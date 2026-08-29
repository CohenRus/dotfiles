# load aliases
source ~/.zaliases

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

# aerospace window switcher using fzf
ff() {
  aerospace list-windows --all |
    fzf --bind 'enter:execute-silent(echo {} | awk "{print \$1}" | xargs aerospace focus --window-id)+abort'
}


# setup yazi to open with "y"
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
}
 rm -f -- "$tmp"

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/cohenrussell/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions


# terminal-wakatime setup
export PATH="$HOME/.wakatime:$PATH"
eval "$(terminal-wakatime init)"
