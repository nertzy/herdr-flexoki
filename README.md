# Flexoki for Herdr

Light and dark themes for [Herdr](https://herdr.dev), based on
[Flexoki](https://stephango.com/flexoki) by Steph Ango. Warm paper backgrounds,
inky dark surfaces, and restrained color, with cyan accents.

Herdr is two separate programs, and this repository themes both:

- **Herdr**, the desktop app ([herdrdev/herdr-app](https://github.com/herdrdev/herdr-app)).
- **Herdr TUI**, the terminal app ([herdrdev/herdr](https://github.com/herdrdev/herdr)).

## Themes

**Herdr (desktop app)**, in [`app/`](app):

| File | Appearance |
| --- | --- |
| [`flexoki-light.json`](app/flexoki-light.json) | Light |
| [`flexoki-dark.json`](app/flexoki-dark.json) | Dark |

Tested with Herdr 0.1.18. Each file sets the terminal palette and every panel
color. Herdr follows the system appearance when given one theme for each.

**Herdr TUI**, in [`tui/`](tui):

| File | Appearance |
| --- | --- |
| [`flexoki-auto.toml`](tui/flexoki-auto.toml) | Follows your terminal's light/dark appearance |
| [`flexoki-light.toml`](tui/flexoki-light.toml) | Always light |
| [`flexoki-dark.toml`](tui/flexoki-dark.toml) | Always dark |

Tested with Herdr TUI 0.9.0. Each palette supplies all 19 customizable color
tokens.

In both, the light theme uses Flexoki's 600-level accent colors and the dark
theme uses its 400-level accents.

## Install

Clone this repository and install with `make`, running the line for each
program you use:

```sh
git clone https://github.com/nertzy/herdr-flexoki.git
cd herdr-flexoki
make install       # Herdr (desktop app)
make install-tui   # Herdr TUI
```

| Command | What it does |
| --- | --- |
| `make install` | Copies both desktop app themes into Herdr's themes folder. |
| `make install-tui` | Copies `tui/flexoki-auto.toml` into place as a new Herdr TUI configuration. It stops without changing anything when a configuration already exists. |
| `make help` | Lists every target and the paths it writes to on your machine. |

Each program then needs one more step:

- **Herdr (desktop app):** choose the themes in Settings or in
  `settings.json`; see [Set up Herdr (desktop app)](#set-up-herdr-desktop-app).
- **Herdr TUI:** reload or launch it, or merge the theme into a configuration
  you already have; see [Set up Herdr TUI](#set-up-herdr-tui).

Both sections also give the commands to run without `make`.

## Set up Herdr (desktop app)

`make install` copies both themes into Herdr's themes folder:

```sh
make install
```

Without `make`, at the default location:

```sh
mkdir -p ~/.config/herdr-app/themes
cp app/flexoki-light.json app/flexoki-dark.json ~/.config/herdr-app/themes/
```

Herdr's folder is `~/.config/herdr-app` by default, or
`$XDG_CONFIG_HOME/herdr-app` when `XDG_CONFIG_HOME` is set. `HERDR_APP_HOME`
overrides either location. `make install` follows the same rules.

They appear in Settings without a restart. To follow the system appearance, set
`theme` in `~/.config/herdr-app/settings.json` and keep your other settings:

```jsonc
{
  // ...your other settings
  "theme": { "light": "flexoki-light", "dark": "flexoki-dark" }
}
```

The change applies live. For a fixed appearance, set `"theme"` to one name
instead, or add `"appearance": "light"` or `"dark"`.

A layout that names its own theme uses that one instead of the setting, and a
theme picked in Settings stays with the layout it was picked on.

Check that Herdr accepted the files:

```sh
herdr-app status
```

Its `errors` list should be empty. Herdr keeps the last good version of an
invalid theme and writes the reason to `<name>.error` beside it.

Unlike the Herdr TUI themes, these also color the terminals: background,
foreground, cursor, selection, and the 16 ANSI colors. The ANSI colors match
Ghostty's built-in Flexoki themes.

## Set up Herdr TUI

Herdr TUI reads `~/.config/herdr/config.toml` by default, or
`$XDG_CONFIG_HOME/herdr/config.toml` when `XDG_CONFIG_HOME` is set.
`HERDR_CONFIG_PATH` overrides either location; edit that file instead if set.

**For an existing configuration**, back it up, then replace its `[theme]` section
and all `[theme.custom]` subtables with the contents of your chosen theme file.
Keep your other settings. Do not append a second `[theme]` section: duplicate
TOML tables are invalid.

**For a fresh configuration**, copy one file into place:

```sh
make install-tui
```

Add `TUI_THEME=light` or `TUI_THEME=dark` if you prefer a fixed appearance. The
copy replaces the whole configuration, so `make install-tui` stops without
changing anything when a configuration already exists.

Without `make`, at the default location:

```sh
mkdir -p ~/.config/herdr
cp tui/flexoki-auto.toml ~/.config/herdr/config.toml
```

Validate the configuration:

```sh
herdr config check
```

If Herdr TUI is already running, apply it without restarting:

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
Herdr TUI 0.9.0 accepts only built-in theme names in those fields, not filenames
or custom theme names. The Flexoki colors are supplied directly through
overrides, so no named base theme is needed in the configuration.

The themes style Herdr TUI's interface, not the color settings of programs
running inside its panes.

## Check the theme files

From the repository directory:

```sh
make check
```

`make check-tui` runs `herdr config check` against each TOML theme.
`make check-app` needs [jq](https://jqlang.org); it confirms that each JSON
theme parses and that every color is a hex value. Herdr itself reports whether
it accepted an installed theme, as described under
[Set up Herdr (desktop app)](#set-up-herdr-desktop-app).

With [mise](https://mise.jdx.dev), `mise install` provides both `herdr` and
jq. CI runs the same check on Linux and macOS for every pull request.

## Package the theme files

Set `PREFIX` to copy every theme into a shared directory instead of your own
configuration, and `DESTDIR` to stage that copy:

```sh
make install PREFIX=/usr/local
```

The themes land in `$PREFIX/share/herdr-flexoki/app` and
`$PREFIX/share/herdr-flexoki/tui`. Neither program reads that directory, so
set each one up from there as described above.

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

This is **not a WCAG-conformance claim** for either set of themes. Not every
accent is suitable for small text on every background, and the programs inside
panes have their own colors.

### Herdr (desktop app)

| Herdr color | Flexoki role |
| --- | --- |
| `background`, `surface` | `bg`; terminals and cards |
| `canvas`, `chrome`, `popover` | `bg-2`; the area behind cards, sidebars and bars, menus and dialogs |
| `hover`, `border` | `ui` |
| `selected`, `raised` | `ui-2` |
| `input`, `selection` | `ui-3`; `input` is the stronger border |
| `foreground`, `terminal_foreground`, `cursor`, `solid` | `tx` |
| `muted` | Light: `base-800`; dark: `base-300` |
| `dim`, `idle`, `unknown` | Light: `base-700`; dark: `base-400` |
| `accent`, `ring` | Cyan |
| `working`, `blocked`, `done` | Yellow, red, blue |

Without a `colors` block, Herdr derives panel colors from the terminal palette:
a near-white foreground in dark themes, translucent white or black borders and
hovers, and its stock status colors. These files set every color so that each
one is a Flexoki value.

Flexoki has two background steps and Herdr has three surfaces. Terminals and
cards take `bg`. Everything around them takes `bg-2`, so a card reads as paper
on a desk and a menu stands out over a terminal. `hover` and `selected` are one
interface step apart, which keeps the pointed row and the current row distinct.

Herdr's panels put most secondary labels in `dim`, including on the current
row, where canonical `tx-2` falls to about 3.5:1. `dim` therefore uses
`base-700` in light mode and `base-400` in dark mode, one step stronger than
`tx-2` and the same choice the TUI themes make. `muted` is one step stronger
again, which keeps the two levels distinct. Measured contrast for `dim`:

| Surface | Light | Dark |
| --- | --- | --- |
| Sidebar (`bg-2`) | 6.4:1 | 6.3:1 |
| Current row (`ui-2`) | 5.1:1 | 4.7:1 |

Light-mode yellow, used for the working status, is 3.1:1 on the sidebar.

### Herdr TUI

Herdr TUI's renderer controls text modifiers such as bold and `DIM`; these TOML
files cannot disable them.

| Herdr TUI token | Flexoki role |
| --- | --- |
| `panel_bg`, `sidebar_bg` | `bg`, `bg-2` |
| `surface0`, `surface1` | `ui`, `ui-2` |
| `surface_dim` | `ui`; Herdr TUI uses it for sidebar dividers |
| `active_row_bg`, `selection_bg` | `ui`, `ui-3`; workspace focus and navigation selection |
| `text` | `tx` |
| `subtext0` | Light: `base-700`; dark: `base-400` |
| `overlay0` | Light: `base-700`; dark: `base-400`; shared by labels, inactive borders, and the focused scrollbar track |
| `overlay1` | `tx`; shared by scrollbar thumbs and enabled tab controls |

Secondary text uses `base-700` in light mode and `base-400` in dark mode,
one step darker or lighter than canonical `tx-2`, respectively, to help
secondary labels that Herdr TUI additionally dims. The extended Flexoki ramps
allow stronger colors without introducing a foreign palette. However, changing a
shared Herdr TUI token affects both text and controls.
Brighter dark-mode labels, for example, can reduce the contrast between a
scrollbar track and its thumb.

Canonical muted text falls below 4.5:1 on some highlighted surfaces. Herdr TUI
also applies the terminal's `DIM` modifier to some already-muted agent labels,
so hex-pair measurements alone do not describe their rendered contrast. The
terminal has its own color and rendering behavior.

The upstream discussion [Optional semantic theme roles for higher-quality custom
themes](https://github.com/herdrdev/herdr/discussions/3802) proposes independent
control of secondary text, borders, and scrollbar colors while retaining shared
palette defaults. These themes work with Herdr TUI's current tokens; they do not
require that proposal to be implemented.

Inline comments in each TOML theme explain the role mappings and shared-token
constraints. Decorative dividers intentionally stay quiet; important text and
controls need separate contrast evaluation rather than uniformly stronger grays.

## Credits

[Flexoki](https://github.com/kepano/flexoki) is created by Steph Ango and
MIT-licensed. This adaptation is also MIT-licensed; see [LICENSE](LICENSE).
