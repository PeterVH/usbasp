@echo off
::===========================================================================
:: batch file to flash a hex image using avrdude
:: To use with drag and drop, just drop the desired .hex file on top of this
:: batch file.
:: No other tools other than avrdude are required to be installed.
::
:: avrdude must be on PATH or can be hard coded in AVRDUDE variable below
:: or overridden when in interactive mode.
::
:: MCU type is automatically determined from the filename.
:: Filename must have "atmegaX" in the filename and a dash, dot, or underbar
:: must follow
:: i.e. atmega8.hex  atmega88-2011-10-9.hex usbasp-v1.5-2016-01-12-atmega48.hex
:: This can be disabled by hard coding the MCU type below
::
:: NOTE:
::	This may report a warning/error about UNC paths not being supported
::	if run from a location on a networked server due to the stupid way
::	windows does its networking and disk volumes.
::	
::
:: Created: Jan 2016
::  Author: Bill Perry bperrybap@opensource.billsworld.billandterrie.com
::===========================================================================

:: don't screw with the parent shells environment variables if run from
:: a command prompt instead of using drag and drop
setlocal

:: if avrdude is not on path, put full path to it here
set AVRDUDE=avrdude

:: default avrdude ISP burner and port
set ISP=USBasp
set PORT=usb

:: default MCU type
:: 'auto' means to determine from filename
set MCU=auto

:: Interactive mode.
:: If set to 'y', then allow user to override all values interactively
set IMODE=y

::===========================================================================
:: Now do start doing some work
::===========================================================================

:: get name of this script
set pname=%~n0

:: if not in interactive mode, require filename argument
:: which is passed automatically by drag and drop
if not ["%IMODE%"] == ["y"] (
	if ["%~1"] == [""] goto usage
)

:: get name of drag and drop hex file (removing any quotes)
set HEXFILE=%~1

:: check for interactive mode
:: and allow user to override/change any defaults
:: default value is in () and is what will be used if <ENTER> is pressed
:: note: the UGLY if/goto is intentional because windows batch processing is retarded
:: and the if check for the gethexfile would not work correctly since all vars
:: inside an if are expanded all at once and up front.
if not ["%IMODE%"] == ["y"] (
	goto gotvars
)

echo -------------------------------------------------------------
echo %pname% avrdude flash utility
echo -------------------------------------------------------------
echo Enter avrdude options:

set /p AVRDUDE="avrdude command (%AVRDUDE%):"
set /p ISP="avrdude ISP programmer (%ISP%):"
set /p PORT="avrdude PORT (%PORT%):"
:gethexfile
set /p HEXFILE="hexfile (%HEXFILE%):"
if ["%HEXFILE%"] == [""] goto gethexfile

:gotvars

:: We can't use the filename as passed by drag and drop since the filename
:: is a full path and NT/Windows still does not use real mounts.
:: It uses drive letters for local DOS volumes and UNC for networked shares.
:: Since avrdude was written for real operating systems that use mounts,
:: the : after the drive letter really scews with things and
:: breaks the avrdude option parsing.
:: So we have to do a bunch of crap to work around this.
:: Some of the work is because Windows is so @#%@#$ stupid and
:: doesn't contain any real tools for parsing things.
:: So we have to do nonsense things like bogus loops to be able to use
:: the bogus magic variables to extract what we want because cmd.exe variable
:: parsing and substitution is so weak and inconsistent.
:: 

:: get the drive, path, and basname of the HEXFILE
:: This still works even if filename is not a full path including drive letter
:: On UNC filenames "drive" is \\
for %%i IN ("%HEXFILE%") do (
set HEXFILEdrive=%%~di
set HEXfilepath=%%~pi
set HEXFILEbasename=%%~nxi
)

:: Because Windows is so bad and inconsistent, we have to know whether
:: the hexfile is on a local DOS volume or on the network using a UNC filename
:: since we have to treat them differently.
:: We have to check to see if filename is using a UNC path or DOS volume
:: The "drive" of a UNC path filename is reported as "\\"
:: If on a DOS volume, then 
:: jump to the DOS drive where the hexfile is, then cd to the path
:: This allows using just the basename and avoids using any
:: BS DOS drive letter crap later since the : breaks things.
:: NOTE: REMs below are intentional as :: can't be used inside if/for
:: (isn't DOS batch syntax @#$#@ great!)

if not ["%HEXFILEdrive%"] == ["\\"] (
	REM change to DOS drive where hexfile is
	%HEXFILEdrive%
	REM change to path where hexfile is
	cd "%HEXFILEpath%"
	REM use basefilename now that we are where the file is
	set HEXFILE=%HEXFILEbasename%
)

:: If user forced MCU type then skip over auto mcu detection code
if not ["%MCU%"] == ["auto"] (
echo using FORCED MCU of %MCU%
goto got_mcu
)

:: Parsing SUCKS in Windows/DOS since it lacks proper tools,
:: so we have to jump through hoops and play ridiculous games.
:: We figure out MCU type by stripping off parts of hexfile name
:: and then ripping the string into tokens and then grabing the first token

:: First, strip off evertything before "atmega"
set MCU=%HEXFILE:*atmega=atmega%

:: to parse the string as tokens
:: change all dots, dashes, underbars to <space>
set MCU=%MCU:.= %
set MCU=%MCU:-= %
set MCU=%MCU:_= %

:: Extract first token which should be the MCU type
:: but can fail to work correctly if "atmega" is not
:: in the filename.
for /f "tokens=1" %%t in ("%MCU%") DO set MCU=%%t

:got_mcu

:: in intereactive mode allow modifying the MCU type
:: this can be very useful since the auto mcu detection can fail
:: to properly determine the MCU from the filename
if ["%IMODE%"] == ["y"] (
	set /p MCU="mcu type (%MCU%):"
)

:: run avrdude command
echo %AVRDUDE% -c %ISP% -P %PORT% -p %MCU% -U flash:w:"%HEXFILE%"
%AVRDUDE% -c %ISP% -P %PORT% -p %MCU% -U flash:w:"%HEXFILE%"

:: check to see if flash update succeeded
if %errorlevel% == 0 (
	echo FLASH successfully updated
) else (
	echo FLASH update failed
)

goto alldone

:usage
echo Usage: %pname% HexFilename
echo 	OR drag and drop Hexfile on top of batch file

:alldone
:: Wait for user input to allow time for user to see output
pause
