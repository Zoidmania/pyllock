#################
# Baka Makefile #
#################

# For performance reasons, we do this in one subshell.
# See: https://www.gnu.org/software/make/manual/html_node/One-Shell.html
.ONESHELL:

BASEDIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
PYTHON := $(BASEDIR)/venv/bin/python
REQS := $(BASEDIR)/lock
P := "[Baka]"

.PHONY: bootstrap
bootstrap: venv init install

.PHONY: venv
venv:
	@echo "$P Creating virtual environment..."
	@# We need to grab the Python interpretter on $$PATH to create the venv first, so don't use
	@# $$(PYTHON) here.
	@if [ ! -d $(BASEDIR)/venv ]; then \
		python -m venv $(BASEDIR)/venv --prompt="$(shell basename $(BASEDIR))"; \
	fi

.PHONY: init
init:
	@echo "$P Upgrading pip..."
	@$(PYTHON) -m pip install --upgrade pip
	@echo "$P Installing pip-tools and wheel..."
	@$(PYTHON) -m pip install --upgrade pip-tools wheel
	@if [ ! -d $(REQS) ]; then \
		mkdir -p $(REQS); \
		touch $(REQS)/main; \
		touch $(REQS)/dev; \
	fi

.PHONY: install
install:
	@echo "$P Installing Python dependencies..."
	@$(PYTHON) -m pip install --upgrade -r $(REQS)/main -r $(REQS)/dev -e .
	@$(PYTHON) -m pip check

.PHONY: lock
lock:
	@echo "$P Ensuring '$(BASEDIR)lock/' exists."
	@$(shell mkdir -p $(REQS))
	@echo "$P Locking main dependencies..."
	@$(PYTHON) -m piptools compile --upgrade --resolver backtracking \
		-o $(REQS)/main pyproject.toml
	@echo "$P Locking dev dependencies..."
	@$(PYTHON) -m piptools compile --extra dev --upgrade --resolver backtracking \
		-o $(REQS)/dev pyproject.toml

.PHONY: update
update: init lock install

.PHONY: clean
clean:
	@echo "$P Removing egg-info..."
	@rm -rf $(BASEDIR)/*.egg-info
	@echo "$P Removing virtual environment..."
	@rm -rf $(BASEDIR)/venv

.PHONY: lint
lint:
	$(PYTHON) -m ruff check .

.PHONY: test
test:
	$(PYTHON) -m pytest -v -s
