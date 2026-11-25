# Check and install the Flexoki themes for Herdr and Herdr TUI.
# Written for the make that ships with macOS (GNU Make 3.81).

APP_THEMES := app/flexoki-light.json app/flexoki-dark.json
TUI_THEMES := tui/flexoki-auto.toml tui/flexoki-light.toml tui/flexoki-dark.toml

# The locations the two programs read, with the same overrides they honor.
CONFIG_HOME := $(or $(XDG_CONFIG_HOME),$(HOME)/.config)
APP_HOME    := $(or $(HERDR_APP_HOME),$(CONFIG_HOME)/herdr-app)
TUI_CONFIG  := $(or $(HERDR_CONFIG_PATH),$(CONFIG_HOME)/herdr/config.toml)

# With PREFIX set, the install targets copy every theme under
# PREFIX/share/herdr-flexoki instead, as a package would, and DESTDIR stages
# that copy. Neither program reads that directory.
ifdef PREFIX
SHARE    := $(DESTDIR)$(PREFIX)/share/herdr-flexoki
APP_DEST := $(SHARE)/app
TUI_DEST := $(SHARE)/tui
else
APP_DEST := $(APP_HOME)/themes
endif

# The theme install-tui copies: auto, light, or dark.
TUI_THEME ?= auto

.PHONY: help check check-app check-tui install install-app install-tui

help:
	@echo "make check        check every theme file"
	@echo "make check-app    check app/*.json (needs jq)"
	@echo "make check-tui    check tui/*.toml (needs herdr)"
ifdef PREFIX
	@echo "make install      copy every theme to $(SHARE)"
	@echo "make install-app  copy app/*.json to $(APP_DEST)"
	@echo "make install-tui  copy tui/*.toml to $(TUI_DEST)"
else
	@echo "make install      copy the desktop app themes to $(APP_DEST)"
	@echo "make install-tui  copy tui/flexoki-$(TUI_THEME).toml to $(TUI_CONFIG),"
	@echo "                  only when that file does not exist yet (TUI_THEME=auto|light|dark)"
	@echo ""
	@echo "With PREFIX set (and DESTDIR to stage), the install targets copy every"
	@echo "theme to PREFIX/share/herdr-flexoki instead."
endif

check: check-app check-tui

# Herdr has no offline check for a theme file, so this checks what can be
# checked without it: the file parses, and every string in it is a color.
# jq prints the offenders JSON-encoded on one line, so an empty string shows
# up as "" instead of vanishing in the command substitution.
check-app: $(APP_THEMES)
	@for theme in $(APP_THEMES); do \
		bad=$$(jq -r '[.. | strings | select(test("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$$") | not) | tojson] | join(" ")' "$$theme") \
			|| { echo "$$theme: not valid JSON"; exit 1; }; \
		if [ -n "$$bad" ]; then printf '%s: not #rrggbb or #rrggbbaa: %s\n' "$$theme" "$$bad"; exit 1; fi; \
		echo "$$theme: ok"; \
	done

# Listing the files as prerequisites matters: herdr reports "config: ok" for a
# path that does not exist, so a missing theme has to fail here instead.
check-tui: $(TUI_THEMES)
	@for theme in $(TUI_THEMES); do \
		printf '%s: ' "$$theme"; \
		HERDR_CONFIG_PATH="$(CURDIR)/$$theme" herdr config check || exit 1; \
	done

install-app: $(APP_THEMES)
	install -d "$(APP_DEST)"
	install -m 644 $(APP_THEMES) "$(APP_DEST)/"

ifdef PREFIX

install: install-app install-tui

install-tui: $(TUI_THEMES)
	install -d "$(TUI_DEST)"
	install -m 644 $(TUI_THEMES) "$(TUI_DEST)/"

else

install: install-app

# Copying a theme replaces the whole configuration, so this never overwrites
# one. An existing configuration needs its [theme] section merged by hand.
install-tui: tui/flexoki-$(TUI_THEME).toml
	@if [ -e "$(TUI_CONFIG)" ]; then \
		echo "$(TUI_CONFIG) already exists."; \
		echo "Replace its [theme] section by hand; see \"Set up Herdr TUI\" in README.md."; \
		exit 1; \
	fi
	mkdir -p "$$(dirname "$(TUI_CONFIG)")"
	install -m 644 $< "$(TUI_CONFIG)"

endif
