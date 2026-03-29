alias e="nvim"

alias dot="e ~/.dotfiles"

# Networking
alias pubip='curl ipv4.icanhazip.com'

# Git
alias g="lazygit"
alias gs="git status"
alias gpsu="git_set_upstream"
alias gpoh="git push origin head"
alias gcm="git checkout main"
alias gmm="git merge main"
alias gml="git merge @{-1}"
alias gpm="git pull origin main"
alias glast="git checkout @{-1}"
alias gwl="git worktree list"
alias gwr="git worktree remove"
alias gce="git commit --allow-empty -m"
alias ghd="gh dash"
alias git-rm-branches="git branch --sort=-committerdate --format='%(committerdate:relative)%09%(refname:short)' | awk '{print \$3}' | sed -e 's/^refs\/heads\///' | awk '\$0 !~ /dev|main/' | xargs git branch -D"

# File system
if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

# Navigation
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi
