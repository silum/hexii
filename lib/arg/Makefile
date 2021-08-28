BIN =

VPATH = tests
TESTS = prog test_argv0_set test_argv0_unset
prog: prog.o
test_argv0_set: test_argv0_set.o
test_argv0_unset: test_argv0_unset.o

CFLAGS += -std=c99 -Wall -Wextra -Wpedantic
CPPFLAGS += -I.

.PHONY: all
all: $(BIN)

.PHONY: check
check: tests/test.sh $(TESTS)
	@./$<
	@echo
	@echo ================
	@echo all tests passed
	@echo ================

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
