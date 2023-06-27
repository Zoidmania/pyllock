#################
# Baka Makefile
# v0.3.3
#
# For more details, see https://github.com/Zoidmania/baka.
#
# MIT License
#
# Copyright (c) 2023 Leland Vakarian
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

## Configs

# For performance reasons, we do this in one subshell.
# See: https://www.gnu.org/software/make/manual/html_node/One-Shell.html
.ONESHELL:

# Set a default target. In this case, print help text.
.DEFAULT_GOAL := help

## ANSI Escapes
# All high-intensity colors aren't boldable. The only high-intensity color used here is Orange.
# For more info, see https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit.
#
# NB: When passing to 'echo', you shouldn't add quotes.

BLACK   := \033[0;30m
RED     := \033[0;31m
GREEN   := \033[0;32m
YELLOW  := \033[0;33m
BLUE    := \033[0;34m
MAGENTA := \033[0;35m
CYAN    := \033[0;36m
WHITE   := \033[0;37m
ORANGE  := \033[38;5;214m

# bold
BD_STD     := \033[1m
BD_BLACK   := \033[1;30m
BD_RED     := \033[1;31m
BD_GREEN   := \033[1;32m
BD_YELLOW  := \033[1;33m
BD_BLUE    := \033[1;34m
BD_MAGENTA := \033[1;35m
BD_CYAN    := \033[1;36m
BD_WHITE   := \033[1;37m

# underline
UL_STD     := \033[4m
UL_BLACK   := \033[4;30m
UL_RED     := \033[4;31m
UL_GREEN   := \033[4;32m
UL_YELLOW  := \033[4;33m
UL_BLUE    := \033[4;34m
UL_MAGENTA := \033[4;35m
UL_CYAN    := \033[4;36m
UL_WHITE   := \033[4;37m
UL_ORANGE  := \033[4;38;5;214m

# italics
IT_STD     := \033[3m
IT_BLACK   := \033[3;30m
IT_RED     := \033[3;31m
IT_GREEN   := \033[3;32m
IT_YELLOW  := \033[3;33m
IT_BLUE    := \033[3;34m
IT_MAGENTA := \033[3;35m
IT_CYAN    := \033[3;36m
IT_WHITE   := \033[3;37m
IT_ORANGE  := \033[3;38;5;214m

# bold and underline
BD_UL_STD     := \033[1;4m
BD_UL_BLACK   := \033[1;4;30m
BD_UL_RED     := \033[1;4;31m
BD_UL_GREEN   := \033[1;4;32m
BD_UL_YELLOW  := \033[1;4;33m
BD_UL_BLUE    := \033[1;4;34m
BD_UL_MAGENTA := \033[1;4;35m
BD_UL_CYAN    := \033[1;4;36m
BD_UL_WHITE   := \033[1;4;37m

# bold and italics
BD_IT_STD     := \033[1;3m
BD_IT_BLACK   := \033[1;3;30m
BD_IT_RED     := \033[1;3;31m
BD_IT_GREEN   := \033[1;3;32m
BD_IT_YELLOW  := \033[1;3;33m
BD_IT_BLUE    := \033[1;3;34m
BD_IT_MAGENTA := \033[1;3;35m
BD_IT_CYAN    := \033[1;3;36m
BD_IT_WHITE   := \033[1;3;37m

# italics and underline
IT_UL_STD     := \033[3;4m
IT_UL_BLACK   := \033[3;4;30m
IT_UL_RED     := \033[3;4;31m
IT_UL_GREEN   := \033[3;4;32m
IT_UL_YELLOW  := \033[3;4;33m
IT_UL_BLUE    := \033[3;4;34m
IT_UL_MAGENTA := \033[3;4;35m
IT_UL_CYAN    := \033[3;4;36m
IT_UL_WHITE   := \033[3;4;37m
IT_UL_ORANGE  := \033[3;4;38;5;214m

# bold, underline, and italics
BD_UL_IT_STD     := \033[1;3;4m
BD_UL_IT_BLACK   := \033[1;3;4;30m
BD_UL_IT_RED     := \033[1;3;4;31m
BD_UL_IT_GREEN   := \033[1;3;4;32m
BD_UL_IT_YELLOW  := \033[1;3;4;33m
BD_UL_IT_BLUE    := \033[1;3;4;34m
BD_UL_IT_MAGENTA := \033[1;3;4;35m
BD_UL_IT_CYAN    := \033[1;3;4;36m
BD_UL_IT_WHITE   := \033[1;3;4;37m

RESET := \033[0m

# Prefix Macro
# When creating a macro , even if it'll be passed to 'echo' later, you _should_ add quotes.
P := "'$(BD_GREEN)'['$(WHITE)'Baka'$(BD_GREEN)']'$(RESET)'"

## Templates

# It's possible to preserve leading spaces by making a variable and inserting a reference at
# the beginning. Bad, but I don't know of a way around this.
SP = " "

define PYPROJECT_TOML
# If any strings are left empty, 'make lock' will fail.
# To debug, run 'pip install .' to emit errors.
[project]
# Package names should follow PEP 423.
name = \"\"
version = \"\"
description = \"\"
authors = [
${SP}${SP}${SP}${SP}{name = \"\", email = \"\"},
]
readme = \"readme.md\"
# For example, \">= 3.10\"
requires-python = \"\"
# See: https://pypi.org/classifiers/
classifiers = [\"Private :: Do Not Upload\"]

dependencies = [

]

[project.optional-dependencies]
dev = [

]

[project.urls]
Repository = \"\"
endef

define HELP
$(BD_BLUE)#$(RESET) $(BD_STD)Baka ¯\_(ツ)_/¯$(RESET) $(BD_BLUE)#$(RESET)

\"The Stupid Python Project Manager.\"

For more details, see $(UL_BLUE)https://github.com/Zoidmania/baka$(RESET).

This manager creates virtual environments for your Python project and manages
them with a standard virtual environment and minimal tooling. It $(BD_UL_IT_STD)does not$(RESET)
activate the environment for you! You must activate your virtual environment
with:

${SP}${SP}$$ $(BD_WHITE)cd /path/to/project/$(BD_RESET)
${SP}${SP}$$ $(BD_WHITE)source venv/bin/activate$(BD_RESET)

$(BD_BLUE)##$(RESET) $(BD_STD)Commands$(RESET) $(BD_BLUE)##$(RESET)

All commands are issued in the following format:

${SP}${SP}$$ $(BD_WHITE)make$(BD_RESET) $(BD_GREEN)<command>$(RESET)

The following commands are available.

$(BD_GREEN)clean$(RESET)
${SP}${SP}${SP}${SP}Deletes the project's virtual environment, and any $(BD_IT_BLUE).egg-info$(RESET) metadata.

$(BD_GREEN)help$(RESET)
${SP}${SP}${SP}${SP}Prints this help text and exits. Default command.

$(BD_GREEN)init$(RESET)
${SP}${SP}${SP}${SP}A convenience function that runs $(BD_GREEN)venv$(RESET) and $(BD_GREEN)pyproject$(RESET) in that order.

$(BD_GREEN)install$(RESET)
${SP}${SP}${SP}${SP}Alias for $(BD_GREEN)sync$(RESET).

$(BD_GREEN)lock$(RESET)
${SP}${SP}${SP}${SP}Creates lock files from the dependencies specified in $(BD_IT_BLUE)project.toml$(RESET).
${SP}${SP}${SP}${SP}Dependencies are $(BD_UL_IT_STD)not$(RESET) installed with this command.

$(BD_GREEN)pyproject$(RESET)
${SP}${SP}${SP}${SP}Generates a $(BD_IT_BLUE)pyproject.toml$(RESET) file from the standard template at the root of
${SP}${SP}${SP}${SP}the project.

$(BD_GREEN)refresh$(RESET)
${SP}${SP}${SP}${SP}A convenience function that runs $(BD_GREEN)clean$(RESET) and $(BD_GREEN)update$(RESET), in that order. Use to
${SP}${SP}${SP}${SP}completely rebuild a virtual environment.

$(BD_GREEN)sync$(RESET)
${SP}${SP}${SP}${SP}Syncs dependencies from the lock file to the virtual environment. Any new
${SP}${SP}${SP}${SP}dependencies will be installed, and any removed dependencies will be
${SP}${SP}${SP}${SP}uninstalled.

${SP}${SP}${SP}${SP}By default, $(BD_UL_IT_STD)development$(RESET) dependencies are synced. Set $(IT_ORANGE)BAKA_ENV$(RESET) to either
${SP}${SP}${SP}${SP}$(BD_STD)'main'$(RESET) or $(BD_STD)'dev'$(RESET) to select between the two available dependency lists.

$(BD_GREEN)update$(RESET)
${SP}${SP}${SP}${SP}A convenience function that runs $(BD_GREEN)venv$(RESET), $(BD_GREEN)lock$(RESET), and $(BD_GREEN)sync$(RESET), in that order.
${SP}${SP}${SP}${SP}Suitable for running after adding, removing, or updating dependencies.

$(BD_GREEN)venv$(RESET)
${SP}${SP}${SP}${SP}Creates a virtual environment at the root of the project, using the Python
${SP}${SP}${SP}${SP}interpreter specified by $(IT_ORANGE)BAKA_PYTHON$(RESET), or the default interpreter on the
${SP}${SP}${SP}${SP}$(IT_ORANGE)PATH$(RESET). Also upgrades $(BD_IT_CYAN)pip$(RESET) and installs $(BD_IT_CYAN)wheel$(RESET) and $(BD_IT_CYAN)pip-tools$(RESET), necessary
${SP}${SP}${SP}${SP}dependencies of Baka. This command $(BD_IT_STD)does not$(RESET) recreate the venv if one already
${SP}${SP}${SP}${SP}exists.

${SP}${SP}${SP}${SP}By default, the venv's prefix is the name of the parent directory of the
${SP}${SP}${SP}${SP}project directory. This can be overridden by setting $(IT_ORANGE)BAKA_VENV_PREFIX$(RESET).

$(BD_BLUE)##$(RESET) $(BD_STD)Getting Started$(RESET) $(BD_BLUE)##$(RESET)

You $(BD_UL_IT_STD)must$(RESET) choose a Python interpreter to use for initializing the virtual
environment (venv). Set the environment variable $(IT_ORANGE)BAKA_PYTHON$(RESET) to the your
interpreter of choice, otherwise the default Python interpreter on $(IT_ORANGE)PATH$(RESET) is used.
The interpreter specified with this variable is $(BD_UL_STD)only used to$(RESET) $(BD_UL_STD)create the venv$(RESET).

To get started, place the Baka $(BD_IT_BLUE)Makefile$(RESET) in the root of your project. Then,
$(BD_UL_IT_STD)remove any existing venvs from your project$(RESET).

To start managing a project, simply run the following and begin tracking your
dependencies in the generated $(BD_IT_BLUE)project.toml$(RESET).

${SP}${SP}$$ $(BD_WHITE)make$(BD_RESET) $(BD_GREEN)init$(RESET)

You $(BD_UL_IT_STD)must$(RESET) specify your project's dependencies according to $(BD_MAGENTA)PEP 621$(RESET). Additional
development dependencies should be specified in a list called $(BD_MAGENTA)dev$(RESET) in the
$(BD_MAGENTA)[project.optional-dependencies]$(RESET) section.
endef

## Directory and Env Helpers

BASEDIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
VENV := $(BASEDIR)/venv/bin/python
REQS := $(BASEDIR)/lock

ifndef BAKA_PYTHON
BAKA_PYTHON := /usr/bin/env python3
endif

ifndef BAKA_VENV_PREFIX
BAKA_VENV_PREFIX := "$(shell basename $(BASEDIR))"
endif

ifndef BAKA_ENV
BAKA_ENV := dev
endif

## Targets

.PHONY: init
init: venv pyproject

.PHONY: install
init: sync

.PHONY: clean
clean:
	@echo "$P $(BD_YELLOW)Removing project's egg-info...$(RESET)"
	@rm -rf $(BASEDIR)/*.egg-info

	@echo "$P $(BD_YELLOW)Removing virtual environment...$(RESET)"
	@rm -rf $(BASEDIR)/venv

	@echo "$P $(BD_YELLOW)Removing lock files...$(RESET)"
	@rm -rf $(BASEDIR)/lock

.PHONY: help
help:
	@# All of the spacing is designed to make the help text readable on a 80-column-width console.
	@echo "$(HELP)"

.PHONY: lock
lock:
	@$(shell mkdir -p $(REQS))

	@echo "$P $(BD_WHITE)Locking main dependencies...$(RESET)"
	@$(VENV) -m piptools compile -q --upgrade --resolver backtracking \
		-o $(REQS)/main $(BASEDIR)/pyproject.toml

	@echo "$P $(BD_WHITE)Locking dev dependencies...$(RESET)"
	@$(VENV) -m piptools compile -q --extra dev --upgrade --resolver backtracking \
		-o $(REQS)/dev $(BASEDIR)/pyproject.toml

.PHONY: pyproject
pyproject:
	@if [ ! -f $(BASEDIR)/pyproject.toml ]; then \
		echo "$(PYPROJECT_TOML)" > $(BASEDIR)/pyproject.toml; \
		echo "$P Created $(BD_IT_BLUE)project.toml$(RESET) file in project root from template."; \
	else \
		echo "$P $(BD_IT_BLUE)project.toml$(RESET) $(BD_RED)already exists!$(RESET) $(BD_YELLOW)Skipping creating from template!$(RESET)"; \
	fi
	@echo "$P $(BD_YELLOW)Edit your$(RESET) $(BD_IT_BLUE)project.toml$(RESET) $(BD_YELLOW)metadata and dependencies before locking!$(RESET)"

.PHONY: refresh
refresh: clean update

.PHONY: sync
sync:
	@echo "$P $(BD_WHITE)Syncing dependencies to venv...$(RESET)"

	@if [ "$(BAKA_ENV)" = "main" ] || [ "$(BAKA_ENV)" = "prod" ]; then \
		$(VENV) -m piptools sync $(REQS)/main; \
		$(VENV) -m pip check; \
	elif [ "$(BAKA_ENV)" = "dev" ]; then \
		$(VENV) -m piptools sync $(REQS)/dev; \
		$(VENV) -m pip check; \
	else \
		echo "$P $(BD_RED)Bad value for$(RESET) $(IT_ORANGE)BAKA_ENV$(RESET): $(BAKA_ENV)"; \
	fi

.PHONY: update
update: venv lock sync

.PHONY: venv
venv:
	@# We need to grab the Python interpreter on $$PATH to create the venv first, so don't use
	@# $$(VENV) here.
	@if [ ! -d $(BASEDIR)/venv ]; then \
		echo "$P $(BD_WHITE)Creating virtual environment...$(RESET)"; \
		$(BAKA_PYTHON) -m venv $(BASEDIR)/venv --prompt=$(BAKA_VENV_PREFIX); \
	fi

	@echo "$P $(BD_WHITE)Upgrading pip...$(RESET)"
	@$(VENV) -m pip install --upgrade pip

	@echo "$P $(BD_WHITE)Installing/upgrading pip-tools and wheel...$(RESET)"
	@$(VENV) -m pip install --upgrade pip-tools wheel
