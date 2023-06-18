#################
# Baka Makefile #
#################

# For performance reasons, we do this in one subshell.
# See: https://www.gnu.org/software/make/manual/html_node/One-Shell.html
.ONESHELL:

## Console Output Helpers

# ANSI Colors
# When passing to 'echo', you shouldn't add quotes.
C_RED := \033[0;31m
C_GREEN := \033[0;32m
C_YELLOW := \033[0;33m
C_BLUE := \033[0;34m
C_MAGENTA := \033[0;35m
C_CYAN := \033[0;36m
C_WHITE := \033[0;37m

C_BOLD_RED := \033[1;31m
C_BOLD_GREEN := \033[1;32m
C_BOLD_YELLOW := \033[1;33m
C_BOLD_BLUE := \033[1;34m
C_BOLD_MAGENTA := \033[1;35m
C_BOLD_CYAN := \033[1;36m
C_BOLD_WHITE := \033[1;37m

C_RESET := \033[0m

# Prefix Macro
# When creating a macro , even if it'll be passed to 'echo' later, you _should_ add quotes.
P := "'$(C_BOLD_GREEN)'['$(C_BOLD_WHITE)'Baka'$(C_BOLD_GREEN)']'$(C_RESET)'"

## Directory Helpers

BASEDIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
PYTHON := $(BASEDIR)/venv/bin/python
REQS := $(BASEDIR)/lock

## Recipes

.PHONY: bootstrap
bootstrap: venv init install

.PHONY: venv
venv:
	@echo "$P $(C_BOLD_WHITE)Creating virtual environment...$(C_RESET)"
	@# We need to grab the Python interpretter on $$PATH to create the venv first, so don't use
	@# $$(PYTHON) here.
	@if [ ! -d $(BASEDIR)/venv ]; then \
		python -m venv $(BASEDIR)/venv --prompt="$(shell basename $(BASEDIR))"; \
	fi

.PHONY: init
init:
	@echo "$P $(C_BOLD_WHITE)Upgrading pip...$(C_RESET)"
	@$(PYTHON) -m pip install --upgrade pip
	@echo "$P $(C_BOLD_WHITE)Installing pip-tools and wheel...$(C_RESET)"
	@$(PYTHON) -m pip install --upgrade pip-tools wheel
	@if [ ! -d $(REQS) ]; then \
		mkdir -p $(REQS); \
		touch $(REQS)/main; \
		touch $(REQS)/dev; \
	fi

.PHONY: install
install:
	@echo "$P $(C_BOLD_WHITE)Installing Python dependencies...$(C_RESET)"
	@$(PYTHON) -m pip install --upgrade -r $(REQS)/main -r $(REQS)/dev -e .
	@$(PYTHON) -m pip check

.PHONY: lock
lock:
	@echo "$P $(C_BOLD_WHITE)Ensuring '$(BASEDIR)lock/' exists.$(C_RESET)"
	@$(shell mkdir -p $(REQS))
	@echo "$P $(C_BOLD_WHITE)Locking main dependencies...$(C_RESET)"
	@$(PYTHON) -m piptools compile --upgrade --resolver backtracking \
		-o $(REQS)/main pyproject.toml
	@echo "$P $(C_BOLD_WHITE)Locking dev dependencies...$(C_RESET)"
	@$(PYTHON) -m piptools compile --extra dev --upgrade --resolver backtracking \
		-o $(REQS)/dev pyproject.toml

.PHONY: update
update: init lock install

.PHONY: clean
clean:
	@echo "$P $(C_BOLD_YELLOW)Removing project's egg-info...$(C_RESET)"
	@rm -rf $(BASEDIR)/*.egg-info
	@echo "$P $(C_BOLD_YELLOW)Removing virtual environment...$(C_RESET)"
	@rm -rf $(BASEDIR)/venv

.PHONY: lint
lint:
	@echo "$P $(C_BOLD_WHITE)ruff check .$(C_RESET)"
	@$(PYTHON) -m ruff check .

.PHONY: test
test:
	@echo "$P $(C_BOLD_WHITE)pytest -v -s$(C_RESET)"
	@$(PYTHON) -m pytest -v -s
