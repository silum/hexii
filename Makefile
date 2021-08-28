BIN = hexii

hexii: hexii.o

CFLAGS += -std=c99 -Wall -Wextra -Wpedantic
CPPFLAGS += -I. -Ilib/arg

.PHONY: all
all: $(BIN)

.PHONY: clean
clean:
	$(RM) -- $(BIN) $(TESTS) *.o *.d

.PHONY: distclean
distclean: clean
	$(RM) -- tags cscope.out

ifeq ($(filter-out clean distclean,$(MAKECMDGOALS)),$(MAKECMDGOALS))
    # create .d files
    CPPFLAGS += -MMD
    # include .d files
    include $(wildcard *.d)
endif

# prune some implicit rules to limit rule search
Makefile: ;
%.c %.d %.h: ;

.SUFFIXES:
.SUFFIXES: .o .c
.DEFAULT_GOAL := all
