# Pyllock ¯\\\_(ツ)_/¯

![GitHub](https://img.shields.io/github/license/Zoidmania/pyllock)
![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/Zoidmania/Pyllock)

On Linux or Unix/Mac systems, I like to use Makefiles, `pyproject.toml`, and
[`pip-tools`][pip-tools] to manage my Python projects these days. I've workshopped this process into
an informal standard that I'm now calling Pyllock. Pyllock will:

[pip-tools]: https://github.com/jazzband/pip-tools/

- Bootstrap a virtual environment using the `venv` module with the latest versions of `pip`,
  `wheel`, and `pip-tools`.
- Create lock files using `pip-tools` based on the contents of your project's `pyproject.toml`.
- Install and update dependencies based on the lock files.

New developers to existing projects can bootstrap their environments with ease using `make install`.

Add the dependencies you want in `pyproject.toml`, and pin the versions using `pip-tools` in a
`requirements.txt`-style lock file. `pip-tools` creates a temporary virtual environment whenever a
new lockfile is created, so you don't have to worry about poisoning your venv. Using Pyllock, devs can
generate new lockfiles and update their local env using `make update`.

Note that this methodology generates all of the main dependencies in the both the `main` and `dev`,
but that also ensures that if only the `dev` section is updated, then one could verify that the
dependencies stay in sync on both lock files.

To get started, simply place the `Makefile` at the root of your project, and:

```bash
make # prints help text
```

## Disclaimer

**This is in no way a sales pitch**; I'm only sharing my insanity. I'm resistant to [Poetry][poetry]
(some of its behavior rubs me the wrong way), but I like `pyproject.toml`. Just because _I_ don't
like Poetry doesn't mean you shouldn't use it. In fact, you probably should, it's a good tool.

[poetry]: https://python-poetry.org/

Also, huge thanks to [Hynek Schlawack][blog] for giving me the idea to use `pyproject.toml` +
`Makefile` to begin with.

[blog]: https://hynek.me/til/pip-tools-and-pyproject-toml/

## Rationale

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

## Requirements

Pyllock only works in Linux and Unix environments. It's designed for use with Bash, and hasn't been
tested with other shells. It also expects the following programs are available:

- `awk`
- `curl`
- `echo`
- `find`
- `mkdir`
- `mv`
- `rm`
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

## Installation

Simple:

```bash
# Download the Makefile
curl https://raw.githubusercontent.com/Zoidmania/pyllock/main/Makefile -o Makefile
```

Place the `Makefile` at the root of your project.

## Usage

After you've copied the Pyllock `Makefile` to your project root:

1. Run `make` (implies `make help`) to print help text.
1. If you don't have a virtual environment in a folder called `venv` at the root of your project,
   create one with `make venv`.
    - See [Optional Environment Variables](#optional-environment-variables) for options.
1. If you already have a `pyproject.toml`, make sure the metadata and dependencies are specified
   according to [PEP 621][pep-621]. If not, run `make pyproject` to create a boilerplate
   `pyproject.toml` that you can fill out.
1. Once you've defined your dependencies, run `make lock` to generate lock files.
    - The lock files will appear at `<project-root>/lock/[main|dev]`.
1. To _install_ your dependencies, run `make install` (or the alias `make sync`).
    - This target installs dependencies defined in the _lock files_, not directly from
      `pyproject.toml`.

Note: `make init` is a convenience that runs the `venv` and `pyproject` targets. It's useful for
starting brand new projects.

If you want to _add_ or _remove_ dependencies to or from an existing project, running `make update`
will update your venv's base dependencies (`pip-tools` and `wheel`), lock the new dependencies, and
install based on the new lock. This target is a convenience that runs the `venv`, `lock`, and `sync`
targets, in that order.

### Parallel Excution

Pyllock's recipes are inteded to be run _serially_. Parallel execution is disabled.

### Optional Environment Variables

The command `make venv` looks for two optional environment variables:

- Set `PYLLOCK_PYTHON` to point to your Python interpreter of choice. If this isn't set, Pyllock
  will use the default `python3` on your `PATH`.
- Set `PYLLOCK_VENV_PREFIX` to a string that will prefix your shell prompt. If this isn't set, the
  value defaults to the name of the parent directory to your project.

The command `make sync` (a.k.a. `make install`) looks for `PYLLOCK_ENV` to determine whether this is
a production ("main") or development ("dev") environment, defaulting to "dev" if unset. See
[Production](#production) for more details.

### Activate Your Virtual Environment

**_Nota Bene_**: `make` subshells the calls, so you can't activate the virtual environment with
`make` in _your_ shell session. I have a shell alias that does it (when run from the root of a
project):

```bash
alias act="source venv/bin/activate"
```

### Production

In production, you don't want to install your development-only dependencies. That's why we maintain
separate `main` and `dev` lock files.

To ensure that `make sync` (a.k.a. `make install`) only installs the main dependencies, set the
environment variable `PYLLOCK_ENV` to `"main"` or `"prod"`. If unset, Pyllock will default to
`"dev"`, which will install the `dev` lock file.
