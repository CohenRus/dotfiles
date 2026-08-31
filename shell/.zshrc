# load aliases
source ~/.zaliases

# enable completition system
autoload -U compinit $$ compinit

# source arch plugins
# source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# use vim motions and ensure colors work
bindkey -v
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagaced

# load up starship prompt
eval "$(starship init zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# cd and list files
cx() {
	cd "$1" || return
	ls -a
}

# setup yazi to open with "y"
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
}
 rm -f -- "$tmp"

