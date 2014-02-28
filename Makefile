# Veil - Copyright © 2014 François Vaux

# OS version
UNAME = $(shell uname -s)

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

watch:
	@ echo -e "\e[33m* Watching for changes\e[0m"
ifeq ($(UNAME),Linux)
	@inotifywait -qrm sources/ -e CLOSE_WRITE | while read; do make; done
endif
ifeq ($(UNAME),Darwin)
	@fswatch sources/ make
endif

# Cleanup: remove all output files
clean:
	@ echo -e "\e[33m* Cleaning\e[0m"
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
	@ echo -e "\e[33m* Building $(@:$(OUTDIR)/%=%)\e[0m"
	@ mkdir -p $(shell dirname $@)
	@ jade -P -o $(shell dirname $@) $<

# Rule for stylesheets
$(CSSDIR)/%.css: sources/stylesheets/%.styl | $(CSSDIR)
	@ echo -e "\e[33m* Building $(@:$(OUTDIR)/%=%)\e[0m"
	@ stylus -u autoprefixer-stylus -o $(CSSDIR) $<

# Rules for static assets
$(ASSETSDIR)/%: static/% | $(ASSETSDIR)
	@ echo -e "\e[33m* Asset: $(@:$(OUTDIR)/%=%)\e[0m"
	@ mkdir -p $(shell dirname $@)
	@ cp $< $(shell dirname $@)

# Setup task
setup: npm-deps bootstrap

# Install npm dependencies
npm-deps:
	@ echo -e "\e[33m* Installing dependencies\e[0m"
	@ sudo npm install -g jade stylus autoprefixer-stylus

# Bootstrap files
bootstrap:
	@ test -d sources && { echo -e "\n\e[31mAlready set up\e[0m\n"; exit 1; } || true
	@ echo -e "\e[33m* Creating directory structure\e[0m"
	@ mkdir -p sources/{layouts,pages,stylesheets} static
	@
	@ echo -e "\e[33m* Installing normalize\e[0m"
	@ wget https://raw.github.com/skw/normalize.stylus/master/normalize.styl -O sources/stylesheets/normalize_.styl
	@ sed -i "9s/^/\/\//" sources/stylesheets/normalize_.styl
	@
	@ echo -e "\e[33m* Bootstraping files\e[0m"
	@ wget https://raw.github.com/madx/veil/master/skel/default.jade -O sources/layouts/default.jade
	@ wget https://raw.github.com/madx/veil/master/skel/index.jade -O sources/pages/index.jade
	@ wget https://raw.github.com/madx/veil/master/skel/stylesheet.styl -O sources/stylesheets/stylesheet.styl

.PHONY: all clean setup npm-deps bootstrap
