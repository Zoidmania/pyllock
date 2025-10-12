#################
# Pyllock Makefile
# v0.9.0
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

## Preflight Checks

# If OS is Windows, exits with error.
ifeq ($(OS),Windows_NT)
	$(error Pyllock does not support Windows.)
endif

## Configs

# For performance reasons and to make intermediate env vars "persistent", we use one subshell.
# See: https://www.gnu.org/software/make/manual/html_node/One-Shell.html
.ONESHELL:

# Force serial execution. All of these recipes are intended to run serially; parallel execution
# could fail.
# See: https://www.gnu.org/software/make/manual/html_node/Parallel-Disable.html
.NOTPARALLEL:

# Set a default target. In this case, print simple usage.
.DEFAULT_GOAL := usage

## Directory and Env Helpers

BASEDIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
REQS := $(BASEDIR)/lock

# By default GNU make loads what is already in `env`. This extends that behavior to other files.
PYLLOCK_ENV_FILE ?= .env
ifneq ("$(wildcard $(PYLLOCK_ENV_FILE))","")
    $(eval include $(PYLLOCK_ENV_FILE))
endif

PYLLOCK_PYTHON ?= /usr/bin/env python3
PYLLOCK_NO_VENV ?= 0
PYLLOCK_VENV_PREFIX ?= "$(shell basename $(BASEDIR))"
PYLLOCK_ENV ?= dev
INTERPRETER := $(BASEDIR)/venv/bin/python

# Pin the pip-tools version range so this Makefile can predict its behavior. Pip follows version
# specifiers outlined in PEP440, even inline on the CLI. Note that, if a range is specified like
# this, it must be surrounded with quotes.
PIPTOOLS_VERSION ?= >=7.5.1,<8

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

RESET := $(if $(NO_COLOR_ENABLED),,\033[0m)

# Prefix Macro
# When creating a macro , even if it'll be passed to 'echo' later, you _should_ add quotes.
P := "'$(BD_GREEN)'['$(WHITE)'Pyllock'$(BD_GREEN)']'$(RESET)'"

## Templates

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
$(BD_BLUE)#$(RESET) $(BD_STD)Pyllock ¯\_(ツ)_/¯$(RESET) $(BD_BLUE)#$(RESET)

"The Stupid Python Project Manager."

For more details, see $(UL_BLUE)https://github.com/Zoidmania/pyllock$(RESET).

This Makefile manages your Python project's dependencies with minimal tooling.
It creates virtual environments by default (but it doesn't have to). It $(BD_UL_IT_STD)does not$(RESET)
activate virtual environments for you! You must activate your virtual environment with:

    $(BD_IT_WHITE)cd /path/to/project/$(BD_RESET)
    $(BD_IT_WHITE)source venv/bin/activate$(BD_RESET)

$(BD_BLUE)##$(RESET) $(BD_STD)Commands$(RESET) $(BD_BLUE)##$(RESET)

All commands are issued in the following format:

    $(BD_IT_WHITE)make$(BD_RESET) $(BD_GREEN)<command>$(RESET)

The following commands are available.

$(BD_GREEN)build$(RESET)
    Builds a distribution of your Python project, according to $(BD_IT_BLUE)pyproject.toml$(RESET).

$(BD_GREEN)clean$(RESET)
    Deletes the project's virtual environment, any $(BD_IT_BLUE).egg-info$(RESET) metadata, and
    build artifacts.

$(BD_GREEN)clean-build$(RESET)
    Deletes any $(BD_IT_BLUE).egg-info$(RESET)'s, as well as the project's build artifacts by
    removing the 'dist/' directory.

$(BD_GREEN)help$(RESET)
    Prints this help text and exits. Default command.

$(BD_GREEN)init$(RESET)
    A convenience function that runs $(BD_GREEN)venv$(RESET) and $(BD_GREEN)pyproject$(RESET) in that order.

$(BD_GREEN)install$(RESET)
    Alias for $(BD_GREEN)sync$(RESET).

$(BD_GREEN)lock$(RESET)
    Creates lock files from the dependencies specified in $(BD_IT_BLUE)project.toml$(RESET).
    Dependencies are $(BD_UL_IT_STD)not$(RESET) installed with this command.

$(BD_GREEN)pyproject$(RESET)
    Generates a $(BD_IT_BLUE)pyproject.toml$(RESET) file from the standard template at the root of
    the project.

$(BD_GREEN)refresh$(RESET)
    A convenience function that runs $(BD_GREEN)clean$(RESET), $(BD_GREEN)venv$(RESET), and $(BD_GREEN)sync$(RESET), in that order. Use
    to completely rebuild a virtual environment.

$(BD_GREEN)show-env$(RESET)
    Print evaluated environment variables that $(BD_STD)Pyllock$(RESET) is aware of.

$(BD_GREEN)sync$(RESET)
    Syncs dependencies from the lock file to the virtual environment. Any new
    dependencies will be installed, and any removed dependencies will be
    uninstalled.

    By default, $(BD_UL_IT_STD)development$(RESET) dependencies are synced. Set $(IT_ORANGE)PYLLOCK_ENV$(RESET) to either
    $(BD_STD)'main'$(RESET) or $(BD_STD)'dev'$(RESET) to select between the two available dependency lists.

$(BD_GREEN)update$(RESET)
    A convenience function that runs $(BD_GREEN)venv$(RESET), $(BD_GREEN)lock$(RESET), and $(BD_GREEN)sync$(RESET), in that order.
    Suitable for running after adding, removing, or updating dependencies.

$(BD_GREEN)upgrade-pyllock$(RESET)
    Updates $(BD_STD)Pyllock$(RESET) to the latest release version.

$(BD_GREEN)usage$(RESET)
    Prints simple usage text. Default behavior.

$(BD_GREEN)venv$(RESET)
    Creates a virtual environment at the root of the project, using the Python
    interpreter specified by $(IT_ORANGE)PYLLOCK_PYTHON$(RESET), or the default interpreter on the
    $(IT_ORANGE)PATH$(RESET). Also upgrades $(BD_IT_CYAN)pip$(RESET) and installs $(BD_IT_CYAN)wheel$(RESET) and $(BD_IT_CYAN)pip-tools$(RESET), necessary
    dependencies of $(BD_STD)Pyllock$(RESET). This command $(BD_IT_STD)does not$(RESET) recreate the venv if one
    already exists.

    By default, the venv's prefix is the name of the parent directory of the
    project directory. This can be overridden by setting $(IT_ORANGE)PYLLOCK_VENV_PREFIX$(RESET).

$(BD_BLUE)##$(RESET) $(BD_STD)Getting Started$(RESET) $(BD_BLUE)##$(RESET)

You $(BD_UL_IT_STD)must$(RESET) choose a Python interpreter to use for initializing the virtual
environment (venv). Set the environment variable $(IT_ORANGE)PYLLOCK_PYTHON$(RESET) to the your
interpreter of choice, otherwise the default Python interpreter on $(IT_ORANGE)PATH$(RESET) is used.
The interpreter specified with this variable is $(BD_UL_STD)only used to create the venv$(RESET).

To get started, place the $(BD_STD)Pyllock$(RESET) $(BD_IT_BLUE)Makefile$(RESET) in the root of your project. Then,
$(BD_UL_IT_STD)remove any existing venvs from your project$(RESET).

To start managing a project, simply run the following and begin tracking your
dependencies in the generated $(BD_IT_BLUE)project.toml$(RESET).

    $(BD_IT_WHITE)make init$(RESET)

You $(BD_UL_IT_STD)must$(RESET) specify your project's dependencies according to $(BD_MAGENTA)PEP 621$(RESET). Additional
development dependencies should be specified in a list called $(BD_MAGENTA)dev$(RESET) in the
$(BD_MAGENTA)[project.optional-dependencies]$(RESET) section.

$(BD_BLUE)##$(RESET) $(BD_STD)Configuring Environment Variables$(RESET) $(BD_BLUE)##$(RESET)

You can set your environment variables in a few places, $(IT_UL_STD)in order of descreasing
precedence$(RESET):

* In a file at the path specified by $(IT_ORANGE)PYLLOCK_ENV_FILE$(RESET).
    * If this variable isn't set, its value defaults to $(BD_UL_IT_BLUE).env$(RESET), representing a
      file next to the $(BD_STD)Pyllock$(RESET) Makefile.
    * Paths are relative to the Makefile.
* Inline with your calls (i.e., '$(BD_IT_WHITE)NO_COLOR=1 make help$(RESET)')
* Persistently for your shell (i.e., in $(BD_IT_BLUE)~/.bashrc$(RESET) for Bash)

You can specify any environment variable $(BD_STD)Pyllock$(RESET) uses can be set in a file,
either the default of $(BD_IT_BLUE).env$(RESET) or a file given at $(IT_ORANGE)PYLLOCK_ENV_FILE$(RESET). You cam view
these values with:

    $(BD_IT_WHITE)make show-env$(RESET)

$(BD_BLUE)##$(RESET) $(BD_STD)Extra Functions$(RESET) $(BD_BLUE)##$(RESET)

To add extra functions, create the file $(BD_IT_BLUE)pylk-extras.mk$(RESET) next to this Makefile. It
will automatically be imported $(IT_STD)after$(RESET) the default targets, giving you the
ability to override them.

$(BD_BLUE)##$(RESET) $(BD_STD)Disabling Colors in Output$(RESET) $(BD_BLUE)##$(RESET)

Set the environment variable $(IT_ORANGE)NO_COLOR=1$(RESET) to disable colored output.
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

## Targets

.PHONY: build # Build the Python application.
build:
	@echo "$P $(BD_WHITE)Building package distribution...$(RESET)"
	@$(INTERPRETER) -m build

.PHONY: clean # Remove venv, egg-info, and dist.
clean: rm-venv clean-build

.PHONY: clean-build # Remove egg-info and dist.
clean-build:
	@echo "$P $(BD_YELLOW)Removing project's egg-info...$(RESET)"
	@find $(BASEDIR) -type d -name '*.egg-info' -exec rm -rf {} +

	@echo "$P $(BD_YELLOW)Removing dist builds...$(RESET)"
	@if [ -d $(BASEDIR)/dist ]; then \
		rm -rf $(BASEDIR)/dist; \
	fi

.PHONY: help # Print verbose help.
help:
	@echo "$$HELP"

.PHONY: init # Create venv and a boilerplate pyproject.toml file.
init: venv pyproject

.PHONY: install # Alias for sync.
install: sync

.PHONY: lock # Create prod and dev lockfiles from pyproject.toml.
lock:
	@$(shell mkdir -p $(REQS))

	@if $(INTERPRETER) -c "$$PROD_DEPS_ARE_DEFINED"; then \
		echo "$P $(BD_WHITE)Locking main dependencies...$(RESET)"; \
		$(INTERPRETER) -m piptools compile -q --upgrade --resolver backtracking --no-strip-extras \
			-o $(REQS)/main $(BASEDIR)/pyproject.toml; \
	else \
		echo "$P $(BD_RED)No base dependencies defined in$(RESET) $(BD_IT_BLUE)$(BASEDIR)/pyproject.toml$(RESET)$(BD_RED)! Aborting!$(RESET)"; \
		exit; \
	fi

	@if $(INTERPRETER) -c "$$DEV_DEPS_ARE_DEFINED"; then \
		echo "$P $(BD_WHITE)Locking dev dependencies...$(RESET)"; \
		$(INTERPRETER) -m piptools compile -q --extra dev --upgrade --resolver backtracking --no-strip-extras \
			-o $(REQS)/dev $(BASEDIR)/pyproject.toml; \
	else \
		echo "$P $(BD_YELLOW)No dev dependencies defined in$(RESET) $(BD_IT_BLUE)$(BASEDIR)/pyproject.toml$(RESET)$(BD_YELLOW)! Skipping!$(RESET)"; \
	fi

	@if $(INTERPRETER) -c "$$TEST_DEPS_ARE_DEFINED"; then \
		echo "$P $(BD_WHITE)Locking test dependencies...$(RESET)"; \
		$(INTERPRETER) -m piptools compile -q --extra test --upgrade --resolver backtracking --no-strip-extras \
			-o $(REQS)/test $(BASEDIR)/pyproject.toml; \
	else \
		echo "$P $(BD_YELLOW)No test dependencies defined in$(RESET) $(BD_IT_BLUE)$(BASEDIR)/pyproject.toml$(RESET)$(BD_YELLOW)! Skipping!$(RESET)"; \
	fi

.PHONY: pyproject # Create a boilerplate pyproject.toml file.
pyproject:
	@if [ ! -f $(BASEDIR)/pyproject.toml ]; then \
		echo "$$PYPROJECT_TOML" > $(BASEDIR)/pyproject.toml; \
		echo "$P Created $(BD_IT_BLUE)project.toml$(RESET) file in project root from template."; \
	else \
		echo "$P $(BD_IT_BLUE)project.toml$(RESET) $(BD_RED)already exists!$(RESET) $(BD_YELLOW)Skipping creating from template!$(RESET)"; \
	fi
	@echo "$P $(BD_YELLOW)Edit your$(RESET) $(BD_IT_BLUE)project.toml$(RESET) $(BD_YELLOW)metadata and dependencies before locking!$(RESET)"

.PHONY: refresh # Remove build dist and egg-info, recreate venv, and sync lock into it.
refresh: clean venv sync

.PHONY: rm-venv # Remove venv.
rm-venv:
	@echo "$P $(BD_YELLOW)Removing virtual environment...$(RESET)"
	@rm -rf $(BASEDIR)/venv

.PHONY: show-env # Print evaluated environment variables that Pyllock is aware of.
show-env:
	@echo "PYLLOCK_ENV_FILE=$(PYLLOCK_ENV_FILE)"
	@echo "PYLLOCK_ENV=$(PYLLOCK_ENV)"
	@echo "PYLLOCK_PYTHON=$(PYLLOCK_PYTHON)"
	@echo "PYLLOCK_VENV_PREFIX=$(PYLLOCK_VENV_PREFIX)"
	@echo "PIPTOOLS_VERSION=$(PIPTOOLS_VERSION)"
	@echo "NO_COLOR=$(NO_COLOR)"

.PHONY: sync # Sync venv with lockfile. Removes non-defined dependencies.
sync:
	@if [ "$(PYLLOCK_ENV)" = "production" ] || [ "$(PYLLOCK_ENV)" = "prod" ]; then \
		echo "$P $(BD_WHITE)Syncing prod dependencies to venv...$(RESET)"; \
        if [ -f $(REQS)/main ]; then \
			$(INTERPRETER) -m piptools sync --pip-args "-e ." $(REQS)/main; \
			$(INTERPRETER) -m pip check; \
        else \
            echo "$P $(BD_RED)No lockfile found at$(RESET) $(BD_IT_BLUE)$(BASEDIR)/main$(RESET)$(BD_RED)! Aborting!$(RESET)"; \
		fi; \
	elif [ "$(PYLLOCK_ENV)" = "development" ] || [ "$(PYLLOCK_ENV)" = "dev" ]; then \
		echo "$P $(BD_WHITE)Syncing dev dependencies to venv...$(RESET)"; \
        if [ -f $(REQS)/dev ]; then \
			$(INTERPRETER) -m piptools sync --pip-args "-e ." $(REQS)/dev; \
			$(INTERPRETER) -m pip check; \
        else \
            echo "$P $(BD_RED)No lockfile found at$(RESET) $(BD_IT_BLUE)$(BASEDIR)/dev$(RESET)$(BD_RED)! Aborting!$(RESET)"; \
		fi; \
	elif [ "$(PYLLOCK_ENV)" = "testing" ] || [ "$(PYLLOCK_ENV)" = "test" ]; then \
		echo "$P $(BD_WHITE)Syncing test dependencies to venv...$(RESET)"; \
        if [ -f $(REQS)/dev ]; then \
			$(INTERPRETER) -m piptools sync --pip-args "-e ." $(REQS)/test; \
			$(INTERPRETER) -m pip check; \
		else \
            echo "$P $(BD_RED)No lockfile found at$(RESET) $(BD_IT_BLUE)$(BASEDIR)/test$(RESET)$(BD_RED)! Aborting!$(RESET)"; \
        fi; \
	else \
		echo "$P $(BD_RED)Bad value for$(RESET) $(IT_ORANGE)PYLLOCK_ENV$(RESET): $(PYLLOCK_ENV)"; \
	fi

.PHONY: update # Create or update a venv, compute lock files to latest versions, and sync dependencies.
update: venv lock sync

.PHONY: upgrade-pyllock # Pull the latest version of Pyllock.
upgrade-pyllock:
	@echo "$P $(BD_WHITE)Upgrading Pyllock to latest release...$(RESET)"
	@$(eval LATEST=$(shell curl -s https://api.github.com/repos/Zoidmania/pyllock/releases/latest | grep -i "tag_name" | awk -F '"' '{print $$4}'))
	@curl -s -o $(BASEDIR)/Makefile https://raw.githubusercontent.com/Zoidmania/pyllock/$(LATEST)/Makefile

# Using "$$" syntax instead of "$()" syntax to reference an exported variable leaves rendering to
# the shell, rather than doing a literal string replace. The "echo" command preserves leading
# whitespace when *it* renders a variable in double-quotes, but does not when GNU Make renders the
# variable because GNU Make presents it to echo as a string literal instead of a variable.
.PHONY: usage
usage:
	@echo "$$USAGE"
	@grep -vE '^[[:space:]]' $(MAKEFILE_LIST) | grep -E '^.*:.* #' | sed -E 's/.PHONY:(.*):.*#(.*)/  \1###\2/' | sed -E 's/.PHONY: //g' | column -t -s '###'

.PHONY: venv # Create or update a venv.
venv:
	@# We need to grab the Python interpreter on $$PATH to create the venv first, so don't use
	@# $$(INTERPRETER) here.
	@if [ ! -d $(BASEDIR)/venv ]; then \
		echo "$P $(BD_WHITE)Creating virtual environment...$(RESET)"; \
		$(PYLLOCK_PYTHON) -m venv $(BASEDIR)/venv --prompt=$(PYLLOCK_VENV_PREFIX); \
	fi

	@echo "$P $(BD_WHITE)Upgrading pip...$(RESET)"
	@$(INTERPRETER) -m pip install --upgrade pip

	@echo "$P $(BD_WHITE)Installing/upgrading pip-tools and wheel...$(RESET)"
	@$(INTERPRETER) -m pip install --upgrade "pip-tools$(PIPTOOLS_VERSION)" wheel setuptools


# Include extra functions for this project, if they exist.
# See: https://www.gnu.org/software/make/manual/html_node/Include.html
-include pylk-extras.mk
