#include <stdio.h>
#include <stdlib.h>

#include "arg.h"

char *argv0;

int
main(int argc, char *argv[])
{
	char *f;

	printf("%s", argv[0]);

	ARGBEGIN {
	case 'b':
		printf(" -b");
		break;
	case 'f':
		printf(" -f(%s)", (f=ARGF())? f: "no arg");
		break;
	default:
		printf(" badflag('%c')", ARGC());
	} ARGEND

	printf(" %d args:", argc);

	while (*argv)
		printf(" '%s'", *argv++);
	printf("\n");

	exit(EXIT_SUCCESS);
}
