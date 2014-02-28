# Veil - Copyright © 2014 François Vaux

# Colors
COL_R = "\\033[31m"
COL_G = "\\033[32m"
COL_Y = "\\033[33m"
ENDC  = "\\033[0m"

# OS version
UNAME = $(shell uname -s)

# OS specific variables
ifeq ($(UNAME),Linux)
ECHO = echo -e
WATCH = inotifywait -qrm sources/ -e CLOSE_WRITE | while read; do make -s; done
endif
ifeq ($(UNAME),Darwin)
ECHO = echo
WATCH = fswatch sources/ "make -s"
endif

# Source files
PAGES       = $(shell find sources/pages -name *.jade 2>/dev/null)
LAYOUTS     = $(wildcard sources/layouts/*.jade)
STYLESHEETS = $(filter-out %_.styl,$(wildcard sources/stylesheets/*.styl))
OTHER       = $(shell find static -type f 2>/dev/null)

# Output files
HTML   = $(addsuffix .html,\
				 	 $(basename $(PAGES:sources/pages%=output%)))
CSS    = $(addsuffix .css,\
           $(basename $(STYLESHEETS:sources/stylesheets%=output/assets/css%)))
STATIC = $(OTHER:static/%=output/assets/%)

# Output directories
OUTDIR    = output
ASSETSDIR = $(OUTDIR)/assets
CSSDIR    = $(ASSETSDIR)/css

# Default task: build everything
all: html css static
	@ $(ECHO) "$(COL_G)✓ Done$(ENDC)"

watch:
	@ $(ECHO) "$(COL_Y)▸ Watching for changes$(ENDC)"
	@ $(WATCH)

# Cleanup: remove all output files
clean:
	@ $(ECHO) "$(COL_Y)♻ Cleaning$(ENDC)"
	@ rm -rf $(OUTDIR)

# Meta-tasks for html, css and static
html: $(HTML)
css:  $(CSS)
static: $(STATIC)

# Rules for building the output folders
$(OUTDIR):
	@ mkdir -p $(OUTDIR)

$(ASSETSDIR):
	@ mkdir -p $(ASSETSDIR)

$(CSSDIR):
	@ mkdir -p $(CSSDIR)

# Rule for HTML files
$(OUTDIR)/%.html: sources/pages/%.jade | $(OUTDIR)
	@ $(ECHO) "$(COL_Y)▸ Building $(@:$(OUTDIR)/%=%)$(ENDC)"
	@ mkdir -p $(shell dirname $@)
	@ jade -P -o $(shell dirname $@) >/dev/null $<

# Rule for stylesheets
$(CSSDIR)/%.css: sources/stylesheets/%.styl | $(CSSDIR)
	@ $(ECHO) "$(COL_Y)▸ Building $(@:$(OUTDIR)/%=%)$(ENDC)"
	@ stylus -u autoprefixer-stylus -o $(CSSDIR) >/dev/null $<

# Rules for static assets
$(ASSETSDIR)/%: static/% | $(ASSETSDIR)
	@ $(ECHO) "$(COL_Y)▸ Asset: $(@:$(OUTDIR)/%=%)$(ENDC)"
	@ mkdir -p $(shell dirname $@)
	@ cp $< $(shell dirname $@)

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
	@ curl -s https://raw.github.com/skw/normalize.stylus/master/normalize.styl > sources/stylesheets/normalize_.styl
	@ sed -i "9s/^/\/\//" sources/stylesheets/normalize_.styl
	@ $(ECHO) "  sources/stylesheets/normalize_.styl"
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

.PHONY: all clean setup npm-deps bootstrap
