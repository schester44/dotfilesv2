#!/usr/bin/env bash
# Generate all themed configs from templates + theme.json
# Usage: generate-themes.sh
#
# Templates live in ~/.dotfiles/system/templates/*.tmpl
# Each template has a companion .dest file OR a destination map below.
# Placeholders use {{section.key}} format, flattened from theme.json.
#
# To add a new app: just drop a .tmpl file in templates/ and add a
# destination entry to the DEST_MAP below.

set -euo pipefail

DOTFILES="$HOME/.dotfiles"
THEME_JSON="$DOTFILES/system/theme.json"
TEMPLATES_DIR="$DOTFILES/system/templates"

# Map: template filename -> output path
declare -A DEST_MAP=(
  ["walker-style.css.tmpl"]="$DOTFILES/home/.config/walker/themes/dotfiles/style.css"
  ["ironbar-style.css.tmpl"]="$DOTFILES/home/.config/ironbar/style.css"
  # ["obsidian.css.tmpl"]="$HOME/.config/obsidian/snippets/theme.css"
)

# Reload commands to run after generation (optional, per app)
declare -A RELOAD_MAP=(
  ["walker-style.css.tmpl"]="killall walker 2>/dev/null; sleep 1; nohup walker --gapplication-service >/dev/null 2>&1 &"
  ["ironbar-style.css.tmpl"]="killall ironbar 2>/dev/null; sleep 1; nohup ironbar >/dev/null 2>&1 &"
)

if [[ ! -f "$THEME_JSON" ]]; then
  echo "Error: $THEME_JSON not found"
  exit 1
fi

# Flatten theme.json into key=value pairs for sed substitution
# e.g. palette.bg.base -> #202024, name -> grapelean
declare -A COLORS
while IFS='=' read -r key value; do
  COLORS["$key"]="$value"
done < <(jq -r '
  paths(scalars) as $p
  | "\($p | join("."))=\(getpath($p))"
' "$THEME_JSON")

# Build sed expression from all flattened keys
SED_ARGS=()
for key in "${!COLORS[@]}"; do
  SED_ARGS+=(-e "s|{{${key}}}|${COLORS[$key]}|g")
done

# Process each template
for tmpl in "$TEMPLATES_DIR"/*.tmpl; do
  [[ -f "$tmpl" ]] || continue
  filename="$(basename "$tmpl")"

  dest="${DEST_MAP[$filename]:-}"
  if [[ -z "$dest" ]]; then
    echo "Warning: no destination for $filename, skipping"
    continue
  fi

  mkdir -p "$(dirname "$dest")"
  sed "${SED_ARGS[@]}" "$tmpl" > "$dest"
  echo "Generated: $dest"

  # Run reload command if defined
  reload="${RELOAD_MAP[$filename]:-}"
  if [[ -n "$reload" ]]; then
    eval "$reload"
  fi
done
