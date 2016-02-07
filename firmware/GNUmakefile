##############################################################################
#
#   Makefile for usbasp
#   20061119   Thomas Fischl        original
#   20061120   Hanns-Konrad Unger   help: and TARGET=atmega48 added
#   20151212   Bill Perry           Major re-work for multiple target MCUs
#   20160129   Peter Van Hoyweghen  Template based support for multiple MCUs
#                                   (Requires GNU Make).
#
#   Note GNU make prefers 'GNUMakefile' over' Makefile', so _this_ file
#   will be used when GNU make is available and 'Makefile' will be used when
#   not.
#
##############################################################################

# List of supported mcus
MCUS := atmega8 atmega48 atmega88

# 'make all' will build firmware for all supported mcu's
# You will typically have one of those mcu's on your desk to work with.
# That mcu is specified by MCU, see below:

###############################################################################
# Begining of USER defined variables & defaults
#
# Any of these values can be ovridden:
#	1. from a .config configuration file (which is ignored by git)
#		To create a default .config file to start from:
#			make .config
#		Then adapt the .config to your needs.
#		This is convenient as these settings will probably stay the same
#		during development
#	2. from the commandline by using:
#			make VARNAME=value
# 		example:
# 			make hex MCU=atmega48
# 			make flash ISP=dragon_isp
###############################################################################

# USBASP Firmware revision numbers
# this gets stuffed into the USB DEVICE version field
# These values must be specified as decimal values.
# Minor revisions lower than 9 should have a leading 0 if you want them
# printed as #.0# vs #.#
USBASP_FWREV_MAJ:=1
USBASP_FWREV_MIN:=06

# The target MCU you are currently working with
MCU:=atmega8

# pick your ISP type and port
#
# examples:
# ISP:=bsd          PORT:=/dev/parport0
# ISP:=ponyser      PORT:=/dev/ttyS1
# ISP:=stk500       PORT:=/dev/ttyS1
# ISP:=stk500v2     PORT:=/dev/ttyUSB0
# ISP:=usbasp       PORT:=usb
# ISP:=dragon_isp   PORT:=usb
ISP:=usbasp
PORT:=usb

# The two lines below are for "uisp" and the AVR910 serial programmer connected
# to a Keyspan USB to serial converter to a Mac running Mac OS X.
# Choose your favorite programmer and interface.
SERIAL := `echo /dev/tty.USA19QI*`
UISP := uisp -dprog=$S -dserial=$(SERIAL) -dpart=auto

# output directory
OUT := out
FWBINDIR = ../bin/firmware


###############################################################################
# END of USER defined variables
###############################################################################

# include the optional user configs:
-include .config

# build a default user config:
.config:
	@echo "MCU :=$(MCU)" > $(@)
	@echo "ISP :=$(ISP)" >> $(@)
	@echo "HFUSE :=$(HFUSE)" >> $(@)
	@echo "LFUSE :=$(LFUSE)" >> $(@)
	@echo "USBASP_FWREV_MAJ:=$(USBASP_FWREV_MAJ)" >> $(@)
	@echo "USBASP_FWREV_MIN:=$(USBASP_FWREV_MIN)">> $(@)

# fuses can be overridden, but
# pick default values based on MCU:
ifeq ($(MCU), atmega8)
HFUSE?=0xc9
LFUSE?=0xef
else ifeq ($(MCU), atmega48)
HFUSE?=0xdd
LFUSE?=0xff
# 4k flash device
else ifeq ($(MCU), atmega88)
HFUSE?=0xdd
LFUSE?=0xff
endif

REV := v$(USBASP_FWREV_MAJ).$(USBASP_FWREV_MIN)

# MCU specific copiler flags.
# On 4k parts, disable TPI support to make it fit:

CFLAGS_atmega8  := -mmcu=atmega8
CFLAGS_atmega88 := -mmcu=atmega88
CFLAGS_atmega48 := -mmcu=atmega48 -DUSBASP_CFG_DISABLE_TPI


# get date in YYYY-MM-DD format.
DATE=$(shell date "+%F")

# create defines for USBasp f/w revision that will be used in USB device version
# USB device versions are in BCD so tack on 0x for the conversion from decimal
USBASP_OPTS := -DUSB_CFG_DVERSION_MAJ=0x$(USBASP_FWREV_MAJ) -DUSB_CFG_DVERSION_MIN=0x$(USBASP_FWREV_MIN)

# create "standard" f/w base name to help identify the revision of the code
# this is independent of the target MCU
FW_BNAME:=usbasp-v$(USBASP_FWREV_MAJ).$(USBASP_FWREV_MIN)

# create a "standard" file basname for all files for a given target MCU
# if no f/w basename, then just use mcutype as file basename
ifdef FW_BNAME
FILE_BNAME:=$(FW_BNAME)-$(MCU)
else
FILE_BNAME:=$(MCU)
endif

# hexfile name unless overridden
HEXFILE:=$(OUT)/$(MCU)/$(FILE_BNAME).hex

# 'help' is the default target
help::

COMPILE := avr-gcc -g -Wall -O2 -Iusbdrv -I. # -DDEBUG_LEVEL=2

OBJECTS := usbdrv/usbdrv.o usbdrv/usbdrvasm.o usbdrv/oddebug.o isp.o clock.o tpi.o main.o

# Output the command lines, or not:
ifeq ($(V),)
define pretty
@echo $1
endef
hide := @
else
define pretty
endef
hide :=
endif

# Template of makefile code to generate for one mcu.
# $(1): mcu name
define mcu_template

HEXFILES += $(OUT)/$(1)/usbasp-$(REV)-$(1).hex

DIST_HEXFILES += $(FWBINDIR)/usbasp-$(REV)/usbasp-$(REV)-$(1).hex
$(FWBINDIR)/usbasp-$(REV)/usbasp-$(REV)-$(1).hex: $(OUT)/$(1)/usbasp-$(REV)-$(1).hex
	@mkdir -p $$(dir $$(@))
	cp $$< $$@

DATE_DIST_HEXFILES += $(FWBINDIR)/usbasp-$(REV)-$(DATE)/usbasp-$(REV)-$(DATE)-$(1).hex
$(FWBINDIR)/usbasp-$(REV)-$(DATE)/usbasp-$(REV)-$(DATE)-$(1).hex: $(OUT)/$(1)/usbasp-$(REV)-$(1).hex
	@mkdir -p $$(dir $$(@))
	cp $$< $$@

OBJECTS_$(1) := $(addprefix $(OUT)/$(1)/,$(OBJECTS))
DEPENDENCIES += $(patsubst %.o,%.d,$(addprefix $(OUT)/$(1)/,$(OBJECTS)))

$(OUT)/$(1)/%.o: %.c
	@mkdir -p $$(dir $$@)
	$(call pretty,"CC: $$@")
	$(hide) $$(COMPILE) $$(CFLAGS_$(1)) $(USBASP_OPTS) -MD -c $$< -o $$@

$(OUT)/$(1)/%.o: %.S
	@mkdir -p $(dir $$@)
	$(call pretty,"AS: $$@")
	$(hide) $(COMPILE) $(CFLAGS_$(1)) $(USBASP_OPTS) -MD -c $$< -o $$@

$(OUT)/$(1)/%.i: %.c
	$(call pretty,"CPP: $$@")
	@mkdir -p $$(dir $$@)
	$(hide) $(COMPILE) $(CFLAGS_$(1)) $(USBASP_OPTS) -dD -E -c $$< -o $$@

$(OUT)/$(1)/%.i: %.S
	@mkdir -p i$(dir $$@)
	$(call pretty,"CPP: $$@")
	$(hide) $(COMPILE) $(CFLAGS_$(1)) $(USBASP_OPTS) -dD -E -c $$< -o $$@

$(OUT)/$(1)/usbasp-$(REV)-$(1).elf: $$(OBJECTS_$(1))
	@mkdir -p $$(dir $$@)
	$(call pretty,"LD: $$@")
	$(hide) $(COMPILE) $(CFLAGS_$(1)) $(USBASP_OPTS) -o $$@ $$^ -Wl,-Map,$$@.map

endef

# Instantiate the above template for each mcu:
$(foreach mcu,$(MCUS),$(eval $(call mcu_template,$(mcu))))

-include $(DEPENDENCIES)

%.hex: %.elf
	$(call pretty,"OBJCOPY: $@")
	$(hide) avr-objcopy -j .text -j .data -O ihex $< $@

%.lss: %.elf
	$(call pretty,"OBJDUMP: $@")
	$(hide) avr-objdump -h -S $< > $@

%.lst: %.elf
	$(call pretty,"OBJDUMP: $@")
	$(hide) avr-objdump -d $< > $@


all: $(HEXFILES) $(HEXFILES:.hex=.lss) $(HEXFILES:.hex=.lst)

hex: $(HEXFILE) $(HEXFILE:.hex=.lss) $(HEXFILE:.hex=.lst)

flash: $(HEXFILE)
	avrdude -c ${ISP} -p ${MCU} -P ${PORT} -U flash:w:$(HEXFILE)

fuses:
	avrdude -c ${ISP} -p ${MCU} -P ${PORT} -u -U hfuse:w:$(HFUSE):m -U lfuse:w:$(LFUSE):m

avrdude:
	avrdude -c ${ISP} -p ${MCU} -P ${PORT} -v

uisp:	$(HEXFILE)
	$(UISP) --erase
	$(UISP) --upload --verify if=$<

# clean up "trash" files
clean:
	rm -rf $(OUT)

# phony targets to move all hex images into a distribution directory named by rev & date
# after the files are created you can add the directory to the repo and commit it.
# NOTE:
# It is important that you do a "make clean" before any of the "dist" targets
# to ensure you only get the desired .hex files.

hexdist: $(DIST_HEXFILES)

datehexdist: all $(DATE_DIST_HEXFILES)

# debug target for date testing
date:
	@echo The date is $(DATE)

help::
	@echo "Usage: make                same as make help"
	@echo "       make help           same as make"
	@echo "       make all            build hex files for all mcu's"
	@echo "The following make targets below operate on a single MCU target device"
	@echo "       make flash          upload HEXFILE into target device with avrdude"
	@echo "       make fuses          program fuses"
	@echo "Other useful make targets"
	@echo "       make avrdude        test avrdude"
	@echo "       make clean          remove redundant files"
	@echo "To see the pre processor output, e.g.:"
	@echo "       make out/atmega8/isp.i"
	@echo "On these targets make sure to do a \"make clean\" first:"
	@echo "       make hexdist        build & move .hex files to distribution directory"
	@echo "       make datehexdist    build & move dated .hex files to distribution directory"
	@echo ""
	@echo "Current values:"
	@echo "       MCU=${MCU}"
	@echo "       LFUSE=${LFUSE}"
	@echo "       HFUSE=${HFUSE}"
	@echo "       CLOCK=12000000"
	@echo "       ISP=${ISP}"
	@echo "       PORT=${PORT}"
	@echo "       HEXFILE=${HEXFILE}"
	@echo ""
	@echo "All values above (other than CLOCK) can be overridden"
	@echo "To override a value:"
	@echo "    - make .config and adapt the .config file."
	@echo "    - or use VALUENAME=value on commandline"
	@echo "Each known MCU type includes default values for fuses that can be overidden."
	@echo "Examples:"
	@echo "       make help MCU=mcutype"
	@echo "       make fuses MCU=atmega48"
	@echo "       make MCU=atmega48"
	@echo "       make flash MCU=atmega48"
	@echo "       make flash MCU=atmega88 ISP=dragon_isp"
	@echo "       make flash ISP=usbtiny"
	@echo "       make fuses MCU=atmega88 LFUSE=LfuseValue HFUSE=HfuseValue"
	@echo "       make flash HEXFILE=anyprebuilt.hex MCU=mcuOfHexfile"
	@echo "See GNMakefile for further details"
