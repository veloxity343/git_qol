# ~/.bash_profile

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

if [ -f "$HOME/.bashrc" ]; then
	source "$HOME/.bashrc"
fi
