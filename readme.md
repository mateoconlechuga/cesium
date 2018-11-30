## Cesium

Cesium is the first *shell* for the TI-84 Plus CE / TI-83 Premium CE calculators, and includes many useful features.

### Installing

In order to transfer Cesium to your calculator, you must have a linking program, such as TI-Connect CE: https://education.ti.com/ticonnectce. Once installed:

1. Plug-in your calculator and Launch TI-Connect CE
2. Send `cesium.8xp` (or `cesium_french.8xp` if needed)
3. Drag'n'drop them onto the calculator that should be in the devices list in TI-Connect CE
4. Press the <kbd>Send</kbd> button in the window that pops up.

Congratulations, Cesium is now on your calculator!

### Running
For the first run, execute Cesium as you would any other assembly program by pressing <kbd>2nd</kbd> + <kbd>0</kbd> and choosing the `Asm(` token.
Then press <kbd>prgm</kbd> and choose `CESIUM`. The homescreen should look like this:

    Asm(prgmCESIUM

*If you have OS 5.3 or above, you can just do:*

    prgmCESIUM

Press <kbd>enter</kbd> to execute.

**NOTE:** The `Cesium` application is accessible with the <kbd>apps</kbd> button; *not* with the <kbd>prgm</kbd> button.

Once installed, the application cannot be transferred to other calculators. If you wish to transfer Cesium to other calculators after installation, you must transfer the installer itself to other calculators.

### Controls
Cesium provides a way to quickly jump to different programs in the program browser. Simply press one of the keys with a green letter above it, and it will take you to the first program with that starts with that letter.

| Combination     | Action                                     |
|-----------------|--------------------------------------------|
| <kbd>2nd</kbd> / <kbd>enter</kbd> | Run, select              |
| <kbd>alpha</kbd>                  | Edit program options     |
| <kbd>zoom</kbd>                   | Edit BASIC program       |
| <kbd>y=</kbd>                     | Create new BASIC program |
| <kbd>graph</kbd>                  | Rename program           |
| <kbd>mode</kbd>                   | Enter settings menu      |
| <kbd>up</kbd> / <kbd>down</kbd>   | Move places              |
| <kbd>green letters</kbd>          | Alpha search for program |

### Shortcuts
Shortcuts are available from the TI-OS system anywhere. Simply hold the <kbd>on</kbd> key and press the corresponding button to trigger the action.
Available actions:

| Combination | Action                                                                     |
|-------------|----------------------------------------------------------------------------|
| <kbd>on</kbd> + <kbd>prgm</kbd> | Launch Cesium Application                              |
| <kbd>on</kbd> + <kbd>stat</kbd> | Power down with password on wake (No Default Password) |

You can change the password from the settings menu (Accessed using <kbd>mode</kbd>), and pressing the <kbd>sto→</kbd> button. This will prompt for a new password which will be automatically saved. 
*Note: There is no default password as before.*

### External Backup
Cesium also offers the ability to externally back up the RAM from within the OS. These are also tied to the shortcuts:

**THE FLASH CHIP IS ONLY DESIGNED TO SUPPORT 100,000+ ERASE CYCLES. PLEASE BE SURE TO MODERATE USEAGE.**

| Combination | Action                                                     |
|-------------|------------------------------------------------------------|
| <kbd>on</kbd> + <kbd>8</kbd>    | Backup RAM from TI-OS                  |
| <kbd>on</kbd> + <kbd>5</kbd>    | Remove latest RAM backup               |
| <kbd>on</kbd> + <kbd>2</kbd>    | Restore RAM from latest backup         |

### Running Programs
Cesium can run programs written in ASM, C, ICE, or BASIC, either from the archive or not. It is prefered that you place programs in the archive, as it will protect them against RAM clears.
To run a program, simply press <kbd>2nd</kbd> or <kbd>Enter</kbd>. After a program is finished running, it will return to Cesium.
Note: pressing <kbd>2nd</kbd> to back up RAM before running will only work if the "Backup RAM" option is enabled in the Cesium settings. Otherwise, the program will be run without backing up the RAM.

### Features
*HUD:*
* Displays battery level.
* Program count. (toggle in settings)
* Current time. (toggle in settings, the clock MUST be set from TI-OS for the time to be 'correct')
* Custom color scheme. (changeable in settings)

*Backup features:*
* Backup RAM before executing programs (with [2nd] button). If a program crashes, nothing will be deleted or lost! (toggle in settings)
* Quick launch button (the [enter] button) that skips backup process.
* External backup, if your calculator crashes outside of Cesium, everything is still protected! (done from homescreen)
* Restore External backup feature so you can revert your calculator back to its backed-up state whenever you want. (also done from homescreen)
* Video of every backup feature and how to use them: https://youtu.be/hZDzV1CDN3k

*Basic Features:*
* Quick launch with <kbd>on</kbd> + <kbd>prgm</kbd> (toggle in settings)
* Quick (adjustable) password lock with <kbd>on</kbd> + <kbd>stat</kbd> (toggle in settings)

* Run ASM , C, and ICE programs directly.
* Run Archived programs with any OS.
* Edit Archived BASIC programs and an instant goto for errors. (Won't edit locked programs)
* While editing program, you have access to the entire screen (the "PROGRAM:NAME" line isn't there for more space)
* Turn off run/busy indicator when running BASIC programs. (toggle in settings)

*Program Features:*
* Search for programs for a quick lookup. (press the letter with the green letter above it corresponding to the first letter of the program you're searching for)
* Archive programs.
* Lock programs from editing.
* Hide programs from normal <kbd>prgm</kbd> button (the TI-OS program menu).
* Rename a program.
* Create a program.
* Delete a program.
* Edit a program directly.

* Folder dedicated to FLASH applications.
* Folder dedicated to AppVar management.
* Automatically quits after about 20 to 25 seconds of inactivity so it won't drain your battery.

* Displays program details such as:
    * Displays an icon next to the programs name and above extra information.
    * Language the program was written in.
    * How large a program is.
    * Extra information about a program at the bottom of the HUD.

*Settings*
* Color selection (toggle with <kbd>mode</kbd>):
    * Theme color (primary color).
    * Main text color (secondary color).
    * Highlight color.
    * Inversion color.
    * Hidden programs color.
    * Background color.
* Disabling busy run indicator in Basic programs.
* Toggle show program/directory item count.
* Toggle display clock.
* Toggle running with RAM backup.
* Toggle showing special directories (Applications and AppVars).
* Enable/disable keyboard short cuts (Open Cesium hook, turn off with password hook, and external backup hooks).
* Toggle show item deletion confirmation to prevent accidentally deleting something you don't want to.
* Change LCD brightness

*Language support:*
* English
* French (Credits to Adriweb for translation!)

### Uninstalling 
<sup><sub>First off, why would you ever want to delete such an awesome shell?</sub></sup>

To uninstall Cesium, press <kbd>2nd</kbd> + <kbd>+</kbd> + <kbd>2</kbd> + <kbd>1</kbd> and delete the Cesium Application and appvar. Or you can delete anything Cesium from TI-Connect CE.

You can also delete the Cesium AppVar from Cesium, then delete the App itself.  Exit Cesium to finish.
NOTE: The "show special directories" box MUST be selected in order to see the AppVars/ Apps folder!!

### Building

Cesium uses submodules to build, so be sure to clone the project like so:
Go to a new folder, then run the following command(s):

    git clone --recursive https://github.com/mateoconlechuga/cesium.git

Download `fasmg` and place it in the root directory of the repository (Available for your OS near the bottom of [this page](https://flatassembler.net/download.php)), or add it to your global PATH variable.

Build Cesium using the following `make` commands, depending on what language you want:

    make
    make english
    make french

### Credits
(C) October 2015 - July 2018 Matt "MateoConLechuga" Waltz
Licensed under BSD 3 Clause.

### Source
Source is available here: https://github.com/mateoconlechuga/cesium

### Bug Reports and Feature Requests
Make a GitHub issue here: https://github.com/mateoconlechuga/cesium/issues

If you encounter an unexpected behavior, please make an [issue on GitHub] (https://github.com/mateoconlechuga/cesium/issues/) and/or post a topic on TI community websites detailing exactly went wrong and when. (If there isn't a GitHub issue for a bug, it will likely be ignored) Thanks!
