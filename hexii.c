/* Released under ISC License
 *
 * Copyright (c) 2021, Deneys S. Maartens.
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
 * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
#include <ctype.h>
#include <err.h>
#include <fcntl.h>
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>

#include "ansi.h"
#include "arg.h"

char *argv0;

static int hexii(int, unsigned);
static void usage(void);
static void version(void);

int
main(int argc, char *argv[])
{
	unsigned cols = 16;
	ARGBEGIN {
	case 'c':
		cols = atoi(EARGF(usage()));
		cols = (cols <= 0) ? 1 : cols;
		break;
	case 'V':
		version();
		break;
	default: usage();
	} ARGEND

	if (!*argv) {
		usage();
	}

	int fd = STDIN_FILENO;
	const char *fn = NULL;
	int rval = EXIT_SUCCESS;
	for (; argc; argc--, argv++) {
		fn = *argv;
		fd = ('-' == fn[0] && '\0' == fn[1])
		     ? STDIN_FILENO
		     : open(fn, O_RDONLY, 0);
		if (fd < 0) {
			warn("%s", fn);
			rval = EXIT_FAILURE;
			continue;
		}
		if (hexii(fd, cols)) {
			warn("%s", fn ? fn : "stdin");
			rval = EXIT_FAILURE;
		}
		close(fd);
	}

	if (++argv, 0 < --argc) {
		errx(EXIT_FAILURE, "unexpected argument: %s", *argv);
	}

	exit(rval);
}

static
void
addr(int wid, int off, int cols)
{
	static int prev = 0;
	int xor = off ^ prev;
	int w = (0 == xor
	         || cols != (off - prev))
	        ? wid
	        : (log(xor) / log(16) + 1);
	int val = off % (int)pow(16, w);

	if (w == wid) {
		printf("\n" ANSI_YEL "%0*X:" ANSI_RESET, wid, val);
	} else {
		printf("\n" ANSI_YEL "%*X:" ANSI_RESET, wid, val);
	}

	prev = off;
}

static
off_t
fsize(int fd)
{
	struct stat stat;
	int ret = fstat(fd, &stat);
	if (-1 == ret) {
		return ret;
	}

	off_t size = stat.st_size;
	return size;
}

static
void
head(int nspace, unsigned cols)
{
	printf("%*s", nspace, " ");
	for (unsigned i = 0; i < cols; i++) {
		printf(ANSI_YEL "%3X" ANSI_RESET, i);
	}
	puts("");
}

static
void
hexii_c(unsigned char c)
{
	if (0x00 == c) {
		printf("  ");
	} else if (0xff == c) {
		printf(ANSI_RED "##" ANSI_RESET);
	} else if (isprint(c) && ' ' != c) {
		printf(ANSI_CYN ".%c" ANSI_RESET, c);
	} else {
		printf("%02X", c);
	}
}

static
int
hexii_r(char *buf, ssize_t len, off_t base, off_t off, unsigned addr_wid, unsigned cols)
{
	bool zeros = true;
	unsigned ncols = (len < off + cols) ? len : cols;
	for (unsigned c = 0; c < ncols && zeros; c++) {
		zeros = ('\0' == buf[off + c]);
	}
	if (zeros && ncols == cols) {
		return cols;
	}

	addr(addr_wid, base + off, cols);

	unsigned i = 0;
	for (; i < cols
	     && off + i < len; i++) {
		putchar(' ');
		hexii_c(buf[off + i]);
	}

	return i;
}

static
int
hexii(int fd, unsigned cols)
{
	off_t sz = fsize(fd);
	int addr_wid = (sz <= 0) ? 16 : (log(sz) / log(16)) + 1;
	head(addr_wid + 1, cols);

	size_t buflen = 8192 - 8192 % cols;
	char buf[buflen];
	off_t off = 0;
	for (int blk = 0;; blk++) {
		ssize_t len = read(fd, buf, buflen);
		if (-1 == len) {
			return 1;
		}
		if (0 == len) {
			if (0 == (off % cols)) {
				addr(addr_wid, off, cols);
			}
			printf(" " ANSI_BWHT "]" ANSI_RESET "\n");
			break;
		}

		off_t base = buflen * blk;
		while (off - base < len) {
			int nr = hexii_r(buf, len, base, off - base, addr_wid, cols);
			off += nr;
		}
	}
	return 0;
}

static
void
usage(void)
{
	fprintf(stderr, "usage: %s [-c num] FILE\n", argv0);
	fprintf(stderr, "       %s -V\n", argv0);
	exit(EXIT_FAILURE);
}

static
void
version(void)
{
	printf("%s version 0.1\n", argv0);
	exit(EXIT_SUCCESS);
}
