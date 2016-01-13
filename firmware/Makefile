##############################################################################
#
#   Makefile for usbasp
#   20061119   Thomas Fischl        original
#   20061120   Hanns-Konrad Unger   help: and TARGET=atmega48 added
#   20151212   Bill Perry           Major re-work for multiple target MCUs
#                                   along with command line overrides
#
##############################################################################
# Fuse atmega8 high byte HFUSE:
# 0xc9 = 1 1 0 0   1 0 0 1 <-- BOOTRST (boot reset vector at 0x0000)
#        ^ ^ ^ ^   ^ ^ ^------ BOOTSZ0
#        | | | |   | +-------- BOOTSZ1
#        | | | |   + --------- EESAVE (don't preserve EEPROM over chip erase)
#        | | | +-------------- CKOPT (full output swing)
#        | | +---------------- SPIEN (allow serial programming)
#        | +------------------ WDTON (WDT not always on)
#        +-------------------- RSTDISBL (reset pin is enabled)
# Fuse atmega8 low byte LFUSE:
# 0x9f = 1 0 0 1   1 1 1 1
#        ^ ^ \ /   \--+--/
#        | |  |       +------- CKSEL 3..0 (external >8M crystal)
#        | |  +--------------- SUT 1..0 (crystal osc, BOD enabled)
#        | +------------------ BODEN (BrownOut Detector enabled)
#        +-------------------- BODLEVEL (2.7V)
#
# Fuse atmega48 high byte hfuse:
# 0xdf = 1 1 0 1   1 1 1 1     factory setting
#        ^ ^ ^ ^   ^ \-+-/
#        | | | |   |   +------ BODLEVEL (Brown out disabled)
#        | | | |   + --------- EESAVE (don't preserve EEPROM over chip erase)
#        | | | +-------------- WDTON (WDT not always on)
#        | | +---------------- SPIEN (allow serial programming)
#        | +------------------ DWEN (debug wire is disabled)
#        +-------------------- RSTDISBL (reset pin is enabled)
# 0xdd = ext.reset, no DW, SPI, no watchdog, no save eeprom, BOD 2.7V
# Fuse atmega48 low byte lfuse:
# 0x62 = 0 1 1 0   0 0 1 0     factory setting
#        ^ ^ \ /   \--+--/
#        | |  |       +------- CKSEL 3..0 (internal 8Mhz Oszillator)
#        | |  +--------------- SUT 1..0 (start-up time)
#        | +------------------ CKOUT (no clock output)
#        +-------------------- CKDIV8 (divide clock by 8)
# 0xdc = divide/1,no clock output,fast raising power,low Pw Oszil. 3..8 Mhz
# 0xe0 = divide/1,no clock output,fast raising power,external Oszil.
# 0xff = divide/1,no clock output,slow raising power,low Pw Oszil 8..  Mhz
##############################################################################

###############################################################################
# Begining of USER defined variables & defaults
# NOTE:
# any of these values can be ovridden from the commandline by using:
# VARNAME=value
# example:
# make hex MCU=atmega48
# make flash ISP=dragon_isp
# make flash HEXFILE=AnyPrebuilt.hex MCU=mcuOfHexfile"
# make autoflash HEXFILE=AnyPrebuilt.hex
###############################################################################

# USBASP Firmware revision numbers
# this gets stuffed into the USB DEVICE version field
# These values must be specified as decimal values.
# Minor revisions lower than 9 should have a leading 0 if you want them
# printed as #.0# vs #.#
USBASP_FWREV_MAJ=1
USBASP_FWREV_MIN=05

# default target MCU type if MCU not specified/overridden on make commandline
MCU=atmega8

# pick values based on MCU
ifeq ($(MCU), atmega8)
HFUSE=0xc9
LFUSE=0xef
else ifeq ($(MCU), atmega48)
HFUSE=0xdd
LFUSE=0xff
# 4k flash device
USBASP_4k_FLASH=1
else ifeq ($(MCU), atmega88)
HFUSE=0xdd
LFUSE=0xff
endif


# pick your default ISP type and port
#
# examples:
# ISP=bsd          PORT=/dev/parport0
# ISP=ponyser      PORT=/dev/ttyS1
# ISP=stk500       PORT=/dev/ttyS1
# ISP=stk500v2     PORT=/dev/ttyUSB0
# ISP=usbasp       PORT=usb
# ISP=dragon_isp   PORT=usb
ISP=usbasp
PORT=usb

# The two lines below are for "uisp" and the AVR910 serial programmer connected
# to a Keyspan USB to serial converter to a Mac running Mac OS X.
# Choose your favorite programmer and interface.
SERIAL = `echo /dev/tty.USA19QI*`
UISP = uisp -dprog=$S -dserial=$(SERIAL) -dpart=auto


###############################################################################
# END of USER defined variables
###############################################################################

# check for small/4k flash parts
# if on 4k parts, then disable TPI support to make it fit
#endif
ifeq (1, $(USBASP_4k_FLASH))
USBASP_MCU_OPT = -DUSBASP_CFG_DISABLE_TPI
endif

# get date in YYYY-MM-DD format.
DATE=$(shell date "+%F")

# create defines for USBasp f/w revision that will be used in USB device version
# USB device versions are in BCD so tack on 0x for the conversion from decimal
USBASP_OPTS = -DUSB_CFG_DVERSION_MAJ=0x$(USBASP_FWREV_MAJ) -DUSB_CFG_DVERSION_MIN=0x$(USBASP_FWREV_MIN) $(USBASP_MCU_OPT)


# create "standard" f/w base name to help identify the revision of the code
# this is independent of the target MCU
FW_BNAME=usbasp-v$(USBASP_FWREV_MAJ).$(USBASP_FWREV_MIN)

# create a "standard" file basname for all files for a given target MCU
# if no f/w basename, then just use mcutype as file basename
ifdef FW_BNAME
FILE_BNAME=$(FW_BNAME)-$(MCU)
else
FILE_BNAME=$(MCU)
endif

# hexfile name unless overridden
HEXFILE=$(FILE_BNAME).hex

help:
	@echo "Usage: make                same as make help"
	@echo "       make help           same as make"
	@echo "The following make targets below operate on a single MCU target device"
	@echo "       make hex            build hex and list files with auto names"
	@echo "       make {anyname}.hex  build anyname.hex for default MCU"
	@echo "       make {anyname}.lst  build .lst disassembly image"
	@echo "       make {anyname}.lss  build .lss disassembly image with C code comments"
	@echo "       make disasm         disassemble image and print its output"
	@echo "       make flash          upload HEXFILE into target device with avrdude"
	@echo "       make fuses          program fuses"
	@echo "Other useful make targets"
	@echo "       make hexall         build .hex files for all supported target devices"
	@echo "       make avrdude        test avrdude"
	@echo "       make clean          remove redundant files"
	@echo "       make autoflash      upload HEXFILE with MCU determined from filename"
	@echo "On these targets make sure to do a \"make clean\" first"
	@echo "       make hexdist        build & move .hex files to distribution directory"
	@echo "       make datehexdist    build & move dated .hex files to distribution directory"
	@echo "Current values:"
	@echo "       MCU=${MCU}"
	@echo "       LFUSE=${LFUSE}"
	@echo "       HFUSE=${HFUSE}"
	@echo "       CLOCK=12000000"
	@echo "       ISP=${ISP}"
	@echo "       PORT=${PORT}"
	@echo "       HEXFILE=${HEXFILE}"
	@echo "All values above (other than CLOCK) can be overridden"
	@echo "To override a value use VALUENAME=value on commandline"
	@echo "Each known MCU type includes default values for fuses that can be overidden."
	@echo "examples:"
	@echo "       make help MCU=mcutype"
	@echo "       make fuses MCU=atmega48"
	@echo "       make hex MCU=atmega48"
	@echo "       make flash MCU=atmega48"
	@echo "       make anyame.hex MCU=atmega88"
	@echo "       make flash MCU=atmega88 ISP=dragon_isp"
	@echo "       make flash ISP=usbtiny"
	@echo "       make fuses MCU=atmega88 LFUSE=LfuseValue HFUSE=HfuseValue"
	@echo "       make flash HEXFILE=anyprebuilt.hex MCU=mcuOfHexfile"
	@echo "       make autoflash HEXFILE=anyprebuilt.hex"
	@echo "NOTE: autoflash requires sed"
	@echo "See Makefile for further details"

COMPILE = avr-gcc -g -Wall -O2 -Iusbdrv -I. -mmcu=$(MCU) $(USBASP_OPTS) # -DDEBUG_LEVEL=2

OBJECTS = usbdrv/usbdrv.o usbdrv/usbdrvasm.o usbdrv/oddebug.o isp.o clock.o tpi.o main.o

.c.o:
	$(COMPILE) -c $< -o $@
#-Wa,-ahlms=$<.lst

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $@
# "-x assembler-with-cpp" should not be necessary since this is the default
# file type for the .S (with capital S) extension. However, upper case
# characters are not always preserved on Windows. To ensure WinAVR
# compatibility define the file type manually.

.c.s:
	$(COMPILE) -S $< -o $@

disasm:	$(FILE_BNAME).elf
	avr-objdump -d $<
cpp:
	$(COMPILE) -E main.c

#
# if $(HEXFILE) is added as a dependency for flash target, the hexfile will be
# built first, which is very nice; However... This would cause the .hex file to
# be clobbered if it was an archived distribution .hex file since the .hex file
# would not be newer than the source files.
# Becuse of this, $(HEXFILE) is not a dependency.
# This requires the user run make once for "hex" and once for "flash" to
# flash a default .hex file
# if this depdency is added, then the user must NEVER type:
# make flash HEXFILE=prebuilt.hex MCU=mcutype
#
flash:
	avrdude -c ${ISP} -p ${MCU} -P ${PORT} -U flash:w:$(HEXFILE)
#
# automatically determine MCU type for avrdude based on filename.
# If there is a "atmega[0-9]*" in the filename just before a . then that will be used
# If it is not found, then the full filname will be used as the "MCU" which will fail.
# This may not work for windows.
# this is usefule to flash existing distribution images
AUTOMCU= $(shell echo $(HEXFILE) | sed -e 's/\(.*\)\(atmega[0-9]*\)\..*/\2/')
autoflash:
	avrdude -c ${ISP} -p $(AUTOMCU) -P ${PORT} -U flash:w:$(HEXFILE)

fuses:
	avrdude -c ${ISP} -p ${MCU} -P ${PORT} -u -U hfuse:w:$(HFUSE):m -U lfuse:w:$(LFUSE):m

avrdude:
	avrdude -c ${ISP} -p ${MCU} -P ${PORT} -v

uisp:	$(HEXFILE)
	$(UISP) --erase
	$(UISP) --upload --verify if=$<

# file targets:

# unfortuantely since we are supporting builing images for multiple MCU targets
# we have to remove the OBJECTS when the .elf is created.
# this has the unfortunate side effect of having to rebuild everything each time
# even when files for a single MCU is being created

%.elf: $(OBJECTS)
	$(COMPILE) -o $@ $(OBJECTS) -Wl,-Map,$*.map
	rm $(OBJECTS)

%.lss: %.elf
	avr-objdump -h -S $< > $@

%.lst: %.elf
	avr-objdump -d $< > $@

%.hex: %.elf
	avr-objcopy -j .text -j .data -O ihex $< $@

hex: $(FILE_BNAME).hex $(FILE_BNAME).lst $(FILE_BNAME).lss

hexall:
	make hex MCU=atmega8
	make hex MCU=atmega48
	make hex MCU=atmega88

# clean up "trash" files
# unfortunately, since we are allowing so much flexibility on names of files we
# have to remove all the files of a given type rather than just specific named files
clean:
	rm -f *.hex *.lst *.obj *.cof *.lss *.map  *.elf *.o main.s usbdrv/*.o

# phony targets to move all hex images into a distribution directory named by rev & date
# after the files are created you can add the directory to the repo and commit it.
# NOTE:
# It is important that you do a "make clean" before any of the "dist" targets
# to ensure you only get the desired .hex files.
FWBINDIR = ../bin/firmware
hexdist: hexall
	-mkdir $(FWBINDIR)/usbasp-v$(USBASP_FWREV_MAJ).$(USBASP_FWREV_MIN)
	cp *.hex $(FWBINDIR)/usbasp-v$(USBASP_FWREV_MAJ).$(USBASP_FWREV_MIN)

datehexdist: datehexall
	-mkdir $(FWBINDIR)/usbasp-v$(USBASP_FWREV_MAJ).$(USBASP_FWREV_MIN)-$(DATE)
	cp *.hex $(FWBINDIR)/usbasp-v$(USBASP_FWREV_MAJ).$(USBASP_FWREV_MIN)-$(DATE)

# build files with names using fw version and dates
datehex:
	make hex FW_BNAME=usbasp-v$(USBASP_FWREV_MAJ).$(USBASP_FWREV_MIN)-$(DATE)

datehexall:
	make hexall FW_BNAME=usbasp-v$(USBASP_FWREV_MAJ).$(USBASP_FWREV_MIN)-$(DATE)

# build files with auto names based only on MCU 
mcuhex:
	make hex FILE_BNAME=$(MCU)

mcuhexall:
	make hexall FW_BNAME=

# debug target for date testing
date:
	@echo The date is $(DATE)
