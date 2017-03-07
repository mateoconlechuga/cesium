# Cesium

Cesium is the first *shell* for the TI-84 Plus CE / TI-83 Premium CE calculators.

### Features
* Running ASM, C, and Basic programs directly, and they can be archived or not
* [Un]Archiving, deleting, hiding, and renaming programs
* Catalog-like searching for programs for quick lookup
* Ability to hide then run indicator when running Basic programs
* Support implemented for relocatable shared C and ASM libraries
* Customizable icons for all file types (DoorsCS format)
* Battery indicator and clock
* Customizable colors/theme
* Available in French and English

### INSTALLING ###

In order to transfer Cesium to your calculator, you must have a linking program, such as TI-Connect CE: https://education.ti.com/ticonnectce. Once installed:

1. Plug-in your calculator and Launch TI-Connect CE
2. Select the two programs, `Cesium.8xp` and `A.8xp` downloaded from here (or `Cesium_French.8xp` if needed)
3. Drag'n'drop them onto the calculator that should be in the devices list in TI-Connect CE
4. Press the [Send] button in the window that pops up.

Congratulations, Cesium is now on your calculator!  

### RUNNING ###
All you need to do to run Cesium is to press [PGRM],[ENTER],[ENTER] in order to load prgmA.  
If you are still unsure of what to do, simply press the [PGRM] button, select the option that says 1:A, and press enter.  

The first time Cesium is run, it needs to copy some files to the archive to help with stability.  
Once you get a "Cesium Installed" message, simply press [ENTER] again.  
Now Cesium can be run at any time by running the prgmA.

### NAVIGATION ###
Cesium provides a way to quickly jump to different programs in the program browser. Simply press one of the keys with a green letter above it, and it will take you to the first program with that starts with that letter.
* [2ND/ENTER] - Run, select  
* [ALPHA] - Edit program options  
* [MODE] - Enter settings menu  
* [UP/DOWN] - Move places  
* [Key with green letter] - Alpha search
 
### RUNNING PROGRAMS ###
Cesium can run programs written in ASM, C, or BASIC, either from the archive or not. It is prefered that you place programs in the archive, as it will protect them against RAM clears.  
To run a program, simply press [2ND] or [Enter]. After a program is finished running, it will return to Cesium.

### UNINSTALLING ###
To uninstall Cesium, just press [2ND],[+],[2],[1] and delete the following files:
* A      (Program)
* CESIUM (Program)
* CeOS   (AppVar)
* Cesium (AppVar)

### CREDITS ###
(C) March 2017 Matt Waltz  
"MateoConLechuga"  
Licensed under BSD 3 Clause.

### BUGS ###
If you encounter an unexpected behaviour, please make an issue here on GitHub and/or post a topic on TI community websites detailing exactly went wrong and when. Thanks!
