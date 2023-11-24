# Add zsh completions from brew
source ~/bin/completion-brew.zsh
source ~/bin/zshrc-vi-edit-mode.zsh
source ~/bin/zshrc-k8s.zsh
source ~/bin/zshrc-aliases.zsh

# Custom options
set -o vi
which nvim >/dev/null 2>&1 && alias vi=nvim
