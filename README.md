# dotfiles

basic config files for all the things as I learn more linuxy things. There are many super duper all singing and dancing setups out there, this one is done by me so I can understand whats going on.


## setup mac from scratch

Execute by:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/khalido/dotfiles/master/setup_mac.sh)"
```

Installs essential apps using [brew](https://brew.sh).
Tweaks some settings, a nice guide here: https://macos-defaults.com

**28 July, 2021:** it worked!

## old stuff, clean up

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


### todos:

- script download and install current version of anaconda
