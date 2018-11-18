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

MKDIR := $(QUIET)mkdir -p
CD := $(QUIET)cd
ECHO := $(QUIET)echo -e
RM := $(QUIET)rm -rf

SRCDIR ?= src

INCDIR ?= include
OBJDIR ?= src

CURDIR := $(notdir $(shell pwd))
EXEC ?= $(CURDIR)
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

MLCMESSAGE=@$(ECHO) "\t MLC \t\t $(notdir $@)"

.PHONY: all clean mrproper

.DEFAULT_GOAL = all

all: $(EXEC)

$(EXEC): $(SRC)
	$(LDMESSAGE)
	$(QUIET)$(LD) -o $@ $^ $(LDFLAGS)

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

mrproper: clean
	rm -f $(EXEC)
