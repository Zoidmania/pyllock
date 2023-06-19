# Baka ¯\\\_(ツ)_/¯

![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/w/Zoidmania/baka/master)

On Linux or Unix/Mac systems, I like to use Makefiles, `pyproject.toml`, and
[`pip-tools`][pip-tools] to manage my Python projects these days (on Linux and Mac at least). I've
workshopped this process into an informal standard that I'm now calling Baka. Baka will:

[pip-tools]: https://github.com/jazzband/pip-tools/

- Bootstrap a virtual environment using the `venv` module with the latest versions of `pip`,
  `wheel`, and `pip-tools`.
- Create lock files using `pip-tools` based on the contents of your project's `pyproject.toml`.
- Install and update dependencies based on the lock files.

New developers to existing projects can bootstrap their environments with ease using `make install`.

Add the dependencies you want in `pyproject.toml`, and pin the versions using `pip-tools` in a
`requirements.txt`-style lock file. `pip-tools` creates a temporary virtual environment whenever a
new lockfile is created, so you don't have to worry about poisoning your venv. Using Baka, devs can
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

## Installation

Simple:

```bash
# Download the Makefile to the root of your project
curl https://raw.githubusercontent.com/Zoidmania/baka/main/Makefile -o /<path>/<to>/<project>/Makefile
```

## Requirements for Usage

Baka only works in Linux and Unix environments. It's designed for use with Bash, and hasn't been
tested with other shells. It also expects the following programs are available:

- `echo`
- `mkdir`
- `mv`
- `rm`
- `touch`
- GNU `make`
    - Tested with GNU Make 4.3.
    - Doesn't work with "standard" `make`. Baka relies on features of GNU Make.
- `python3`
    - You need to have Python available to create the virtual environment. Any version of Python
      that includes the `venv` module (**introduced in Python 3.3**) will work. The initial Python
      instance used to create your project's virtual environment **will not be modified**; only the
      project's virtual environment will be modified.
    - To specify a Python interpreter that isn't the default one on your `$PATH`, set the
      environment variable `BAKA_PYTHON` to the interpreter of your choice. This variable is only
      used to create the venv.

In addition, your Python project must specify its dependencies in a `pyproject.toml` file, rather
than `requirements.txt`, according to [PEP 621][pep-621]. Namely:

- Specify your main dependencies in the `dependencies` list under the `[project]` section using
  [PEP 508][pep-508]-style strings.
- Place the extra development dependencies (like linters, the test suite, etc) in a list called
  `dev` in the `[project.optional-dependencies]` section, also using [PEP 508][pep-508]-style
  strings.

[pep-621]: https://peps.python.org/pep-0621/
[pep-508]: https://peps.python.org/pep-0508/

## Outstanding Issues

There are a few outstanding issues with this methodology (that probably won't get fixed):

- `make` subshells the calls, so you can't activate the virtual environment with `make` in _your_
  shell session. I have a shell alias that does it:
  ```bash
  alias act="source venv/bin/activate"
  ```
- Removing "root" dependencies from the `pyproject.toml` doesn't work with the Makefile easily, so
  there isn't a target for that. After removing the dependency, you can do this manually:
  ```bash
  cd /path/to/your/project/
  act # my alias for 'source venv/bin/activate'
  python -m pip uninstall <removed package>
  python -m pip check
  make lock
  ```
  The alternative approach is to nuke the venv and build it from scratch, but that's painful when
  the project is large (though made easier via `pip`'s wheel-caching feature):
  ```bash
  make refresh
  ```
- Baka doesn't work on Windows. `make` is generally not something you'd use on Windows, though I'm
  sure I could accomplish a similar batch script to do this too. But I don't want to. Maybe
  [NMake][nmake] is something we could explore in the future.
- It would be nice if we could pass arguments to `make pyproject`, or optionally prompt the user for
  values to fill in. But, dumping the file to the project root and manually editing it is fine for
  now.
    - `make` doesn't allow accepting arguments or options to targets because you can specify
      multiple targets to run.
    - We could make env vars that Baka could look for, but the syntax is backwards when passing
      inline to `make` calls, and setting a `.env` file is functionally no different than editing
      `pyproject.toml` manually after the template is generated.

[nmake]: https://learn.microsoft.com/en-us/cpp/build/reference/nmake-reference?view=msvc-170

These are acceptable trade-offs for me. I don't often develop on Windows natively, and I typically
nuke my venvs when uninstalling major dependencies anyway.
