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
# Any of these values can be ovridden.
#	1. from a config.mk config configuration file
#               (created automatically, but is ignored by git)
#		edit the config file to your needs.
#		You can also set values in the config file by specifying them
#		to update a config file:
#			make config VARNAME=value
#		example:
#			make config MCU=atmega48 ISP=dragon_ISP
#
#		Use of config file is convenient as these settings will typically
#		stay the same during development
#
#	2. from the commandline for a single invocation of make by using:
#			make VARNAME=value
# 		example:
# 			make hex MCU=atmega48
# 			make flash ISP=dragon_isp
#		commandline variables will override the config file
#
# To remove the config file and start fresh:
#	'make mrproper' or 'make distclean'
#
###############################################################################

# USBASP Firmware revision numbers
# this gets stuffed into the USB DEVICE version field
# These values must be specified as decimal values.
# Minor revisions lower than 9 should have a leading 0 if you want them
# printed as #.0# vs #.#
USBASP_FWREV_MAJ := 1
USBASP_FWREV_MIN := 06

# The target MCU you are currently working with
MCU := atmega8

# pick your ISP type and port
#
# examples:
# ISP:=bsd          PORT:=/dev/parport0
# ISP:=ponyser      PORT:=/dev/ttyS1
# ISP:=stk500       PORT:=/dev/ttyS1
# ISP:=stk500v2     PORT:=/dev/ttyUSB0
# ISP:=usbasp       PORT:=usb
# ISP:=usbtiny      PORT:=usb
# ISP:=dragon_isp   PORT:=usb
ISP := usbasp
PORT := usb

# The two lines below are for "uisp" and the AVR910 serial programmer connected
# to a Keyspan USB to serial converter to a Mac running Mac OS X.
# Choose your favorite programmer and interface.
SERIAL := `echo /dev/tty.USA19QI*`
UISP := uisp -dprog=$S -dserial=$(SERIAL) -dpart=auto

# output directory
OUT := out

# where distribution images are stored
FW_BINDIR = ../bin/firmware


###############################################################################
# END of USER defined variables
###############################################################################

# 'help' is the default target
help::

CONFIGFILE = config.mk
# include the user config file:
-include $(CONFIGFILE)

# build a user config file
# The ifdef on fuses is used to allow MCU overrides to use default fuse values
# from the makefile so you can do 'make fuses MCU=xxx' even when there is a
# config file for a different MCU and get the default fuses for MCU 'xxx'
# which would be the expected behavior.
# note: "echo -n" was avoided since it depends on shell and if make decides
# to use its own internal "echo" which does not support -n
# Best to avoid depending on echo -n working.
$(CONFIGFILE) config:
	@echo "# default variable values" > $(CONFIGFILE)
	@echo "MCU := $(MCU)" >> $(CONFIGFILE)
	@echo "# fuses use default values (below) unless explicitly overridden" >> $(CONFIGFILE)
ifdef HFUSE
	@echo "HFUSE := $(HFUSE)" >> $(CONFIGFILE)
else
	@echo "#HFUSE := $(HFUSE)" >> $(CONFIGFILE)
endif
ifdef LFUSE
	@echo "LFUSE := $(LFUSE)" >> $(CONFIGFILE)
else
	@echo "#LFUSE := $(LFUSE)" >> $(CONFIGFILE)
endif
	@echo "# avrdude defaults:" >> $(CONFIGFILE)
	@echo "ISP := $(ISP)" >> $(CONFIGFILE)
	@echo "PORT := $(PORT)" >> $(CONFIGFILE)
	@echo "# USBASP version:">> $(CONFIGFILE)
	@echo "USBASP_FWREV_MAJ := $(USBASP_FWREV_MAJ)" >> $(CONFIGFILE)
	@echo "USBASP_FWREV_MIN := $(USBASP_FWREV_MIN)">> $(CONFIGFILE)
	@echo "# Verbose enable for make output(set to any value to enable)">> $(CONFIGFILE)
	@echo "V := $(V)">> $(CONFIGFILE)

# pick default fuse values based on MCU if not overridden
# by commandline or config file
ifeq ($(MCU), atmega8)
HFUSE ?= 0xc9
LFUSE ?= 0xef
else ifeq ($(MCU), atmega48)
HFUSE ?= 0xdd
LFUSE ?= 0xff
# 4k flash device
else ifeq ($(MCU), atmega88)
HFUSE ?= 0xdd
LFUSE ?= 0xff
endif


REV := v$(USBASP_FWREV_MAJ).$(USBASP_FWREV_MIN)

# MCU specific compiler flags.
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
FW_BASENAME:=usbasp-$(REV)

# default hexfile name unless overridden
HEXFILE:=$(OUT)/$(MCU)/$(FW_BASENAME)-$(MCU).hex

COMPILE := avr-gcc -g -Wall -O2 -Iusbdrv -I. -fdata-sections -ffunction-sections -Wl,--gc-sections # -DDEBUG_LEVEL=2

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

HEXFILES += $(OUT)/$(1)/$(FW_BASENAME)-$(1).hex

NODATE_DIST_HEXFILES += $(FW_BINDIR)/$(FW_BASENAME)/$(FW_BASENAME)-$(1).hex
$(FW_BINDIR)/$(FW_BASENAME)/$(FW_BASENAME)-$(1).hex: $(OUT)/$(1)/$(FW_BASENAME)-$(1).hex
	$(hide) mkdir -p $$(dir $$(@))
	cp $$< $$@

DATE_DIST_HEXFILES += $(FW_BINDIR)/$(FW_BASENAME)-$(DATE)/$(FW_BASENAME)-$(DATE)-$(1).hex
$(FW_BINDIR)/$(FW_BASENAME)-$(DATE)/$(FW_BASENAME)-$(DATE)-$(1).hex: $(OUT)/$(1)/$(FW_BASENAME)-$(1).hex
	$(hide) mkdir -p $$(dir $$(@))
	cp $$< $$@

OBJECTS_$(1) := $(addprefix $(OUT)/$(1)/,$(OBJECTS))
DEPENDENCIES += $(patsubst %.o,%.d,$(addprefix $(OUT)/$(1)/,$(OBJECTS)))

# all objects depend on config file and makefile
$$(OBJECTS_$(1)): $(CONFIGFILE) GNUmakefile

$(OUT)/$(1)/%.o: %.c
	$(hide) mkdir -p $$(dir $$@)
	$(call pretty,"CC: $$@")
	$(hide) $$(COMPILE) $$(CFLAGS_$(1)) $(USBASP_OPTS) -MD -c $$< -o $$@

$(OUT)/$(1)/%.o: %.S
	$(hide) mkdir -p $(dir $$@)
	$(call pretty,"AS: $$@")
	$(hide) $(COMPILE) $(CFLAGS_$(1)) $(USBASP_OPTS) -MD -c $$< -o $$@

$(OUT)/$(1)/%.i: %.c
	$(call pretty,"CPP: $$@")
	$(hide) mkdir -p $$(dir $$@)
	$(hide) $(COMPILE) $(CFLAGS_$(1)) $(USBASP_OPTS) -dD -E -c $$< -o $$@

$(OUT)/$(1)/%.i: %.S
	$(hide) mkdir -p i$(dir $$@)
	$(call pretty,"CPP: $$@")
	$(hide) $(COMPILE) $(CFLAGS_$(1)) $(USBASP_OPTS) -dD -E -c $$< -o $$@

$(OUT)/$(1)/$(FW_BASENAME)-$(1).elf: $$(OBJECTS_$(1))
	$(hide) mkdir -p $$(dir $$@)
	$(call pretty,"LD: $$@")
	$(hide) $(COMPILE) $(CFLAGS_$(1)) $(USBASP_OPTS) -o $$@ $$^ -Wl,-Map,$$(basename $$@).map

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

# start clean by removing everything including config file
distclean mrproper: clean
	rm -rf $(CONFIGFILE)

# targets to move all hex images into a distribution directory named by rev & date
# after the files are created you can add directory to the repo and commit it.

nodatehexdist: $(NODATE_DIST_HEXFILES)

hexdist datehexdist: all $(DATE_DIST_HEXFILES)

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
	@echo "       make mrproper       remove all files including config file"
	@echo "       make distclean      same as 'mrproper'"
	@echo "       make hexdist        build & move dated .hex files to distribution dir"
	@echo "       make nodatehexdist  build & move non-dated .hex files to distribution dir"
	@echo "To see the pre processor output, e.g.:"
	@echo "       make out/atmega8/isp.i"
	@echo ""
	@echo "Current values:"
	@echo "       MCU=${MCU}"
	@echo "       LFUSE=${LFUSE}"
	@echo "       HFUSE=${HFUSE}"
	@echo "       CLOCK=12000000"
	@echo "       ISP=${ISP}"
	@echo "       PORT=${PORT}"
	@echo "       HEXFILE=${HEXFILE}"
ifdef V
	@echo "       V=${V} (verbose mode)"
endif
	@echo ""
	@echo "All values above (other than CLOCK) can be overridden"
	@echo "To override a value:"
	@echo "    - 'make config' and mauually adapt/edit the $(CONFIGFILE) file."
	@echo "    - or 'make config VALUENAME=value' to set value in $(CONFIGFILE)"
	@echo "    - or use VALUENAME=value' on commandline for single invocation"
	
	@echo "Each known MCU type includes default fuse values that can be overidden."
	@echo "Examples:"
	@echo "       make help MCU=mcutype"
	@echo "       make fuses MCU=atmega88"
	@echo "       make flash MCU=atmega48"
	@echo "       make config MCU=atmega48"
	@echo "       make config MCU=atmega88 ISP=dragon_isp"
	@echo "       make flash ISP=usbtiny"
	@echo "       make fuses MCU=atmega88 LFUSE=LfuseValue HFUSE=HfuseValue"
	@echo "       make flash HEXFILE=anyprebuilt.hex MCU=mcuOfHexfile"
	@echo "See GNMakefile for further details"
