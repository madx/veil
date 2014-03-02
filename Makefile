# Veil - Copyright © 2014 François Vaux
#
# This Makefile provides the complete Veil build system.
# You can override all the variables by creating a config.mk file and using the
# same Makefile syntax.

# -- 1. General variables --

# OS version
UNAME = $(shell uname -s)

# Colors
COL_R = "\\033[31m"
COL_G = "\\033[32m"
COL_Y = "\\033[33m"
ENDC  = "\\033[0m"


# -- 2. Sources and output --

# Extension for source page files
PAGE_EXT = jade

# Estension for source stylesheets
STYLE_EXT = styl

# Source files
PAGES       = $(shell find sources/pages/ \
                -name "*.$(PAGE_EXT)" \
                -not -name "_*.$(PAGE_EXT)" 2>/dev/null)
STYLESHEETS = $(shell find sources/stylesheets/ \
                -name "*.$(STYLE_EXT)" \
                -not -name "_*.$(STYLE_EXT)" 2>/dev/null)
LAYOUTS     = $(shell find sources/layouts/ \
                -name "*.$(PAGE_EXT)" 2>/dev/null)
OTHER       = $(shell find static -type f 2>/dev/null)

# Output directories
OUTDIR    = output
ASSETSDIR = $(OUTDIR)/assets
CSSDIR    = $(ASSETSDIR)/css

# Output files
HTML = $(addsuffix .html,\
         $(basename $(PAGES:sources/pages/%=$(OUTDIR)/%)))
CSS = $(addsuffix .css,\
        $(basename $(STYLESHEETS:sources/stylesheets/%=$(CSSDIR)/%)))
STATIC = $(OTHER:static/%=$(ASSETSDIR)/%)


# -- 3. Commands --

# Echo command
ECHO = echo -e

# Command used by the watch rule
WATCH = inotifywait -qrm sources/ static/ -e CLOSE_WRITE | while read; do make -s; done

# OS X-specific overrides
ifeq ($(UNAME),Darwin)
ECHO = echo
WATCH = fswatch sources/:static/ "make -s"
endif

# Commands used by the page-building rule
define page-cc =
@ jade -P -o $(shell dirname $@) >/dev/null $<
endef

# Commands used by the stylesheet-building rule
define stylesheet-cc =
@ stylus -u autoprefixer-stylus -o $(shell dirname $@) >/dev/null $<
endef

# Commands used by the assets-building rule
define asset-cc =
@ mkdir -p $(shell dirname $@)
@ cp $< $(shell dirname $@)
endef

# Override variables with included config.mk if it exists
-include config.mk

# -- 4. Rules and recipes --

# Default rule: build everything
all: announce-rebuild html css assets
	@ $(ECHO) "$(COL_G)✓ Done$(ENDC)"

watch:
	@ $(ECHO) "$(COL_Y)▸ Watching for changes$(ENDC)"
	@ $(WATCH)

# Cleanup: remove all output files
clean:
	@ $(ECHO) "$(COL_Y)♻ Cleaning$(ENDC)"
	@ rm -rf $(OUTDIR)

# Meta-tasks for html, css and static
html:   $(HTML)
css:    $(CSS)
assets: $(STATIC)

# Rules for building the output folders
$(OUTDIR):
	@ mkdir -p $(OUTDIR)

$(ASSETSDIR):
	@ mkdir -p $(ASSETSDIR)

$(CSSDIR):
	@ mkdir -p $(CSSDIR)

# Rule to announce a rebuild
announce-rebuild:
	@ $(ECHO) "$(COL_Y)▸ Rebuilding$(ENDC)"

# Rule for HTML files
$(OUTDIR)/%.html: sources/pages/%.$(PAGE_EXT) | $(OUTDIR)
	@ $(ECHO) "  $(@:$(OUTDIR)/%=%)"
	$(page-cc)

# Rule for stylesheets
$(CSSDIR)/%.css: sources/stylesheets/%.$(STYLE_EXT) | $(CSSDIR)
	@ $(ECHO) "  $(@:$(OUTDIR)/%=%)"
	$(stylesheet-cc)

# Rules for static assets
$(ASSETSDIR)/%: static/% | $(ASSETSDIR)
	@ $(ECHO) "  $(@:$(OUTDIR)/%=%)"
	$(asset-cc)

# Setup task
setup: npm-deps bootstrap

# Install npm dependencies
npm-deps:
	@ $(ECHO) "$(COL_Y)▸ Installing dependencies$(ENDC)"
	@ sudo npm install -g jade stylus autoprefixer-stylus

# Bootstrap files
bootstrap:
	@ test -d sources && { echo -e "\n$(COL_R)✗ Already set up$(ENDC)\n"; exit 1; } || true
	@ $(ECHO) "$(COL_Y)▸ Creating directory structure$(ENDC)"
	@ mkdir -p sources/{layouts,pages,stylesheets} static
	@
	@ $(ECHO) "$(COL_Y)▸ Installing normalize$(ENDC)"
	@ curl -s https://raw.github.com/skw/normalize.stylus/master/normalize.styl > sources/stylesheets/_normalize.styl
	@ sed -i "9s/^/\/\//" sources/stylesheets/_normalize.styl
	@ sed -i "s/\(box-sizing\)(\([^)]\+\))/\1 \2/" sources/stylesheets/_normalize.styl
	@ $(ECHO) "  sources/stylesheets/_normalize.styl"
	@
	@ $(ECHO) "$(COL_Y)▸ Bootstraping with default files$(ENDC)"
	@ curl -s https://raw.github.com/madx/veil/master/skel/default.jade > sources/layouts/default.jade
	@ $(ECHO) "  sources/layout/default.jade"
	@ curl -s https://raw.github.com/madx/veil/master/skel/index.jade > sources/pages/index.jade
	@ $(ECHO) "  sources/pages/index.jade"
	@ curl -s https://raw.github.com/madx/veil/master/skel/stylesheet.styl > sources/stylesheets/stylesheet.styl
	@ $(ECHO) "  sources/stylesheets/stylesheet.styl"
	@
	@ $(ECHO) "$(COL_G)✓ Done$(ENDC)"

# Upgrade this makefile
upgrade:
	@ $(ECHO) "$(COL_Y)▸ Fetching latest Makefile$(ENDC)"
	@ curl -s https://raw.github.com/madx/veil/master/Makefile > Makefile
	@ $(ECHO) "$(COL_G)✓ Done$(ENDC)"

.PHONY: all clean setup npm-deps bootstrap announce-rebuild upgrade
