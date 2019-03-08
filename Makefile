############################## MAKEFILE ##############################
#          Author : Enzo Brignon                                     #
######################################################################

-include config.mk
.SECONDEXPANSION:

QUIET?=@
SHELL=/bin/bash
MLC = ocamlopt
AS = $(TARGET)as
AR = ar
VALGRIND = valgrind
LD = ocamlopt
M4=m4

MKDIR := $(QUIET)mkdir -p
CD := $(QUIET)cd
ECHO := $(QUIET)echo -e
RM := $(QUIET)rm -rf

SRCDIR ?= src

INCDIR ?= include
OBJDIR ?= src

CURDIR := $(notdir $(shell pwd))
EXEC ?= $(CURDIR)
# SYMBOLIC ?= ../../$(EXEC)
STATIC := lib$(EXEC).a
DYNAMIC := lib$(CURDIR).so

MLEXT = ml

ALLEXT = $(MLEXT)

SRC = $(foreach VAR, $(ALLEXT), $(wildcard $(addsuffix *.$(VAR), $(SRCDIR)/)))

OBJ := $(foreach EXT, $(ALLEXT), $(patsubst %.$(EXT), %.o, \
                                  $(notdir $(filter %.$(EXT), $(SRC)))))

FLAGS += -Wall
FLAGS += $(DBGFLAGS)
FLAGS += $(addprefix -I, $(INCDIR))

DBGFLAGS := $(OPTLEVEL)

LDMESSAGE=@$(ECHO) "\t MLLD \t\t $(notdir $@)"
MLCMESSAGE=@$(ECHO) "\t MLC \t\t $(notdir $@)"
M4MESSAGE=@$(ECHO) "\t M4 \t\t $(notdir $@)"

include config.mk

.PHONY: all clean mrproper symbolic

.DEFAULT_GOAL = all

all: $(EXEC)

# .pre/%.ml: src/%.ml $$(@D)/.f
# 	$(M4MESSAGE)
# 	$(QUIET)$(M4) -D BRIGHTNESS=$(BRIGHTNESS) -D MAX_BRIGHTNESS=$(MAX_BRIGHTNESS) $< > $@

$(EXEC): $(SRC)
	$(LDMESSAGE)
	$(QUIET)$(LD) -pp "$(M4) -D BRIGHTNESS=$(BRIGHTNESS) -D MAX_BRIGHTNESS=$(MAX_BRIGHTNESS)" -o $@ $^ $(LDFLAGS)

symbolic: $(SYMBOLIC)

$(SYMBOLIC): $(EXEC)
	ln -s $(shell realpath $(EXEC)) $(SYMBOLIC)

%/.f:
	$(QUIET)mkdir -p $(dir $@)
	$(QUIET)touch $@

.PRECIOUS: %/.f %.c .deps/%.d

doxygen:
	$(QUIET)doxygen doc/Doxyfile
	$(QUIET)$(MAKE) -C doc/latex/

clean:
	rm -f $(SRCDIR)/*.cmi
	rm -f $(SRCDIR)/*.cmx
	rm -f $(SRCDIR)/*.o
	rm -rf .pre

mrproper: clean
	rm -f $(EXEC)
