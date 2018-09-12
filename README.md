# dotfiles

basic config files for all the things as I learn more linuxy things. There are many super duper all singing and dancing setups out there, this one is done by me so I can understand whats going on.

1. Clone this repo in the homedir:

```bash
git clone https://github.com/khalido/dotfiles.git
```

2. Make symlinks to all the dotfiles:

```bash
./makesymlinks.sh
```

3. Clone all my repos (only does up to 200 repos) - but copy this script into a `~/code` and run there:

```bash
./gitcloneall.sh khalido
```

### misc

- `caret_user.json` is the preferences file for the [chromeos app Caret](https://github.com/thomaswilburn/Caret). It is supposedely syncd by chrome itself but in practice it doesn't.

### todos:

- automates this into a `./setup.sh` script. Or a `setup.py`. Bash is too old school.
- download and install anaconda