Pre-compiled .hex images can be flashed using the tools
- winflash
- bashflash & bashflashDnD

===========
On Windows:
===========
The desired hexfile can be dragged and dropped on top of the winflash.bat file.
winflash can also be run from the commandline.
It will prompt for all avrdude options needed.
Each avrdude option has a default value which will be used if <enter> is
pressed.
If avrdude is not on the path, the full path to its location can be specified.

================================
On OSes that support bash shell:
================================
The bash shell script bashflash is a wrapper script for avrdude.
The desired hex file can be passed on the commandline.
It will prompt for all avrdude options needed.
Each avrdude option has a default value which will be used if <enter> is
pressed.
If avrdude is not on the path, the full path to its location can be specified.

Also included is bashflashDnD.desktop which is a Gnome/KDE file to allow using
drag and drop.
Simply drag and drop the desired hex file on top of bashflashDnD which will
start the bashflash script and pass in the desired hexfile name.


