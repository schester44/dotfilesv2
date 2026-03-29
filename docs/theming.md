# Theming

A template-based theming system that generates app configs from a single `theme.json` color palette. Switch palettes with one command and every themed app updates.

## Quick start

```bash
sc theme              # list palettes
sc theme cobalt44     # switch palette — all configs regenerate
```

## How it works

```
theme.json ──┐
             ├──▶ generate-themes.sh ──▶ walker style.css
templates/ ──┘                      ──▶ waybar style.css
                                    ──▶ obsidian theme.css
                                    ──▶ ...
```

1. `theme.json` is a symlink to the active palette in `system/colors/`
2. Templates in `system/templates/` contain `{{placeholder}}` tokens
3. `generate-themes.sh` flattens `theme.json` into key/value pairs and substitutes them into each template
4. Output files are written to their configured destinations
5. Optional reload commands restart affected apps

## File structure

```
~/.dotfiles/system/
├── theme.json -> colors/grapelean.json     # symlink to active palette
├── colors/
│   ├── grapelean.json                      # palette definitions
│   └── cobalt44.json
├── templates/
│   └── walker-style.css.tmpl               # CSS template with placeholders
└── scripts/
    └── generate-themes.sh                  # template processor
```

## Switching themes

```bash
sc theme                # preview all palettes with color swatches
sc theme <palette>      # activate a palette
```

This updates the `theme.json` symlink and runs `generate-themes.sh` to rebuild all configs.

## Palette format

Each palette in `system/colors/` is a JSON file with three sections:

```json
{
  "name": "grapelean",
  "description": "Gray base with pink, purple, and green accents",

  "palette": {
    "bg":     { "base": "#202024", "dark": "...", "light": "...", "lighter": "...", "muted": "..." },
    "gray":   { "base": "...", "dark": "...", "light": "...", "muted": "..." },
    "black":  "#0a0a0c",
    "white":  "#FFFFFF",
    "orange": { "base": "...", "dark": "...", "light": "..." },
    "yellow": { "base": "...", "dark": "...", "light": "...", "muted": "..." },
    "green":  { "base": "...", "dark": "...", "light": "...", "muted": "...", "glow": "..." },
    "blue":   { "base": "...", "dark": "...", "light": "...", "muted": "..." },
    "purple": { "base": "...", "dark": "...", "light": "...", "muted": "..." },
    "red":    { "base": "...", "dark": "...", "light": "...", "muted": "..." },
    "pink":   { "base": "...", "dark": "...", "light": "...", "muted": "..." }
  },

  "semantic": {
    "background": "...", "foreground": "...",
    "cursor": "...", "cursor_line": "...", "selection": "...",
    "keyword": "...", "string": "...", "function": "...",
    "type": "...", "constant": "...", "comment": "...",
    "error": "...", "warning": "...", "info": "...", "hint": "...",
    "added": "...", "modified": "...", "removed": "..."
  },

  "terminal": {
    "black": "...", "red": "...", "green": "...", "yellow": "...",
    "blue": "...", "purple": "...", "cyan": "...", "white": "...",
    "bright_black": "...", "bright_red": "...", "bright_green": "...",
    "bright_yellow": "...", "bright_blue": "...", "bright_purple": "...",
    "bright_cyan": "...", "bright_white": "..."
  }
}
```

- **palette** — raw color values by hue, each with variants (base, dark, light, muted)
- **semantic** — purpose-driven mappings (editor syntax, diagnostics, git)
- **terminal** — ANSI 16-color mappings

## Writing templates

Templates are files with a `.tmpl` extension in `system/templates/`. Placeholders use the `{{key.path}}` format, matching the flattened JSON paths from `theme.json`.

### Example template

```css
/* My app theme: {{name}} */
background-color: {{palette.bg.base}};
color: {{semantic.foreground}};
accent: {{palette.purple.base}};
error: {{semantic.error}};
```

### Available placeholders

#### Top-level

| Placeholder | Example |
|---|---|
| `{{name}}` | `grapelean` |
| `{{description}}` | `Gray base with pink, purple, and green accents` |

#### Palette (`{{palette.*}}`)

| Placeholder | Description |
|---|---|
| `{{palette.bg.base}}` | Primary background |
| `{{palette.bg.dark}}` | Darker background |
| `{{palette.bg.light}}` | Lighter background |
| `{{palette.bg.lighter}}` | Lightest background |
| `{{palette.bg.muted}}` | Muted background |
| `{{palette.black}}` | Black |
| `{{palette.white}}` | White |
| `{{palette.<color>.base}}` | Base hue (gray, orange, yellow, green, blue, purple, red, pink) |
| `{{palette.<color>.dark}}` | Dark variant |
| `{{palette.<color>.light}}` | Light variant |
| `{{palette.<color>.muted}}` | Muted variant |
| `{{palette.green.glow}}` | Green glow accent |

#### Semantic (`{{semantic.*}}`)

| Placeholder | Purpose |
|---|---|
| `{{semantic.background}}` | Editor/app background |
| `{{semantic.foreground}}` | Primary text |
| `{{semantic.cursor}}` | Cursor color |
| `{{semantic.cursor_line}}` | Current line highlight |
| `{{semantic.selection}}` | Selection highlight |
| `{{semantic.keyword}}` | Syntax: keywords |
| `{{semantic.string}}` | Syntax: strings |
| `{{semantic.function}}` | Syntax: functions |
| `{{semantic.type}}` | Syntax: types |
| `{{semantic.constant}}` | Syntax: constants |
| `{{semantic.comment}}` | Syntax: comments |
| `{{semantic.error}}` | Diagnostic: error |
| `{{semantic.warning}}` | Diagnostic: warning |
| `{{semantic.info}}` | Diagnostic: info |
| `{{semantic.hint}}` | Diagnostic: hint |
| `{{semantic.added}}` | Git: added |
| `{{semantic.modified}}` | Git: modified |
| `{{semantic.removed}}` | Git: removed |

#### Terminal (`{{terminal.*}}`)

| Placeholder | ANSI color |
|---|---|
| `{{terminal.black}}` | Color 0 |
| `{{terminal.red}}` | Color 1 |
| `{{terminal.green}}` | Color 2 |
| `{{terminal.yellow}}` | Color 3 |
| `{{terminal.blue}}` | Color 4 |
| `{{terminal.purple}}` | Color 5 |
| `{{terminal.cyan}}` | Color 6 |
| `{{terminal.white}}` | Color 7 |
| `{{terminal.bright_black}}` | Color 8 |
| `{{terminal.bright_red}}` | Color 9 |
| `{{terminal.bright_green}}` | Color 10 |
| `{{terminal.bright_yellow}}` | Color 11 |
| `{{terminal.bright_blue}}` | Color 12 |
| `{{terminal.bright_purple}}` | Color 13 |
| `{{terminal.bright_cyan}}` | Color 14 |
| `{{terminal.bright_white}}` | Color 15 |

## Adding a new app

Three steps:

### 1. Create a template

```bash
~/.dotfiles/system/templates/waybar-style.css.tmpl
```

Use any `{{placeholder}}` from the tables above.

### 2. Register the destination

Edit `~/.dotfiles/system/scripts/generate-themes.sh` and add to `DEST_MAP`:

```bash
declare -A DEST_MAP=(
  ["walker-style.css.tmpl"]="$HOME/.config/walker/themes/dotfiles/style.css"
  ["waybar-style.css.tmpl"]="$HOME/.config/waybar/style.css"       # ← add this
)
```

### 3. (Optional) Add a reload command

If the app can hot-reload, add to `RELOAD_MAP`:

```bash
declare -A RELOAD_MAP=(
  ["waybar-style.css.tmpl"]="killall -SIGUSR2 waybar 2>/dev/null || true"
)
```

That's it. The next `sc theme <palette>` will generate and deploy the new config.

## Creating a new palette

1. Copy an existing palette:
   ```bash
   cp ~/.dotfiles/system/colors/grapelean.json ~/.dotfiles/system/colors/mypalette.json
   ```

2. Edit the colors in `mypalette.json`

3. Activate it:
   ```bash
   sc theme mypalette
   ```
