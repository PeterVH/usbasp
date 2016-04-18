Pre-compiled .hex images can be flashed using the tools
- winflash
- bashflash & bashflashDnD

Naming convention:
The pre-built images follow a naming convention of
usbasp-vMAJ.MIN-YYYY-MM-DD in attempt to provide consistent naming.
Where MAJ.MIN is the release version.
If MIN is less than 10 then it will be zero filled.
This MAJ.MIN version is also filled in to the USB h/w version information
and will be reported by tools like linux lsusb and Windows Device manager.

The USB h/w revisions consists of a 8bit major and 8bit minor revision number.
In this example: usbasp-v1.06-2016-04-01
Windows device manager will report the h/w id as 0106
Linux lsusb will report the h/w rev is 1.06

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


