# Pyllock ¯\\\_(ツ)_/¯

[![License](https://img.shields.io/github/license/Zoidmania/pyllock)](https://github.com/Zoidmania/pyllock/blob/main/LICENSE)
[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/Zoidmania/Pyllock)](https://github.com/Zoidmania/pyllock/releases)
[![Pronounciation](https://img.shields.io/badge/pronounciation-like_%22pilluck%22-blue)](#)
[![Footgun?](https://img.shields.io/badge/jury's%20out-red?style=flat&label=footgun%3F)](https://news.ycombinator.com/item?id=17393292)

Pyllock is a simple, probably stupid Python project manager. It's a Makefile being used as a command
runner.

On Linux or Unix/Mac systems, I like to use Makefiles, `pyproject.toml`, and
[`pip-tools`][pip-tools] to manage my Python projects these days. Pyllock will:

- Bootstrap a virtual environment using the `venv` module with the latest versions of `pip`,
  `wheel`, and `pip-tools`.
- Create lock files using `pip-tools` based on the contents of your project's `pyproject.toml`.
- Install and update dependencies based on the lock files.

[pip-tools]: https://github.com/jazzband/pip-tools/

## Installation

Simple:

```bash
# Download the Makefile
curl https://raw.githubusercontent.com/Zoidmania/pyllock/main/Makefile -o Makefile
```

Place the `Makefile` at the root of your project.

## Usage

To get started, run the default target:

```bash
make # prints help text
```

### Starting a Brand New Project

Generally, my workflow to bootstrap a project is as follows.

1. Create a virtual environment in a folder called `venv` at the root of the project and a
   boilerplate `pyproject.toml` with `make init`.
    - See [Optional Environment Variables](#optional-environment-variables) for options.
1. Fill out `pyproject.toml` with minimum metadata and dependencies required for the project.
1. Run `make lock` to generate lock files.
    - The lock files will appear at `<project-root>/lock/[main|dev]`.
1. Install the dependencies to the virtual environemtn with `make install` (an alias for
   `make sync`).
    - This target installs dependencies defined in the _lock files_, not directly from
      `pyproject.toml`.

### Adding or Removing Dependencies

If one wants to _add_ or _remove_ dependencies to or from an existing project, simply edit
`pyproject.toml`. Then:

```bash
make lock
make install
```

### Updating Dependencies to New Versions

This is a convenience that runs the `venv`, `lock`, and `install` targets, in that order:

```bash
make update
```

Running `make update` will update the venv's base dependencies (`pip`, `pip-tools` and `wheel`),
lock updated dependencies, and install the dependencies in the updated lockfile.

### Bootstrapping a Project on Another System

If lockfiles already exist for a project, bootstrapping the project elsewhere is easy:

```bash
make refresh
```

## Additional Notes

### Activating Your Virtual Environment

**_Nota Bene_**: `make` subshells the calls. You can't activate the virtual environment with `make`
in _your_ shell session. I have a shell alias that activates the venv in the current dir:

```bash
alias act="source venv/bin/activate"
```

### Parallel Excution

Pyllock's recipes are inteded to be run _serially_. Parallel execution is disabled.

### Optional Environment Variables

| Variable              | Affected Commands | Usage |
|-----------------------|-------------------|-------|
| `PYLLOCK_PYTHON`      | `venv`            | Set to a path to an alternate Python interpreter. |
| `PYLLOCK_VENV_PREFIX` | `venv`            | Set an alternate prompt prefix shown when activating the venv. Defaults to the name of the parent directory to your project. |
| `PYLLOCK_ENV`         | `sync`/`install`  | Determines whether this environment is "prod" or "dev". Defaults to "dev". |

### Production

In production, you don't want to install your development-only dependencies. That's why we maintain
separate `main` and `dev` lock files.

To ensure that `make sync` (a.k.a. `make install`) only installs the main dependencies, set the
environment variable `PYLLOCK_ENV` to `"main"` or `"prod"`. If unset, Pyllock will default to
`"dev"`, which will install the `dev` lock file.

## Requirements

Pyllock only works in Linux and Unix environments. It's designed for use with Bash, and hasn't been
tested with other shells. It also expects the following programs are available:

- Usual tools:
  - `awk`
  - `column`
  - `curl`
  - `echo`
  - `find`
  - `mkdir`
  - `mv`
  - `rm`
  - `sed`
  - `touch`
- GNU `make`
    - Tested with GNU Make 4.3.
    - Doesn't work with "standard" `make`. Pyllock relies on features of GNU Make.
- `python3`
    - You need to have Python available to create the virtual environment. Any version of Python
      that includes the `venv` module (**introduced in Python 3.3**) will work. The initial Python
      instance used to create your project's virtual environment **will not be modified**; only the
      project's virtual environment will be modified.
    - To specify a Python interpreter that isn't the default one on your `$PATH`, set the
      environment variable `PYLLOCK_PYTHON` to the interpreter of your choice. This variable is only
      used to create the venv.

In addition, your Python project must specify its dependencies in a `pyproject.toml` file, rather
than `requirements.txt`, according to [PEP 621][pep-621] (`make pyproject` will create a templated
file for you to get started). Namely:

- Specify your main dependencies in the `dependencies` list under the `[project]` section using
  [PEP 508][pep-508]-style strings.
- Place the extra development dependencies (like linters, the test suite, etc) in a list called
  `dev` in the `[project.optional-dependencies]` section, also using [PEP 508][pep-508]-style
  strings.
- Unlike `requirements.txt`, you _don't_ need to specify _all_ dependencies, only the ones your
  project needs _directly_. Don't specify dependencies of your dependencies in `pyproject.toml`.

[pep-621]: https://peps.python.org/pep-0621/
[pep-508]: https://peps.python.org/pep-0508/

---

# Rationale

I'm a fan of using minimal tooling to get things working, especially built-in tools. Since `pip` and
`venv` ship with most standard Python installations, that's been my workflow for quite some time. I
used Poetry for a while because it made life easier, but it always bugged me that I was replacing
`pip`'s functionality.

For a few years, Poetry was the only _good_ way to manage your Python dependencies. Its ability to
resolve the dependency graph introduced modern project management to Python development, and it
continues to enjoy widespread usage.

However, `pip` has received upgrades in recent years, adding its own [dependency resolver][pip-res]
(enabled by default). It's still not quite as good as Poetry's, but it's sufficient. That's one
piece of the puzzle solved.

[pip-res]: https://pip.pypa.io/en/stable/topics/dependency-resolution/

With the introduction of [PEP 621][pep-621], we gained the ability to declare the packages we
required in a concise manner along with project metadata. Gone were the days of needing to supply a
large `requirements.txt` file and wondering "which of these packages do I _actually_ need, and which
of them are dependencies of my dependencies?" Coupled with `pip`'s new resolver and `venv` to
isolate project dependencies, the only thing missing is the ability to lock the dependency graph.

Since `pip` still doesn't have a good way to do this, my original inclination was to simply
`pip freeze` after installing dependencies, but this has a couple of problems:

- Classic `requirements.txt` files make for poor lockfiles because `pip freeze` emits dependencies
  in alphabetical order, not in an order that's suitable for ordered installations (rare).
- This requires installing dependencies _before_ locking, which is an antipattern IMO. If dependency
  installation fails, then you may have just corrupted your environment.

This is where `pip-tools` comes in, a package that allows developers to "compile" requirements in a
temporary, isolated virtual environment without messing with your development env, in addition to
labeling and ordering the dependencies in a sensible manner. Pyllock uses this feature of `pip-tools`
to generate its lock files.

## Disclaimer

**This is in no way a sales pitch**; I'm only sharing my insanity. I'm resistant to [Poetry][poetry]
(some of its behavior rubs me the wrong way), but I like `pyproject.toml`. Just because _I_ don't
like Poetry doesn't mean you shouldn't use it. In fact, you probably should, it's a good tool.

[poetry]: https://python-poetry.org/

Also, huge thanks to [Hynek Schlawack][blog] for giving me the idea to use `pyproject.toml` +
`Makefile` to begin with.

[blog]: https://hynek.me/til/pip-tools-and-pyproject-toml/


## Acknowledgement

I leveraged some ideas and code from mitjafelicijan's [makext][makext], an effort to add extensions
for Makefiles being used as a command runner.

[makext]: https://github.com/mitjafelicijan/makext/tree/master
