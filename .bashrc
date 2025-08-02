# ~/.bashrc

# ---------------------------------------------------------
# Color macros
# ---------------------------------------------------------

# Base ANSI colors (no shell-specific formatting)
_ANSI_RED='\e[0;31m'
_ANSI_GREEN='\e[0;32m'
_ANSI_YELLOW='\e[0;33m'
_ANSI_BLUE='\e[0;34m'
_ANSI_MAGENTA='\e[0;35m'
_ANSI_CYAN='\e[0;36m'
_ANSI_WHITE='\e[0;37m'
_ANSI_RESET='\e[0m'

# For echo/read (ANSI-safe)
RED=$'\e[0;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
MAGENTA=$'\e[0;35m'
CYAN=$'\e[0;36m'
WHITE=$'\e[0;37m'
RESET=$'\e[0m'

# For PS1 (prompt-safe)
RED_PS1="\[${_ANSI_RED}\]"
GREEN_PS1="\[${_ANSI_GREEN}\]"
YELLOW_PS1="\[${_ANSI_YELLOW}\]"
BLUE_PS1="\[${_ANSI_BLUE}\]"
MAGENTA_PS1="\[${_ANSI_MAGENTA}\]"
CYAN_PS1="\[${_ANSI_CYAN}\]"
WHITE_PS1="\[${_ANSI_WHITE}\]"
RESET_PS1="\[${_ANSI_RESET}\]"

#---------------------------------------------------------
# Aliases
#---------------------------------------------------------

alias ll='ls -lah'
alias la='ls -A'
alias cl='clear'

#---------------------------------------------------------
# Prompt
#---------------------------------------------------------

# Show user@host:path $
PS1="${GREEN_PS1}\u${RESET_PS1}@${CYAN_PS1}\h${RESET_PS1}:${BLUE_PS1}\w${RESET_PS1}\$ "

#---------------------------------------------------------
# Shell behaviour
#---------------------------------------------------------

# Enable colour support
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# History usability
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend

#---------------------------------------------------------
# Git macros
#---------------------------------------------------------

git_timestamp() {
	date +"%Y-%m-%d %H:%M:%S"
}

root_dir() {
	command git rev-parse --show-toplevel 2>/dev/null
}

current_branch() {
	git symbolic-ref --short HEAD 2>/dev/null
}

gs() {
	git -C "$(root_dir)" status
}

ga() {
	local repo_root branch msg timestamp status_output

	repo_root=$(root_dir) || {
		echo "Not inside a Git repository." >&2
		return 1
	}

	branch=$(current_branch) || {
		echo "Failed to determine current branch." >&2
		return 1
	}

	timestamp="$(git_timestamp)"

	gs || {
		echo "Failed to run git status." >&2
		return 1
	}

	status_output=$(git -C "$repo_root" status --porcelain)
	if [ -z "$status_output" ]; then
		return 0
	fi

	# git diff --color

	read -p "${YELLOW}Continue? (y/n): ${RESET}" confirm
	if [[ "$confirm" != [Yy] ]]; then
		echo "${RED}Git commit aborted.${RESET}"
		return 1
	fi

	if [ $# -gt 0 ]; then
		commit_msg="$*"
	else
		read -p "${MAGENTA}Commit message: ${RESET}" commit_msg
		if [ -z "$commit_msg" ]; then
			commit_msg="Generic auto-update"
		fi
	fi

	msg="$timestamp | $commit_msg"

	git add -A &&
	git commit -m "$msg" &&
	git push origin "$branch"
	echo "${GREEN}Pushed to '$branch' with commit: \"$msg\"${RESET}"
}

gl() {
	git log --graph --oneline --decorate --all
}

gu() {
	last_commit=$(git log -1 --pretty=format:"%h | %s")
	echo "Preparing to undo the last commit: "
	echo "${YELLOW}$last_commit${RESET}"
	read -p "Are you sure? (y/n): " confirm
	if [[ "$confirm" == [Yy] ]]; then
		git reset --soft HEAD~1
		echo "${GREEN}Last commit undone. Changes remain staged.${RESET}"
	else
		echo "${RED}Undo aborted.${RESET}"
	fi
}

#---------------------------------------------------------
# Custom functions
#---------------------------------------------------------

update() {
    if [ "$(uname)" = "Darwin" ]; then
        echo "Updating Homebrew on macOS..."
        brew update && brew upgrade && brew cleanup
    elif [ "$(uname)" = "Linux" ]; then
        echo "Updating APT packages on Linux..."
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean
    else
        echo "Unsupported OS: $(uname)"
        return 1
    fi
}

up() {
	local d=""
	for ((i=0; i<$1; i++)); do d+="../"; done
	cd "$d" || return
}

big() {
	du -ah "${1:-.}" | sort -rh | head -n 10
}

trash() {
	if [ ! -d "$HOME/.Trash" ]; then
		echo "${RED}Error:${RESET} Trash does not exist at '$HOME/.Trash'"
		return 1
	fi

	mv "$@" "$HOME/.Trash/"
}

extract() {
	if [ -f "$1" ]; then
		case "$1" in
			*.tar.bz2)   tar xjf "$1"	;;
			*.tar.gz)	tar xzf "$1"	;;
			*.bz2)	   bunzip2 "$1"	;;
			*.rar)	   unrar x "$1"	;;
			*.gz)		gunzip "$1"	 ;;
			*.tar)	   tar xf "$1"	 ;;
			*.tbz2)	  tar xjf "$1"	;;
			*.tgz)	   tar xzf "$1"	;;
			*.zip)	   unzip "$1"	  ;;
			*.Z)		 uncompress "$1" ;;
			*.7z)		7z x "$1"	   ;;
			*)		   echo "Unsupported archive: $1" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}
