![appicon](resources/icons/appicon.png)

# PvzFusionAccountManager

## Overview

This is an account manager for the fan game PVZFusion made by LanPiaoPiao.

- It allows creating multiple accounts with independent versioning and then selecting one to play the game with.
- Acts as the main entry point for the game, allowing starting and closing the game

## Motivation

On my birthday a friend of mine wanted to play a round of PvzFusion on my girlfriends account and mine.
We do wanted to watch him play too, however we did not want to let him make progress on our save.
So, we thought to ourselves, would'nt it be nice to have an account manager for this game?
And so we searched for some product in the internet, unfortunately without any results.

And so the pvz fusion account manager was born.

We quickly began to develop it and come up with first sketches.

This repo contains the final product and also the installer for the manager.

As it started out as a hobby project, things might not be completely polished.
Feel free to contribute

We hope to not only solve our, but also every pvzfusion fans problem with this.

## Installation

The installation works via an installer found here: [installer](Output/installer.exe) 

### Installer warning

The installer will warn you that the author is not a trusted publisher. 

It is the same problem that pvzfusion faces: Registering apps with trusted signatures costs a lot of money and is just not worth the cost.

The warning does not make the product less functional.

## Getting started

### On app startup

The app searches for your downloaded `PlantsVsZombiesFusionRH.exe` and the directory in which the game saves your game state.

If the search for one of them fails, an dialog will popup informing you that you have to give the app the pathes manually by pressing the upload button:

![upload button](resources/icons/upload.svg)

The `game files` directory will probably not change for the lifetime of pvzfusion. However if it does, you have the ability to set it in the dialog.

This exact dialog can also later be opened manually via the settings icon.

### Playing the game with the account manager

Per default, an account will be created. Select this account and hit the play button:

![play button](resources/icons/play.svg)

To quit, either press the `quit` button in game, or press the stop button in the account manager:

![stop button](resources/icons/stop.svg)

The game will automatically be saved upon pressing either of the buttons.

## Features


## Common problems


## License and Copyright