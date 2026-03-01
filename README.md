<img width="256" alt="pvzFusionAccountManagerIcon" src="resources/icons/appicon.png">

# PvzFusionAccountManager

## Overview

**PvzFusionAccountManager** is an account manager for the fan game *PVZFusion* by LanPiaoPiao.

- Create and manage multiple accounts with independent versioning.
- Select which account to play with.
- Acts as the main entry point for the game, allowing you to start and close it directly.

---

## Motivation

On my birthday, a friend of mine wanted to play a round of *PvzFusion* using my girlfriend’s account and mine.  
We also wanted to watch him play without letting him affect our progress.

So, we thought: *wouldn’t it be nice to have an account manager for this game?*  
We searched online but found no existing solutions.

Thus, **PvzFusion Account Manager** was born.

We quickly began development and sketched the first ideas.

This repo contains the final product and the installer for the manager.

> As it started as a hobby project, feel free to contribute!

We hope this tool will solve not only our problem but also every PvzFusion fan’s problem.

---

## Installation

The manager installs via an installer found here: [installer](https://github.com/Lukbes1/PvzFusionAccountManager/releases/tag/v1.0.0)

### Installer Warning

The installer may warn that the author is not a trusted publisher.

> This is the same issue *PvzFusion* faces. Registering apps with trusted signatures costs a lot of money and is not worth it for this project.  
> The warning does **not** affect functionality.

---

## Getting Started

### On App Startup

The app automatically searches for:

1. Your downloaded `PlantsVsZombiesFusionRH.exe`
2. The directory where your game saves are stored

If either is not found, a dialog will appear prompting you to provide the paths manually:

![upload button](readme_sources/uploadExeOrGamefile.png) 

> The `game files` directory usually doesn’t change, but if it does, you can update it in the previous dialog.  
> This dialog can also be opened later via the **settings** icon.

---

### Playing the Game

By default, a new account is created. 

To play:

1. Select the account.
2. Click the **Play** button:

![play button](readme_sources/playButton.png)

To quit:

- Press **Quit** in-game, or
- Click the **Stop** button in the account manager:

![stop button](readme_sources/stopButton.png)

> The game is automatically saved when quitting via either method.

---

### Quick Guide

<div class="flex">
    Click the
    <img width="30" height="30" alt="infoButton" src="readme_sources/infoButton.png" style="vertical-align: middle;"/>
    button to view a simple guide for getting started.
</div>

---

## Features and Handling

### General Usage

Once you start using the manager, you are **never forced to stay with the manager and can opt out at any moment**.  
Accounts can always be backed up manually via the **Backup** button (see [Edit Account](#edit-account)).

---

### Refresh

The **Refresh** button:

- Reloads all accounts
- Verifies that your `.exe` and game files directory exist and are intact

---

### Create New Account

Press the **Create** button. A dialog will appear asking for:

- Desired profile picture
- Account name (must be unique)
- Whether to copy from an existing source

You can:

- **Import files** from a directory, or
- **Copy the last saved state** from an existing account

> If copying from an account, a new symbol will appear with the name of the copied account and a **trashcan** icon.  
> Clicking the trashcan removes the copy, allowing you to select a new source.  
> The same happens for imported files, labeled as `Custom gamefile`.

![custom game files](readme_sources/customGameFiles.png)

---

### Edit Account

Right-click on an account to open the options dialog:

| Option | Description                                                                                            |
|--------|--------------------------------------------------------------------------------------------------------|
| Trashcan | Permanently delete the account                                                                         |
| Edit | Change the account’s name or profile picture                                                           |
| Previous Saves | Switch to a previous version (last 5 sessions saved). **Note:** newer versions are permanently deleted |
| Backup | Save the last playing state of the account to a directory on your PC <br/>(This ensures you can always manually save your progress if you prefer not to rely solely on the app.)                                |

![options dialog](readme_sources/optionsDialog.png)

---

### Changing the Selected `.exe` or Game Files Location

Press the **Settings** button to open the welcome dialog.

Here you can manually change:

- The `.exe` path
- The game files directory

<div style="border-left: 2px solid #FFD700; padding: 10px; background: #373839">
  It is recommended <strong>not to change the game files directory</strong> if it is detected correctly.<br>
  If not, the default path for PvzFusion is (as of version 3.4):
<code>Users\YourUser\AppData\LocalLow\LanPiaoPiao\PlantsVsZombiesRH</code>
</div>

**See** [Getting started](#getting-started)

---

## Common Problems

### Switching Versions

If you’ve played multiple sessions and want to revert to an older version:

- Versions newer than the one you select will be deleted.
- Confirm deletion to restore the account to the desired state.

> Example: Selecting version 2 out of 4 will delete versions 1 and 2, where 1 is newest and 4 is oldest.  
> The versions that will be deleted are marked with **a red x** in the example picture (**NOT in the actual application**) <br/>
> Your account will reflect the state as of the selected session timestamp.

![Switch versions help](readme_sources/SwitchVersionsHelp.png)

---

## License and Copyright

[License](license.txt)


## Concept Art and early sketches

Here is how the manager would have looked, if my girlfriend hadn't been there:

<div class="flex">
    <img width="300" alt="Main page old" src="readme_sources/concept_art/originalMainPage.png">
    <img width="300" alt="Main page old" src="readme_sources/concept_art/originalCreation.png">
    <img width="300" alt="Main page old" src="readme_sources/concept_art/originalDeletion.png">
</div>

## Last words

**Credits**: Lukas Beschorner did the coding and Lana Langen did the art and design

