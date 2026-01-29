# ~/.bashrc
echo "Hello Stephen"
# -----------------------------
# Basic environment
# -----------------------------
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

# -----------------------------
# Bash completion (Homebrew)
# -----------------------------
if [[ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
    source /opt/homebrew/etc/profile.d/bash_completion.sh
elif [[ -r /usr/local/etc/profile.d/bash_completion.sh ]]; then
    source /usr/local/etc/profile.d/bash_completion.sh
fi

# -----------------------------
# Git branch prompt
# -----------------------------
if [[ -f /opt/homebrew/etc/bash_completion.d/git-prompt.sh ]]; then
    source /opt/homebrew/etc/bash_completion.d/git-prompt.sh
elif [[ -f /usr/local/etc/bash_completion.d/git-prompt.sh ]]; then
    source /usr/local/etc/bash_completion.d/git-prompt.sh
fi

# -----------------------------
# FZF setup (Homebrew)
# -----------------------------
[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
export FZF_DEFAULT_OPTS='--layout=reverse --info=inline'
if command -v ag &>/dev/null && command -v fzf &>/dev/null; then
    export FZF_DEFAULT_COMMAND='ag --follow -g ""'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# -----------------------------
# Prompt function
# -----------------------------
set_bash_prompt() {
    local reset="\[\033[0m\]"
    local userhost="\[\033[1;32m\]\u@\h\[\033[0m\]"
    local dir="\[\033[1;34m\]\w\[\033[0m\]"
    local git_branch=""

    if command -v __git_ps1 &>/dev/null; then
        git_branch=$(__git_ps1 " (\[\033[1;33m\]%s\[\033[0m\])")
    fi

    PS1="${userhost}:${dir}${git_branch}$ "
}

# Append to PROMPT_COMMAND safely
PROMPT_COMMAND="set_bash_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# -----------------------------
# Aliases
# -----------------------------

alias c='clear'
alias q='exit'
alias h='history'
alias r='fh'

# macOS-safe ls colors
alias ls='ls -h -G'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias grep='grep --color=auto'

# Safer file ops
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Navigation
alias .='cd ..'
alias ..='cd ../..'
alias ...='cd ../../..'

# -----------------------------
# Functions
# -----------------------------

# mkdir + cd safely
mkcd() {
    mkdir -p -- "$1" && cd -- "$1"
}

# Depth-limited fuzzy cd using find + fzf
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

    # Go to your workspace root
    cd "$HOME/Desktop/coding" || return

    # Use find with maxdepth and skip hidden directories
    dir=$(find . \
          -maxdepth "$depth" \
          -type d \
          ! -path '*/.*' \
          ! -path '*/node_modules/*' \
          | fzf --prompt="ws (depth=$depth)> ") || return

    # Change to selected directory safely
    cd -- "$dir"
}
# -----------------------------
# Fuzzy search history 
# -----------------------------
__fzf_history_exec() {
    local cmd
    # Get history (newest first)
    cmd=$(fc -rl 1 | fzf --tac --no-sort) || return
    # Strip leading history number
    cmd=${cmd#*[[:space:]]}
    # Execute immediately
    eval "$cmd"
}

# Unbind default Ctrl-R (reverse-i-search)
bind -r '\C-r'

# Bind Ctrl-R to our fzf history exec
bind -x '"\C-r": "__fzf_history_exec"'



# -----------------------------
# Fuzzy VS Code launcher in ~/Desktop/code
# -----------------------------
vf() {
    local dir
    local base="$HOME/Desktop/coding"   # base directory to search

    # Make sure base exists
    [ -d "$base" ] || { echo "Directory $base not found"; return; }

    # Fuzzy select a directory with depth limit 3, skip hidden dirs
    dir=$(find "$base" -maxdepth 3 -type d ! -path '*/.*' ! -path '*/node_modules/*' | fzf --prompt="vf> ") || return

    # Open selected folder in VS Code
    code "$dir"
}


# -----------------------------
# VS Code launcher
# -----------------------------
vscode() {
    if command -v code &>/dev/null; then
        if [[ -z "$1" ]]; then
            # No argument → open current directory
            code .
        else
            # Open specified file or folder
            code "$1"
        fi
    else
        echo "VS Code 'code' command not found. Install it via 'Shell Command: Install 'code' command in PATH' in VS Code."
    fi
}

# Optional: BAT theme for fzf previews
export BAT_THEME="1337"
