## Cesium

Cesium is the first *shell* for the TI-84 Plus CE / TI-83 Premium CE calculators, and includes many useful features.

### Installing

In order to transfer Cesium to your calculator, you must have a linking program, such as TI-Connect CE: https://education.ti.com/ticonnectce. Once installed:

1. Plug-in your calculator and Launch TI-Connect CE
2. Send `cesium.8xp` (or `cesium_french.8xp` if needed)
3. Drag'n'drop them onto the calculator that should be in the devices list in TI-Connect CE
4. Press the [Send] button in the window that pops up.

Congratulations, Cesium is now on your calculator!

### Running
For the first run, execute Cesium as you would any other assembly program by pressing [2nd][0] and choosing the `Asm(` token.
Then press [prgm] and choose `CESIUM`. The homescreen should look like this:

    Asm(prgmCESIUM

**If you have OS 5.3+, you can just do:

    prgmCESIUM

Press [enter] to execute.

**NOTE:** The `Cesium` application is accessible with the [apps] button; *not* with the [prgm] button.

Once installed, the application cannot be transferred to other calculators. If you wish to transfer Cesium to other calculators after installation, you must resend the installer and transfer the installer to other calculators.
Another strategy is to make a group object (<kbd>2nd</kbd><kbd>+</kbd><kbd>8</kbd>, type in a group name) that contains the installer and a random, small file (`L1`, for instance).  Then, the group can be transferred and ungrouped with the same procedure, just scroll to `UNGROUP` in the menu and select the group with the installer.

### Controls
Cesium provides a way to quickly jump to different programs in the program browser. Simply press one of the keys with a green letter above it, and it will take you to the first program with that starts with that letter.

| Combination     | Action                   |
|-----------------|--------------------------|
| [2nd/enter]     | Run, select              |
| [alpha]         | Edit program options     |
| [zoom]          | Edit BASIC program       |
| [y=]            | Create new BASIC program |
| [graph]         | Rename program           |
| [mode]          | Enter settings menu      |
| [up/down]       | Move places              |
| [green letters] | Alpha search for program |

### Shortcuts
Shortcuts are available from the TI-OS system anywhere. Simply hold the [on] key and press the corresponding button to trigger the action.
Available actions:

| Combination | Action                                                     |
|-------------|------------------------------------------------------------|
| [on]+[prgm] | Launch Cesium Application                                  |
| [on]+[stat] | Power down with password on wake (Default password - 5555) |

You can change the password from the settings menu (Accessed using [mode]), and pressing the [sto->] button. This will prompt for a new password which will be automatically saved.

### External Backup
Cesium also offers the ability to externally back up the RAM from within the OS. These are also tied to the shortcuts:

**PLEASE DO NOT USE THESE FOR TRIVIAL ISSUES. THEY MAY CAUSE UNINTENDED WEAR ON THE FLASH CHIP, SO BE SURE TO MODERATE USEAGE.**
**THE FLASH CHIP IS ONLY DESIGNED TO SUPPORT 100,000+ ERASE CYCLES**

| Combination | Action                                                     |
|-------------|------------------------------------------------------------|
| [on]+[8]    | Backup RAM from TI-OS                                      |
| [on]+[5]    | Remove latest RAM backup                                   |
| [on]+[2]    | Restore RAM from latest backup                             |

### Running Programs
Cesium can run programs written in ASM, C, ICE, or BASIC, either from the archive or not. It is prefered that you place programs in the archive, as it will protect them against RAM clears.
To run a program, simply press [2ND] or [Enter]. After a program is finished running, it will return to Cesium.

### Features
*HUD:*
* Displays battery level.
* Program count. (toggle in settings)
* Current time. (toggle in settings, the clock MUST be set from TI-OS for the time to be 'correct')
* Custom color scheme. (changeable in settings)

*Backup features:*
* Backup RAM before executing programs (with [2nd] button). If a program crashes, nothing will be deleted or lost! (toggle in settings)
* Quick launch button (the [enter] button) that skips backup process.
* External backup, if your calculator crashes outside of Cesium, everything is still protected!
* Restore External backup feature so you can revert your calculator back to its backed-up state whenever you want.
* Video of every backup feature and how to use them: https://youtu.be/hZDzV1CDN3k

*Basic Features:*
* Quick launch with [ON]+[prgm] (toggle in settings)
* Quick (adjustable) password lock with [ON]+[stat] (toggle in settings)

* Run ASM programs directly.
* Run Archived programs with any OS.
* Edit Archived BASIC programs and an instant goto for errors. (Won't edit locked programs)
* While editing program, you have access to the entire screen (the "PROGRAM:NAME" line isn't there)
* Turn off loading indicator when running BASIC programs. (toggle in settings)

*Program Features:*
* Search for programs for a quick lookup.
* Archive programs.
* Lock programs from editing.
* Hide programs from normal [prgm] button.
* Rename a program.
* Create a program.
* Delete a program.

* Folder dedicated to FLASH applications. (No other folder support, toggle in settings)
* Automatically quits after a minute of inactivity so it won't drain your battery.

* Displays program details such as:
* Displays an icon next to the programs name.
* Language the program was written in.
* How large a program is.
* Extra information about a program at the bottom of the HUD.

Language support:
* English
* French (Credits to Adriweb for translation) 

### Uninstalling
To uninstall Cesium, press [2nd][+][2][1] and delete the Cesium Application and appvar.  

### Building
You can easily build Cesium by navigating in the `src` directory and entering the command:

Linux / macOS:

    spasm -E -DENGLISH=1 cesium.asm cesium.8xp && mv cesium.8xp ../cesium.8xp && spasm -E -DFRENCH=1 cesium.asm cesium.8xp && mv cesium.8xp ../cesium-french.8xp

Windows:

    spasm -E -DENGLISH=1 cesium.asm cesium.8xp && move cesium.8xp ../cesium.8xp && spasm -E -DFRENCH=1 cesium.asm cesium.8xp && move cesium.8xp ../cesium-french.8xp

### Credits
(C) February 2018 Matt "MateoConLechuga" Waltz
Licensed under BSD 3 Clause.

### Source and Bug Reports
Source is available here: https://github.com/mateoconlechuga/cesium

If you encounter an unexpected behavior, please make an issue on GitHub and/or post a topic on TI community websites detailing exactly went wrong and when. Thanks!
