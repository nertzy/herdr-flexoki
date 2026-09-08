# Flexoki for Herdr

Light and dark themes for [Herdr](https://github.com/herdrdev/herdr), based on
[Flexoki](https://stephango.com/flexoki) by Steph Ango. Warm paper backgrounds,
inky dark surfaces, and restrained color, with cyan accents.

## Themes

| File | Appearance |
|---|---|
| [`flexoki-auto.toml`](flexoki-auto.toml) | Follows your terminal's light/dark appearance |
| [`flexoki-light.toml`](flexoki-light.toml) | Always light |
| [`flexoki-dark.toml`](flexoki-dark.toml) | Always dark |

Tested with Herdr 0.9.0. Each palette supplies all 19 customizable color tokens.
The light theme uses Flexoki's 600-level accent colors; the dark theme uses its
400-level accents.

## Setup

Clone this repository:

```sh
git clone https://github.com/nertzy/herdr-flexoki.git
cd herdr-flexoki
```

Herdr reads `~/.config/herdr/config.toml` by default, or
`$XDG_CONFIG_HOME/herdr/config.toml` when `XDG_CONFIG_HOME` is set.
`HERDR_CONFIG_PATH` overrides either location; edit that file instead if set.

**For an existing configuration**, back it up, then replace its `[theme]` section
and all `[theme.custom]` subtables with the contents of your chosen theme file.
Keep your other settings. Do not append a second `[theme]` section: duplicate
TOML tables are invalid.

**For a fresh configuration at the default location**, copy one file into place:

```sh
mkdir -p ~/.config/herdr
cp flexoki-auto.toml ~/.config/herdr/config.toml
```

Use `flexoki-light.toml` or `flexoki-dark.toml` instead if you prefer a fixed
appearance. The copy command replaces the whole configuration, so use it only
when there are no existing settings to preserve.

Validate the configuration:

```sh
herdr config check
```

If Herdr is already running, apply it without restarting:

```sh
herdr server reload-config
```

Otherwise, launch `herdr` normally.

### Automatic switching

`flexoki-auto.toml` sets `auto_switch = true` and supplies separate
`[theme.custom.light]` and `[theme.custom.dark]` overrides. Switch your host
terminal's appearance to change palettes. Detection depends on the terminal;
use a fixed theme if automatic switching is unavailable.

These files intentionally omit `theme.name`, `light_name`, and `dark_name`.
Herdr 0.9.0 accepts only built-in theme names in those fields, not filenames or
custom theme names. The Flexoki colors are supplied directly through overrides,
so no named base theme is needed in the configuration.

The themes style Herdr's interface, not the color settings of programs running
inside its panes.

## Check the theme files

From the repository directory:

```sh
for theme in flexoki-*.toml; do
  HERDR_CONFIG_PATH="$PWD/$theme" herdr config check || exit
done
```

## Token mapping and contrast

Flexoki separates backgrounds (`bg`, `bg-2`), interface structure (`ui`, `ui-2`,
`ui-3`), and text (`tx`, `tx-2`, `tx-3`). These roles are not interchangeable:
a divider needs an interface gray, not its surrounding background color.

One visual cue should carry each distinction. Row backgrounds communicate focus
and navigation selection; their text does not need an additional color change
to repeat that state. A secondary text color establishes information hierarchy
without extra dimming. Spacing and alignment establish groups before additional
lines or colored surfaces are needed. Each border or accent should communicate
something not already apparent from another cue.

Restraint does not mean faintness: the chosen cue must be perceptible, and useful
text must remain readable. Removing redundant visual styling does not remove
accessible names, semantic state, or non-color cues needed for accessibility.
Herdr's renderer controls text modifiers such as bold and `DIM`; these TOML
files cannot disable them.

| Herdr token | Flexoki role |
|---|---|
| `panel_bg`, `sidebar_bg` | `bg`, `bg-2` |
| `surface0`, `surface1` | `ui`, `ui-2` |
| `surface_dim` | `ui`; Herdr uses it for sidebar dividers |
| `active_row_bg`, `selection_bg` | `ui`, `ui-3`; workspace focus and navigation selection |
| `text` | `tx` |
| `subtext0` | Light: `base-700`; dark: `base-400` |
| `overlay0` | Light: `base-700`; dark: `base-400`; shared by labels, inactive borders, and the focused scrollbar track |
| `overlay1` | `tx`; shared by scrollbar thumbs and enabled tab controls |

Secondary text uses `base-700` in light mode and `base-400` in dark mode,
one step darker or lighter than canonical `tx-2`, respectively, to help
secondary labels that Herdr additionally dims. The extended Flexoki ramps allow
stronger colors without introducing a foreign palette. However, changing a shared
Herdr token affects both text and controls.
Brighter dark-mode labels, for example, can reduce the contrast between a
scrollbar track and its thumb.

This is **not a WCAG-conformance claim**. Canonical muted text falls below 4.5:1
on some highlighted surfaces, and not every accent is suitable for small text
on every background. Herdr also applies the terminal's `DIM` modifier to some
already-muted agent labels, so hex-pair measurements alone do not describe their
rendered contrast. The terminal and programs inside panes have their own color
and rendering behavior.

The upstream discussion [Optional semantic theme roles for higher-quality custom
themes](https://github.com/herdrdev/herdr/discussions/3802) proposes independent
control of secondary text, borders, and scrollbar colors while retaining shared
palette defaults. These themes work with Herdr's current tokens; they do not
require that proposal to be implemented.

Inline comments in each theme explain the role mappings and shared-token
constraints. Decorative dividers intentionally stay quiet; important text and
controls need separate contrast evaluation rather than uniformly stronger grays.

## Credits

[Flexoki](https://github.com/kepano/flexoki) is created by Steph Ango and
MIT-licensed. This adaptation is also MIT-licensed; see [LICENSE](LICENSE).
