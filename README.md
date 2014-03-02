veil
====

veil is a very simple boilerplate for writing static sites.

It uses [Jade][jade] for templating, [Stylus][stylus] for CSS generation and
[GNU Make][make] for the build system.

Install
-------

``` console
# Create your project directory
$ mkdir my-website; cd my-website

# Download the Makefile
$ wget https://raw.github.com/madx/veil/master/Makefile

# Launch the setup task
$ make setup
```

Usage
-----

Building the site requires exactly one command:

``` console
$ make
```

- Pages are written with Jade and stored in `sources/pages/`. They will map to
  a file in your output dir (i.e. `sources/pages/index.jade` →
  `output/index.html`).
- Stylesheets are written with Stylus and stored in `sources/stylesheets/`.
  They will map to a file in the `assets/css/` folder of your output dir (i.e.
  `sources/stylesheets/styles.styl` → `output/assets/css/styles.css`).
- Static assets from the `static/` folder will be copied in the `assets/`
  folder of your output dir, preserving subdirectories (i.e. `static/js/app.js`
  → `output/assets/js/app.js`).

### watch

Provided you have installed either [inotify-tools][inotifytools] (Linux) or
[fswatch][fswatch] (OS X), you can use the `watch` task to continuously rebuild
the site as you modify the source files.

``` console
$ make watch
```

Customisation
-------------

Almost every aspect of Veil is fully customisable though a `config.mk` file.

Creating this file allow you to override all built-in variables and most
commands used during the build process.

You can, for example, change the templating system to another engine:

1. Change the `PAGE_EXT` variable to the extension used by your template engine
2. Redefine the `page-cc` canned recipe to use your command.
3. There is no 3

Read the Makefile to learn what you can customise.

Here's an example `config.mk` for using [Redcarpet][redcarpet] as your
templating engine:

``` make
PAGE_EXT = hbs

define page-cc
@ mkdir -p $(shell dirname $@)
@ redcarpet $< > $@
endef
```

[jade]: http://jade-lang.com/
[redcarpet]: https://github.com/vmg/redcarpet
[stylus]: http://learnboost.github.io/stylus/
[make]: https://www.gnu.org/software/make/
[inotifytools]: https://github.com/rvoicilas/inotify-tools
[fswatch]: https://github.com/alandipert/fswatch
