export TERM="xterm-256color"
export DOTFILES="$HOME/.dotfiles"
export VISUAL="nvim"
export EDITOR="nvim"

# History
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory sharehistory hist_ignore_dups hist_ignore_space

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

# Key bindings
bindkey -e

# Environment
[ -f ~/.env ] && source ~/.env

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Aliases
[ -f ~/.config/zsh/aliases.zsh ] && source ~/.config/zsh/aliases.zsh

# Auto-source all function files
for f in ~/.config/zsh/functions/*.zsh; do
  [ -f "$f" ] && source "$f"
done

# Plugins (installed to /usr/share via pacman)
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# Prompt
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# Path
export PATH="$DOTFILES/bin:$HOME/.local/bin:$PATH"
