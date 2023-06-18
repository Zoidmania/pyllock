# Baka

On Linux or Unix/Mac systems, I like to use Makefiles, `pyproject.toml`, and `pip-tools` to manage
my Python projects these days (on Linux and Mac at least). I've workshopped this process into an
informal standard that I'm now calling Baka. Baka will:

- Bootstrap a virtual environment using the `venv` module with the latest versions of `pip`,
  `wheel`, and `pip-tools`.
- Create lock files using `pip-tools` based on the contents of your project's `pyproject.toml`.
- Install and update dependencies based on the lock files.

Typical project layout is:

```
.
├── LICENSE
├── Makefile
├── pyproject.toml
├── readme.md
├── lock
│   ├── main
│   └── dev
├── src
│   └── whatever.py
└── tests
    └── test-whatever.py
```

New developers can bootstrap their environments with ease using `make bootstrap` (the default
target).

Add the dependencies you want in `pyproject.toml`, and pin the versions using `pip-tools` in a
`requirements.txt`-style lock file. `pip-tools` creates a temporary virtual environment whenever a
new lockfile is created, so you don't have to worry about poisoning your venv. Using Baka, devs can
generate new lockfiles and update their local env using `make update`.

Note that this methodology generates all of the main dependencies in the both the `main` and `dev`,
but that also ensures that if I only update the `dev` section, then I can verify that the
dependencies stay in sync on both lock files.

## Requirements

Baka only works in Linux and Unix environments. It's designed for use with Bash, and hasn't been
tested with other shells. It also expects the following programs are available:

- echo
- make
    - Tested with GNU Make 4.3.
- mkdir
- python
    - You need to have Python available on the $PATH to create the virtual environment. Any version
      of Python that includes the `venv` module (introduced in Python 3.3) will work. The initial
      Python instance used to create your project's virtual environment **will not be modified**;
      only the project's virtual environment will be modified.
- rm
- touch

# Disclaimer

**This is in no way a sales pitch**, only sharing my insanity. I'm resistant to [Poetry][poetry]
(some of its behavior rubs me the wrong way), but I like `pyproject.toml`. Just because _I_ don't
like Poetry doesn't mean you shouldn't use it. You probably should, it's a good tool.

[poetry]: https://python-poetry.org/

Also, huge thanks to [Hynek Schlawack][blog] for giving me the idea to use `pyproject.toml` +
`Makefile` to begin with.

[blog]: https://hynek.me/til/pip-tools-and-pyproject-toml/

# Outstanding Issues

There are a few outstanding issues with this methodology:

- `make` subshells the calls, so you can't activate the virtual environment with `make` in _your_
  shell session. I have a shell alias that does it:
  ```bash
  alias act="source venv/bin/activate"
  ```
- Removing "root" dependencies from the `pyproject.toml` doesn't work with the Makefile easily, so
  there isn't a target for that. After removing the dependency, you can do this manually:
  ```bash
  act
  python -m pip uninstall <removed package>
  python -m pip check
  make lock
  ```
  The alternative approach is to nuke the venv and build it from scratch, but that's painful when
  the project is large:
  ```bash
  make clean
  make
  ```
- This doesn't work on Windows. `make` is generally not something you'd use on Windows, though I'm
  sure I could accomplish a similar batch script to do this too. But I don't want to.
