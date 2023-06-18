#################
# Baka Makefile #
#################

# For performance reasons, we do this in one subshell.
# See: https://www.gnu.org/software/make/manual/html_node/One-Shell.html
.ONESHELL:

BASEDIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
PYTHON:=$(BASEDIR)/venv/bin/python
REQS:=$(BASEDIR)/requirements

.PHONY: bootstrap
bootstrap: venv init install

.PHONY: venv
venv:
    # We need to grab the Python interpretter on $PATH to create the venv first, so don't use
    # $(PYTHON) here.
    if [ ! -d "./venv" ]; then \
        python -m venv venv --prompt="$(shell basename $(BASEDIR))"; \
    fi

.PHONY: init
init:
    $(PYTHON) -m pip install --upgrade pip
    $(PYTHON) -m pip install --upgrade pip-tools wheel
    if [ ! -d "./requirements" ]; then \
        mkdir -p $(REQS); \
        touch $(REQS)/main; \
        touch $(REQS)/dev; \
    fi

.PHONY: install
install:
    $(PYTHON) -m pip install --upgrade -r $(REQS)/main -r $(REQS)/dev -e .
    $(PYTHON) -m pip check

.PHONY: lock
lock:
    $(shell mkdir -p $(REQS))
    $(PYTHON) -m piptools compile --upgrade --resolver backtracking \
        -o $(REQS)/main pyproject.toml
    $(PYTHON) -m piptools compile --extra dev --upgrade --resolver backtracking \
        -o $(REQS)/dev pyproject.toml

.PHONY: update
update: init lock install

.PHONY: clean
clean:
    rm -rf ./venv

.PHONY: lint
lint:
    $(PYTHON) -m ruff check .

.PHONY: test
test:
    $(PYTHON) -m pytest -v -s
