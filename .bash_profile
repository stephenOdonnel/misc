#!/bin/bash
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"

# Load bashrc for interactive shells
if [[ -f ~/.bashrc ]]; then
  source ~/.bashrc
fi
