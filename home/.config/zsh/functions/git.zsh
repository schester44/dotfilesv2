# Set upstream to origin for current branch
git_set_upstream() {
  local branch
  branch=$(git branch --show-current)
  git branch --set-upstream-to="origin/$branch" "$branch"
}

# Fuzzy find and checkout a git branch
gfb() {
  local branch
  branch=$(git branch --sort=-committerdate --format="%(refname:short)" | fzf)
  if [[ -n "$branch" ]]; then
    git checkout "$branch"
  fi
}
