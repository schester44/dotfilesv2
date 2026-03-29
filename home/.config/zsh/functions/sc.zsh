_sc() {
  local commands_dir="$HOME/.dotfiles/bin/sc-commands"

  case $CURRENT in
    2)
      # Complete standalone commands + module names
      local -a items
      for f in "$commands_dir"/*; do
        items+=($(basename "$f"))
      done
      compadd -- "${items[@]}"
      ;;
    3)
      local cmd="${words[2]}"
      if [[ -d "$commands_dir/$cmd" ]]; then
        # Module: complete action names
        compadd -- ${(f)"$(ls "$commands_dir/$cmd" 2>/dev/null)"}
      elif [[ "$cmd" == "theme" ]]; then
        # Standalone theme: complete palette names
        compadd -- ${(f)"$(ls "$HOME/.dotfiles/system/colors"/*.json 2>/dev/null | xargs -I{} basename {} .json)"}
      fi
      ;;
  esac
}

compdef _sc sc
