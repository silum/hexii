#include <err.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "arg.h"

char *argv0;

void usage(void);

int
main(int argc, char *argv[])
{
	ARGBEGIN {
	default: usage();
	} ARGEND

	if (NULL != argv0
	    && 0 == strcmp(argv0, "./test_argv0_unset")) {
		exit(EXIT_SUCCESS);
	} else {
		errx(EXIT_FAILURE, "argv0: %s", argv0);
	}
}

void
usage(void)
{
	fprintf(stderr, "usage: %s\n", argv0);
	exit(EXIT_FAILURE);
}
