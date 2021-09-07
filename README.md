# dotfiles

basic config files for all the things as I learn more linuxy things. There are many super duper all singing and dancing setups out there, this one is done by me so I can understand whats going on.

this repo:

1. Provides dotfiles to [personalize](https://github.com/khalido/dotfiles.git) github codespaces and other linux machines
2. script to setup computers - so far mac.

## setup chromeos from scratch

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/khalido/dotfiles/master/setup_chromeos.sh)"
```
(work in progress)

## setup mac

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/khalido/dotfiles/master/setup_mac.sh)"
```

Installs essential apps using [brew](https://brew.sh).
Tweaks some settings, a nice guide here: https://macos-defaults.com

Shoutout to all the mac setup scripts on github, from which most of the stuff here comes from.

Note: Everything is in one big script so the above command works.

### setup hyper key

In karabiner-elements, import this rule from internet: `Change caps_lock key (rev 5)`

Select the modification: `Change caps_lock key to command+control+option+shift. (Post f19 key when pressed alone)`.

Now set capslock as the raycast shortcut key, and capslock + some key as triggers for various stuff.

e.g I currently have:

```
hyper        : opens raycast

# window stuff
hyper + [    : window fill left half
hyper + ]    : window fill right half
hyper + M    : maximize
hyper + up   : max height
hyper + down : max width

# misc useful things
hyper + L : lock screen
```

Now I run the error of forgetting all the mac shortcuts, but the advantage is that these are somewhat similar to chromeos shortcuts.


## Notes

if a shell script doesn't execute: `sudo chmod +x mac_settings.sh`

# dev setup

## clone all my public repos

Clone all my repos (only does up to 200 repos) - but copy this script into a `~/code` and run there:

```bash
./gitcloneall.sh khalido
```
