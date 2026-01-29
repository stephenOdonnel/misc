# ~/.bashrc
echo "Hello $USER "

export SHELL=/bin/bash
export VISUAL="vim"
export EDITOR="$VISUAL"
export GIT_EDITOR="$VISUAL"

# History
shopt -s histappend
HISTSIZE=4000000
HISTFILESIZE=4000000
HISTCONTROL=erasedups:ignorespace
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# Window size
shopt -s checkwinsize


# FZF setup 
[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
export FZF_DEFAULT_OPTS='--layout=reverse --info=inline'
if command -v ag &>/dev/null && command -v fzf &>/dev/null; then
    export FZF_DEFAULT_COMMAND='ag --follow -g ""'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

[[ $- != *i* ]] && return

# Bash completion
if [[ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
    source /opt/homebrew/etc/profile.d/bash_completion.sh
elif [[ -r /usr/local/etc/profile.d/bash_completion.sh ]]; then
    source /usr/local/etc/profile.d/bash_completion.sh
fi

# Git prompt
if [[ -f /opt/homebrew/etc/bash_completion.d/git-prompt.sh ]]; then
    source /opt/homebrew/etc/bash_completion.d/git-prompt.sh
elif [[ -f /usr/local/etc/bash_completion.d/git-prompt.sh ]]; then
    source /usr/local/etc/bash_completion.d/git-prompt.sh
fi

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM=auto

set_bash_prompt() {
    local reset="\[\033[0m\]"
    local user="\[\033[0;36m\]\u${reset}"        # pastel cyan
    local host=""
    local path="\[\033[0;34m\]\w${reset}"        # pastel blue
    local git_branch=""
    local status=""

    # Show hostname only if non-local
    if [[ -n "$HOSTNAME" ]] && [[ "$HOSTNAME" != "localhost" ]] && [[ "$HOSTNAME" != "$(hostname)" ]]; then
        host="@\[\033[0;35m\]$HOSTNAME${reset}"   # pastel magenta
    fi

    # Git branch
    if declare -F __git_ps1 >/dev/null; then
        git_branch=$(__git_ps1 "(\[\033[0;32m\]%s${reset})")  # pastel yellow
    fi

    # Last command status
    if [[ $? -eq 0 ]]; then
        status="\[\033[0;32m\]✔${reset}"  # green check
    else
        status="\[\033[0;31m\]✗${reset}"  # red X
    fi

    PS1="${status} ${user}${host}:${path}${git_branch}$ "
}

PROMPT_COMMAND=set_bash_prompt



# 
# Aliases
# 

alias c='clear'
alias q='exit'
alias h='history'
alias r='fh'

alias ls='ls -h -G'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias grep='grep --color=auto'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias .='cd ..'
alias ..='cd ../..'
alias ...='cd ../../..'

#
# Functions
#

# mkdir + cd 
mkcd() {
    mkdir -p -- "$1" && cd -- "$1"
}

fd() {
    local depth="${1:-3}"
    local dir
    dir=$(find . -maxdepth "$depth" -type d ! -path '*/.*' ! -path '*/node_modules/*' | fzf --prompt="fd (depth=$depth)> ") || return
    cd -- "$dir"
}

# Workspace jump
ws() {
    local depth="${1:-3}"       # default depth = 3
    local dir

    cd "$HOME/Desktop/coding" || return


    dir=$(find . \
          -maxdepth "$depth" \
          -type d \
          ! -path '*/.*' \
          ! -path '*/node_modules/*' \
          | fzf --prompt="ws (depth=$depth)> ") || return

    cd -- "$dir"
}

# Fuzzy search history 
__fzf_history_exec() {
    local cmd

    cmd=$(fc -rl 1 | fzf --tac --no-sort) || return
    cmd=${cmd#*[[:space:]]}

    eval "$cmd"
}

# Unbind default Ctrl-R (reverse-i-search)
bind -r '\C-r'

# Bind Ctrl-R to fzf history 
bind -x '"\C-r": "__fzf_history_exec"'




#Fuzzy VS Code launcher in ~/Desktop/code
vf() {
    local dir
    local base="$HOME/Desktop/coding"  

    [ -d "$base" ] || { echo "Directory $base not found"; return; }

    dir=$(find "$base" -maxdepth 3 -type d ! -path '*/.*' ! -path '*/node_modules/*' | fzf --prompt="vf> ") || return

    # Open selected folder in VS Code
    code "$dir"
}



vscode() {
    if command -v code &>/dev/null; then
        if [[ -z "$1" ]]; then
        
            code .
        else
           
            code "$1"
        fi
    else
        echo "VS Code 'code' command not found. Install it via 'Shell Command: Install 'code' command in PATH' in VS Code."
    fi
}

# Optional: BAT theme for fzf previews
export BAT_THEME="1337"
