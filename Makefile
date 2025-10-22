#################
# Pyllock Makefile
# v0.9.2
#
# For more details, see https://github.com/Zoidmania/pyllock.
#
# MIT License
#
# Copyright (c) 2025 Leland Vakarian
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#################


## Preflight Checks ################################################################################


# If OS is Windows, exits with error.
ifeq ($(OS),Windows_NT)
    $(error Pyllock does not support Windows.)
endif


## Configs #########################################################################################


# For performance reasons and to make intermediate env vars "persistent", we use one subshell.
# See: https://www.gnu.org/software/make/manual/html_node/One-Shell.html
.ONESHELL:

# Force serial execution. All of these recipes are intended to run serially; parallel execution
# could fail.
# See: https://www.gnu.org/software/make/manual/html_node/Parallel-Disable.html
.NOTPARALLEL:

# Set a default target. In this case, print simple usage.
.DEFAULT_GOAL := usage


## Environment #####################################################################################


BASEDIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

# By default GNU make loads what is already in `env`. This extends that behavior to other files.
PYLLOCK_ENV_FILE ?= .env
ifneq ("$(wildcard $(PYLLOCK_ENV_FILE))","")
	$(eval include $(PYLLOCK_ENV_FILE))
endif

PYLLOCK_BASE_PYTHON ?= /usr/bin/env python3
PYLLOCK_NO_VENV ?= 0
PYLLOCK_VENV_NAME ?= "venv"
PYLLOCK_VENV_PREFIX ?= "$(shell basename $(BASEDIR))"
PYLLOCK_ENV ?= dev
PYLLOCK_LOCK_DIR ?= $(BASEDIR)/lock
# If NO_VENV is set, use the base interpreter. Otherwise, use the venv's interpreter.
ifeq ($(PYLLOCK_NO_VENV),1)
    INTERPRETER := $(PYLLOCK_BASE_PYTHON)
else
    INTERPRETER := $(BASEDIR)/$(PYLLOCK_VENV_NAME)/bin/python
endif

# Pin the pip-tools version range so this Makefile can predict its behavior. Pip follows version
# specifiers outlined in PEP440, even inline on the CLI. Note that, if a range is specified like
# this, it must be surrounded with quotes.
PYLLOCK_PIPTOOLS_VERSION ?= >=7.5.1,<8

# Respect https://no-color.org/.
NO_COLOR ?= 0
ifneq ($(shell tput colors),256)
    INSUFFICIENT_COLORS := true
else
    INSUFFICIENT_COLORS := false
endif
# If NO_COLOR asserted or insufficient colors supported, disable colors.
NO_COLOR_ENABLED := $(or $(findstring 1,$(NO_COLOR)),$(findstring true,$(INSUFFICIENT_COLORS)))

## ANSI Escapes
# All high-intensity colors aren't boldable. The only high-intensity color used here is Orange.
# For more info, see https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit.
# NB: When passing to 'echo', you shouldn't add quotes.

# basic
BLACK   := $(if $(NO_COLOR_ENABLED),,\033[0;30m)
RED     := $(if $(NO_COLOR_ENABLED),,\033[0;31m)
GREEN   := $(if $(NO_COLOR_ENABLED),,\033[0;32m)
YELLOW  := $(if $(NO_COLOR_ENABLED),,\033[0;33m)
BLUE    := $(if $(NO_COLOR_ENABLED),,\033[0;34m)
MAGENTA := $(if $(NO_COLOR_ENABLED),,\033[0;35m)
CYAN    := $(if $(NO_COLOR_ENABLED),,\033[0;36m)
WHITE   := $(if $(NO_COLOR_ENABLED),,\033[0;37m)
ORANGE  := $(if $(NO_COLOR_ENABLED),,\033[38;5;214m)

# bold
BD_STD     := $(if $(NO_COLOR_ENABLED),,\033[1m)
BD_BLACK   := $(if $(NO_COLOR_ENABLED),,\033[1;30m)
BD_RED     := $(if $(NO_COLOR_ENABLED),,\033[1;31m)
BD_GREEN   := $(if $(NO_COLOR_ENABLED),,\033[1;32m)
BD_YELLOW  := $(if $(NO_COLOR_ENABLED),,\033[1;33m)
BD_BLUE    := $(if $(NO_COLOR_ENABLED),,\033[1;34m)
BD_MAGENTA := $(if $(NO_COLOR_ENABLED),,\033[1;35m)
BD_CYAN    := $(if $(NO_COLOR_ENABLED),,\033[1;36m)
BD_WHITE   := $(if $(NO_COLOR_ENABLED),,\033[1;37m)

# underline
UL_STD     := $(if $(NO_COLOR_ENABLED),,\033[4m)
UL_BLACK   := $(if $(NO_COLOR_ENABLED),,\033[4;30m)
UL_RED     := $(if $(NO_COLOR_ENABLED),,\033[4;31m)
UL_GREEN   := $(if $(NO_COLOR_ENABLED),,\033[4;32m)
UL_YELLOW  := $(if $(NO_COLOR_ENABLED),,\033[4;33m)
UL_BLUE    := $(if $(NO_COLOR_ENABLED),,\033[4;34m)
UL_MAGENTA := $(if $(NO_COLOR_ENABLED),,\033[4;35m)
UL_CYAN    := $(if $(NO_COLOR_ENABLED),,\033[4;36m)
UL_WHITE   := $(if $(NO_COLOR_ENABLED),,\033[4;37m)
UL_ORANGE  := $(if $(NO_COLOR_ENABLED),,\033[4;38;5;214m)

# italics
IT_STD     := $(if $(NO_COLOR_ENABLED),,\033[3m)
IT_BLACK   := $(if $(NO_COLOR_ENABLED),,\033[3;30m)
IT_RED     := $(if $(NO_COLOR_ENABLED),,\033[3;31m)
IT_GREEN   := $(if $(NO_COLOR_ENABLED),,\033[3;32m)
IT_YELLOW  := $(if $(NO_COLOR_ENABLED),,\033[3;33m)
IT_BLUE    := $(if $(NO_COLOR_ENABLED),,\033[3;34m)
IT_MAGENTA := $(if $(NO_COLOR_ENABLED),,\033[3;35m)
IT_CYAN    := $(if $(NO_COLOR_ENABLED),,\033[3;36m)
IT_WHITE   := $(if $(NO_COLOR_ENABLED),,\033[3;37m)
IT_ORANGE  := $(if $(NO_COLOR_ENABLED),,\033[3;38;5;214m)

# bold and underline
BD_UL_STD     := $(if $(NO_COLOR_ENABLED),,\033[1;4m)
BD_UL_BLACK   := $(if $(NO_COLOR_ENABLED),,\033[1;4;30m)
BD_UL_RED     := $(if $(NO_COLOR_ENABLED),,\033[1;4;31m)
BD_UL_GREEN   := $(if $(NO_COLOR_ENABLED),,\033[1;4;32m)
BD_UL_YELLOW  := $(if $(NO_COLOR_ENABLED),,\033[1;4;33m)
BD_UL_BLUE    := $(if $(NO_COLOR_ENABLED),,\033[1;4;34m)
BD_UL_MAGENTA := $(if $(NO_COLOR_ENABLED),,\033[1;4;35m)
BD_UL_CYAN    := $(if $(NO_COLOR_ENABLED),,\033[1;4;36m)
BD_UL_WHITE   := $(if $(NO_COLOR_ENABLED),,\033[1;4;37m)

# bold and italics
BD_IT_STD     := $(if $(NO_COLOR_ENABLED),,\033[1;3m)
BD_IT_BLACK   := $(if $(NO_COLOR_ENABLED),,\033[1;3;30m)
BD_IT_RED     := $(if $(NO_COLOR_ENABLED),,\033[1;3;31m)
BD_IT_GREEN   := $(if $(NO_COLOR_ENABLED),,\033[1;3;32m)
BD_IT_YELLOW  := $(if $(NO_COLOR_ENABLED),,\033[1;3;33m)
BD_IT_BLUE    := $(if $(NO_COLOR_ENABLED),,\033[1;3;34m)
BD_IT_MAGENTA := $(if $(NO_COLOR_ENABLED),,\033[1;3;35m)
BD_IT_CYAN    := $(if $(NO_COLOR_ENABLED),,\033[1;3;36m)
BD_IT_WHITE   := $(if $(NO_COLOR_ENABLED),,\033[1;3;37m)

# italics and underline
IT_UL_STD     := $(if $(NO_COLOR_ENABLED),,\033[3;4m)
IT_UL_BLACK   := $(if $(NO_COLOR_ENABLED),,\033[3;4;30m)
IT_UL_RED     := $(if $(NO_COLOR_ENABLED),,\033[3;4;31m)
IT_UL_GREEN   := $(if $(NO_COLOR_ENABLED),,\033[3;4;32m)
IT_UL_YELLOW  := $(if $(NO_COLOR_ENABLED),,\033[3;4;33m)
IT_UL_BLUE    := $(if $(NO_COLOR_ENABLED),,\033[3;4;34m)
IT_UL_MAGENTA := $(if $(NO_COLOR_ENABLED),,\033[3;4;35m)
IT_UL_CYAN    := $(if $(NO_COLOR_ENABLED),,\033[3;4;36m)
IT_UL_WHITE   := $(if $(NO_COLOR_ENABLED),,\033[3;4;37m)
IT_UL_ORANGE  := $(if $(NO_COLOR_ENABLED),,\033[3;4;38;5;214m)

# bold, underline, and italics
BD_UL_IT_STD     := $(if $(NO_COLOR_ENABLED),,\033[1;3;4m)
BD_UL_IT_BLACK   := $(if $(NO_COLOR_ENABLED),,\033[1;3;4;30m)
BD_UL_IT_RED     := $(if $(NO_COLOR_ENABLED),,\033[1;3;4;31m)
BD_UL_IT_GREEN   := $(if $(NO_COLOR_ENABLED),,\033[1;3;4;32m)
BD_UL_IT_YELLOW  := $(if $(NO_COLOR_ENABLED),,\033[1;3;4;33m)
BD_UL_IT_BLUE    := $(if $(NO_COLOR_ENABLED),,\033[1;3;4;34m)
BD_UL_IT_MAGENTA := $(if $(NO_COLOR_ENABLED),,\033[1;3;4;35m)
BD_UL_IT_CYAN    := $(if $(NO_COLOR_ENABLED),,\033[1;3;4;36m)
BD_UL_IT_WHITE   := $(if $(NO_COLOR_ENABLED),,\033[1;3;4;37m)

# Reset Macro
# Resets terminal typeface back to default.
R := $(if $(NO_COLOR_ENABLED),,\033[0m)

# Prefix Macro
# When creating a macro , even if it'll be passed to 'echo' later, you _should_ add quotes.
P := "'$(BD_GREEN)'['$(WHITE)'Pyllock'$(BD_GREEN)']'$R'"


## Templates #######################################################################################


define PYPROJECT_TOML
# See: https://packaging.python.org/en/latest/guides/writing-pyproject-toml/
# If any strings are left empty, 'make lock' will fail.
# To debug, run 'pip install .' to emit errors.
[project]

# Package names should follow PEP 423.
name = ""
version = ""
description = ""
authors = [
    {name = "", email = ""},
]
readme = "readme.md"
# For example, ">= 3.11" or "== 3.11".
requires-python = ""
# See: https://pypi.org/classifiers/
classifiers = ["Private :: Do Not Upload"]

dependencies = [

]

[project.optional-dependencies]

dev = [

]

test = [

]

[project.urls]

Repository = ""

# https://pip.pypa.io/en/stable/reference/build-system/pyproject-toml/#fallback-behaviour
[build-system]

requires = ["setuptools", "wheel"]
build-backend = "setuptools.build_meta"

[tool.setuptools]

include-package-data = true

# https://setuptools.pypa.io/en/latest/userguide/package_discovery.html
[tool.setuptools.packages.find]

where = []
include = []
exclude = []
namespaces = true # true by default

# https://github.com/jazzband/pip-tools?tab=readme-ov-file#configuration
#[tool.pip-tools]
#
#index-url = https://example.com
#extra-index-url = https://another-example.com
#dry-run = true
#annotate = true
endef


# All of the spacing is designed to make the help text readable on a 80-column-width console.
define HELP
$(BD_BLUE)#$R $(BD_STD)Pyllock ¯\_(ツ)_/¯$R $(BD_BLUE)#$R

"The Stupid Python Project Manager."

For more details, see $(UL_BLUE)https://github.com/Zoidmania/pyllock$R.

This Makefile manages your Python project's dependencies with minimal tooling.
It creates virtual environments by default (but it doesn't have to). It $(BD_UL_IT_STD)does not$R
activate virtual environments for you! You must activate your virtual environment
with:

    $(BD_IT_WHITE)cd /path/to/project/$(BD_RESET)
    $(BD_IT_WHITE)source venv/bin/activate$(BD_RESET)

$(BD_BLUE)##$R $(BD_STD)Commands$R $(BD_BLUE)##$R

All commands are issued in the following format:

    $(BD_IT_WHITE)make$(BD_RESET) $(BD_GREEN)<command>$R

The following commands are available.

$(BD_GREEN)bootstrap$R
    Within the virtual environment, or in $(IT_ORANGE)PYLLOCK_BASE_PYTHON$R's environment if
    $(IT_ORANGE)PYLLOCK_NO_VENV$R is set, upgrades $(BD_IT_CYAN)pip$R and installs $(BD_IT_CYAN)wheel$R and $(BD_IT_CYAN)pip-tools$R,
    necessary dependencies of $(BD_STD)Pyllock$R. This command $(BD_IT_STD)does not$R recreate the venv
    if one already exists.

$(BD_GREEN)build$R
    Builds a distribution of your Python project, according to $(BD_IT_BLUE)pyproject.toml$R.

$(BD_GREEN)clean$R
    Convenience function for $(BD_GREEN)rm-venv$R and $(BD_GREEN)clean-build$R. $(BD_IT_BLUE)project.toml$R and any
    lock files are left intact.

$(BD_GREEN)clean-build$R
    Deletes any $(BD_IT_BLUE).egg-info$R. Also deletes the project's build artifacts by
    removing the 'dist/' directory.

$(BD_GREEN)help$R
    Prints this help text and exits. Default command.

$(BD_GREEN)init$R
    Alias for $(BD_GREEN)new-project$R.

$(BD_GREEN)install$R
    Alias for $(BD_GREEN)sync$R.

$(BD_GREEN)lock$R
    Creates lock files from the dependencies specified in $(BD_IT_BLUE)project.toml$R.
    Dependencies are $(BD_UL_IT_STD)not$R installed with this command.

$(BD_GREEN)new-project$R
    A convenience function that runs $(BD_GREEN)clean$R, $(BD_GREEN)venv$R, and $(BD_GREEN)pyproject$R in that order.

$(BD_GREEN)pyproject$R
    Generates a $(BD_IT_BLUE)pyproject.toml$R file from the standard template at the root of
    the project.

$(BD_GREEN)refresh$R
    A convenience function that runs $(BD_GREEN)clean$R, $(BD_GREEN)venv$R, and $(BD_GREEN)sync$R, in that order. Use
    to remove all build artifacts, completely rebuild a virtual environment (if
    there is one), and reinstall dependencies from the lock files.

$(BD_GREEN)show$R
    Print evaluated environment variables that $(BD_STD)Pyllock$R is aware of.

$(BD_GREEN)sync$R
    Syncs dependencies from the lock file to the virtual environment if
    $(IT_ORANGE)PYLLOCK_NO_VENV$R isn't set, or to $(IT_ORANGE)PYLLOCK_BASE_PYTHON$R's environment if it is.
    Any new dependencies will be installed, and any removed dependencies will be
    uninstalled.

    By default, $(BD_UL_IT_STD)development$R dependencies are synced. Set $(IT_ORANGE)PYLLOCK_ENV$R to either
    $(BD_STD)'prod'$R, $(BD_STD)'dev'$R, or $(BD_STD)'test'$R to select between the available dependency lists.

$(BD_GREEN)update$R
    A convenience function that runs $(BD_GREEN)venv$R, $(BD_GREEN)lock$R, and $(BD_GREEN)sync$R, in that order.
    Suitable for running after adding, removing, or updating dependencies.

$(BD_GREEN)upgrade-pyllock$R
    Updates the $(BD_STD)Pyllock$R $(BD_IT_BLUE)Makefile$R to the latest release version.

$(BD_GREEN)usage$R
    Prints simple usage text. Default behavior.

$(BD_GREEN)venv$R
    If $(IT_ORANGE)PYLLOCK_NO_VENV$R is set, no virtual environment is created. Instead,
    Pyllock will use $(IT_ORANGE)PYLLOCK_BASE_PYTHON$R's environment directly.

    However, if $(IT_ORANGE)PYLLOCK_NO_VENV$R isn't set (default behavior), this command
    creates a virtual environment at a path relative to $(BD_STD)Pyllock$R $(BD_IT_BLUE)Makefile$R given by
    $(IT_ORANGE)PYLLOCK_VENV_NAME$R (simply $(BD_IT_BLUE)venv$R by default). The virtual environment is made
    using the Python interpreter specified by $(IT_ORANGE)PYLLOCK_BASE_PYTHON$R, on the default
    interpreter on the $(IT_ORANGE)PATH$R if one isn't specified. By default, the venv's prompt
    prefix is the name of the parent directory of the project directory. For
    example, if the $(BD_STD)Pyllock$R $(BD_IT_BLUE)Makefile$R is placed at $(BD_IT_BLUE)~/src/foobar/Makefile$R, the
    virtual environment's prompt prefix will be $(BD_STD)'foobar'$R. The default prefix
    logic can be overridden by setting $(IT_ORANGE)PYLLOCK_VENV_PREFIX$R to an explicit string
    value.

    Regardless of whether a virtual environment is made, $(BD_GREEN)bootstrap$R is called at
    the end of this command to ensure required tools are installed.

$(BD_BLUE)##$R $(BD_STD)Pyllock Settings$R $(BD_BLUE)##$R

By default, $(BD_STD)Pyllock$R searches for the default Python interpreter on $(IT_ORANGE)$$PATH$R given
by $(BD_STD)/usr/bin/env python3$R. This interpreter is used to create virtual environments
by calling $(BD_IT_WHITE)python -m venv$R, or if $(IT_ORANGE)PYLLOCK_NO_VENV$R is set, $(BD_STD)Pyllock$R will attempt to
install and manage dependencies in the interpreter's environment $(IT_STD)directly$R.

Optionally, you may instead choose a Python interpreter by setting the
environment variable $(IT_ORANGE)PYLLOCK_BASE_PYTHON$R to the your interpreter of choice.

$(BD_BLUE)###$R $(BD_STD)Configuring Environment Variables$R $(BD_BLUE)###$R

Environment variables can be set in a few places, $(IT_UL_STD)in order of descreasing
precedence$R:

* In a file at the path specified by $(IT_ORANGE)PYLLOCK_ENV_FILE$R.
    * If this variable isn't set, its value defaults to $(BD_UL_IT_BLUE).env$R, representing a
      file next to the $(BD_STD)Pyllock$R Makefile.
    * Paths are relative to the Makefile.
* Inline with your calls (i.e., '$(BD_IT_WHITE)NO_COLOR=1 make help$R')
* Persistently for your shell (i.e., in $(BD_IT_BLUE)~/.bashrc$R for Bash)

You can view setting values Pyllock has determined with:

    $(BD_IT_WHITE)make show$R

$(BD_BLUE)##$R $(BD_STD)Getting Started$R $(BD_BLUE)##$R

To start managing a new project, simply run the following and begin tracking
your dependencies in the generated $(BD_IT_BLUE)project.toml$R.

    $(BD_IT_WHITE)make new-project$R

To start managing an existing project, place the $(BD_STD)Pyllock$R $(BD_IT_BLUE)Makefile$R at the root of
the project.

You $(BD_UL_IT_STD)must$R specify your project's dependencies according to $(BD_MAGENTA)PEP 621$R. Additional
development dependencies should be specified in a list called $(BD_MAGENTA)dev$R in the
$(BD_MAGENTA)[project.optional-dependencies]$R section.

$(BD_BLUE)##$R $(BD_STD)Extra Functions$R $(BD_BLUE)##$R

To add extra functions, create the file $(BD_IT_BLUE)pylk-extras.mk$R next to this $(BD_IT_BLUE)Makefile$R. It
will automatically be imported $(IT_STD)after$R the default targets, giving you the ability
to override them.

$(BD_BLUE)##$R $(BD_STD)Disabling Colors in Output$R $(BD_BLUE)##$R

Set the environment variable $(IT_ORANGE)NO_COLOR=1$R to disable colored output.

endef


define USAGE
Pyllock

"The stupid Python project manager."

  Usage: make <command>

Available commands:

endef


# Detects whether prod dependencies are defined
define PROD_DEPS_ARE_DEFINED
import tomllib
import sys

with open("pyproject.toml", "rb") as f:
    ppt = tomllib.load(f)

sys.exit(0 if "dependencies" in ppt["project"] else 1)
endef


# Detects whether dev dependencies are defined (optional)
define DEV_DEPS_ARE_DEFINED
import tomllib
import sys

with open("pyproject.toml", "rb") as f:
    ppt = tomllib.load(f)

defined = "optional-dependencies" in ppt["project"] and \
    "dev" in ppt["project"]["optional-dependencies"].keys()

sys.exit(0 if defined else 1)
endef


# Detects whether dev dependencies are defined (optional)
define TEST_DEPS_ARE_DEFINED
import tomllib
import sys

with open("pyproject.toml", "rb") as f:
	ppt = tomllib.load(f)

defined = "optional-dependencies" in ppt["project"] and \
	"test" in ppt["project"]["optional-dependencies"].keys()

sys.exit(0 if defined else 1)
endef


# Export to variable for shell execution. This way, leading whitespace is preserved.
# See: https://stackoverflow.com/a/7287289
export PYPROJECT_TOML
export HELP
export USAGE
export PROD_DEPS_ARE_DEFINED
export DEV_DEPS_ARE_DEFINED
export TEST_DEPS_ARE_DEFINED


## Targets #########################################################################################


.PHONY: bootstrap # Update pip and install pip-tools.
bootstrap:
	@echo "$P $(BD_WHITE)Upgrading pip...$R"
	@$(INTERPRETER) -m pip install --upgrade pip

	@echo "$P $(BD_WHITE)Installing/upgrading pip-tools and wheel...$R"
	@$(INTERPRETER) -m pip install --upgrade "pip-tools$(PYLLOCK_PIPTOOLS_VERSION)" wheel setuptools


.PHONY: build # Build the Python application.
build:
	@echo "$P $(BD_WHITE)Building package distribution...$R"
	@$(INTERPRETER) -m build


.PHONY: clean # Remove venv, egg-info, and dist.
clean: rm-venv clean-build


.PHONY: clean-build # Remove egg-info and dist.
clean-build:
	@echo "$P $(BD_YELLOW)Removing project's egg-info...$R"
	@find $(BASEDIR) -type d -name '*.egg-info' -exec rm -rf {} +

	@echo "$P $(BD_YELLOW)Removing dist builds...$R"
	@if [ -d $(BASEDIR)/dist ]; then \
		rm -rf $(BASEDIR)/dist; \
	fi


.PHONY: help # Print verbose help.
help:
	@echo "$$HELP"


.PHONY: init # Alias for new-project.
init: new-project


.PHONY: install # Alias for sync.
install: sync


.PHONY: lock # Create prod and dev lockfiles from pyproject.toml.
lock:
	@$(shell mkdir -p $(PYLLOCK_LOCK_DIR))

	@if $(INTERPRETER) -c "$$PROD_DEPS_ARE_DEFINED"; then \
		echo "$P $(BD_WHITE)Locking main dependencies...$R"; \
		$(INTERPRETER) -m piptools compile -q --upgrade --resolver backtracking --no-strip-extras \
			-o $(PYLLOCK_LOCK_DIR)/main $(BASEDIR)/pyproject.toml; \
	else \
		echo "$P $(BD_RED)No base dependencies defined in$R $(BD_IT_BLUE)$(BASEDIR)/pyproject.toml$R$(BD_RED)! Aborting!$R"; \
		exit; \
	fi

	@if $(INTERPRETER) -c "$$DEV_DEPS_ARE_DEFINED"; then \
		echo "$P $(BD_WHITE)Locking dev dependencies...$R"; \
		$(INTERPRETER) -m piptools compile -q --extra dev --upgrade --resolver backtracking --no-strip-extras \
			-o $(PYLLOCK_LOCK_DIR)/dev $(BASEDIR)/pyproject.toml; \
	else \
		echo "$P $(BD_YELLOW)No dev dependencies defined in$R $(BD_IT_BLUE)$(BASEDIR)/pyproject.toml$R$(BD_YELLOW)! Skipping!$R"; \
	fi

	@if $(INTERPRETER) -c "$$TEST_DEPS_ARE_DEFINED"; then \
		echo "$P $(BD_WHITE)Locking test dependencies...$R"; \
		$(INTERPRETER) -m piptools compile -q --extra test --upgrade --resolver backtracking --no-strip-extras \
			-o $(PYLLOCK_LOCK_DIR)/test $(BASEDIR)/pyproject.toml; \
	else \
		echo "$P $(BD_YELLOW)No test dependencies defined in$R $(BD_IT_BLUE)$(BASEDIR)/pyproject.toml$R$(BD_YELLOW)! Skipping!$R"; \
	fi


.PHONY: new-project # Create venv and a boilerplate pyproject.toml file.
new-project: clean venv pyproject


.PHONY: pyproject # Create a boilerplate pyproject.toml file.
pyproject:
	@if [ ! -f $(BASEDIR)/pyproject.toml ]; then \
		echo "$$PYPROJECT_TOML" > $(BASEDIR)/pyproject.toml; \
		echo "$P Created $(BD_IT_BLUE)project.toml$R file in project root from template."; \
	else \
		echo "$P $(BD_IT_BLUE)project.toml$R $(BD_RED)already exists!$R $(BD_YELLOW)Skipping creating from template!$R"; \
	fi
	@echo "$P $(BD_YELLOW)Edit your$R $(BD_IT_BLUE)project.toml$R $(BD_YELLOW)metadata and dependencies before locking!$R"


.PHONY: refresh # Remove build dist and egg-info, recreate venv, and sync lock into it.
refresh: clean venv sync


.PHONY: rm-venv # Remove venv.
rm-venv:
	@if [ "$(PYLLOCK_NO_VENV)" = 1 ]; then \
		echo "$P $(BD_YELLOW)Virtual environment usage disabled because$R $(IT_ORANGE)PYLLOCK_NO_VENV$R $(BD_YELLOW)is set!$R"; \
	else \
		echo "$P $(BD_YELLOW)Removing virtual environment...$R"; \
		rm -rf $(BASEDIR)/$(PYLLOCK_VENV_NAME); \
	fi


.PHONY: show # Print evaluated environment variables that Pyllock is aware of.
show:
	@echo "PYLLOCK_ENV=$(PYLLOCK_ENV)"
	@echo "PYLLOCK_ENV_FILE=$(PYLLOCK_ENV_FILE)"
	@echo "PYLLOCK_BASE_PYTHON=$(PYLLOCK_BASE_PYTHON)"
	@echo "PYLLOCK_NO_VENV=$(PYLLOCK_NO_VENV)"
	@echo "PYLLOCK_VENV_NAME=$(PYLLOCK_VENV_NAME)"
	@echo "PYLLOCK_VENV_PREFIX=$(PYLLOCK_VENV_PREFIX)"
	@echo "PYLLOCK_LOCK_DIR=$(PYLLOCK_LOCK_DIR)"
	@echo "PYLLOCK_PIPTOOLS_VERSION=$(PYLLOCK_PIPTOOLS_VERSION)"
	@echo "NO_COLOR=$(NO_COLOR)"


.PHONY: sync # Sync venv with lockfile. Removes non-defined dependencies.
sync:
	@if [ "$(PYLLOCK_NO_VENV)" = 1 ]; then \
		echo "$P $(BD_YELLOW)Virtual environment usage disabled because$R $(IT_ORANGE)PYLLOCK_NO_VENV$R $(BD_YELLOW)is set!$R"; \
		echo "$P $(BD_YELLOW)Using environment of interpreter $R $(BD_IT_BLUE)$(INTERPRETER)$R $(BD_YELLOW)directly!$R"; \
	fi
	@if [ "$(PYLLOCK_ENV)" = "production" ] || [ "$(PYLLOCK_ENV)" = "prod" ]; then \
		echo "$P $(BD_WHITE)Syncing prod dependencies...$R"; \
		if [ -f $(PYLLOCK_LOCK_DIR)/main ]; then \
			$(INTERPRETER) -m piptools sync --pip-args "-e ." $(PYLLOCK_LOCK_DIR)/main; \
			$(INTERPRETER) -m pip check; \
		else \
			echo "$P $(BD_RED)No lockfile found at$R $(BD_IT_BLUE)$(BASEDIR)/main$R$(BD_RED)! Aborting!$R"; \
		fi; \
	elif [ "$(PYLLOCK_ENV)" = "development" ] || [ "$(PYLLOCK_ENV)" = "dev" ]; then \
		echo "$P $(BD_WHITE)Syncing dev dependencies...$R"; \
		if [ -f $(PYLLOCK_LOCK_DIR)/dev ]; then \
			$(INTERPRETER) -m piptools sync --pip-args "-e ." $(PYLLOCK_LOCK_DIR)/dev; \
			$(INTERPRETER) -m pip check; \
		else \
			echo "$P $(BD_RED)No lockfile found at$R $(BD_IT_BLUE)$(BASEDIR)/dev$R$(BD_RED)! Aborting!$R"; \
		fi; \
	elif [ "$(PYLLOCK_ENV)" = "testing" ] || [ "$(PYLLOCK_ENV)" = "test" ]; then \
		echo "$P $(BD_WHITE)Syncing test dependencies...$R"; \
		if [ -f $(PYLLOCK_LOCK_DIR)/dev ]; then \
			$(INTERPRETER) -m piptools sync --pip-args "-e ." $(PYLLOCK_LOCK_DIR)/test; \
			$(INTERPRETER) -m pip check; \
		else \
			echo "$P $(BD_RED)No lockfile found at$R $(BD_IT_BLUE)$(BASEDIR)/test$R$(BD_RED)! Aborting!$R"; \
		fi; \
	else \
		echo "$P $(BD_RED)Bad value for$R $(IT_ORANGE)PYLLOCK_ENV$R: $(PYLLOCK_ENV)"; \
	fi


.PHONY: update # Create or update a venv, compute lock files to latest versions, and sync dependencies.
update: venv lock sync


.PHONY: upgrade-pyllock # Pull the latest version of Pyllock.
upgrade-pyllock:
	@echo "$P $(BD_WHITE)Upgrading Pyllock to latest release...$R"
	@$(eval LATEST=$(shell curl -s https://api.github.com/repos/Zoidmania/pyllock/releases/latest | grep -i "tag_name" | awk -F '"' '{print $$4}'))
	@curl -s -o $(BASEDIR)/Makefile https://raw.githubusercontent.com/Zoidmania/pyllock/$(LATEST)/Makefile


# Using "$$" syntax instead of "$()" syntax to reference an exported variable leaves rendering to
# the shell, rather than doing a literal string replace. The "echo" command preserves leading
# whitespace when *it* renders a variable in double-quotes, but does not when GNU Make renders the
# variable because GNU Make presents it to echo as a string literal instead of a variable.
.PHONY: usage # Print basic usage.
usage:
	@echo "$$USAGE"
	@grep -vE '^[[:space:]]' $(MAKEFILE_LIST) | grep -E '^.*:.* #' | sed -E 's/.PHONY:(.*):.*#(.*)/  \1###\2/' | sed -E 's/.PHONY: //g' | column -t -s '###'

# We need to grab the Python interpreter on $$PATH to create the venv first, so don't use
# $$(INTERPRETER) here.
.PHONY: venv # Create or update a venv.
venv:
	@if [ "$(PYLLOCK_NO_VENV)" = 1 ]; then \
		echo "$P $(BD_YELLOW)Virtual environment usage disabled because$R $(IT_ORANGE)PYLLOCK_NO_VENV$R $(BD_YELLOW)is set!$R"; \
		echo "$P $(BD_YELLOW)Using environment of interpreter $R $(BD_IT_BLUE)$(INTERPRETER)$R $(BD_YELLOW)directly!$R"; \
	elif [ ! -d $(BASEDIR)/$(PYLLOCK_VENV_NAME) ]; then \
		echo "$P $(BD_WHITE)Creating virtual environment...$R"; \
		$(PYLLOCK_BASE_PYTHON) -m venv $(BASEDIR)/$(PYLLOCK_VENV_NAME) --prompt=$(PYLLOCK_VENV_PREFIX); \
	fi

	$(MAKE) bootstrap --no-print-directory


# Include extra functions for this project, if they exist.
# See: https://www.gnu.org/software/make/manual/html_node/Include.html
-include pylk-extras.mk
