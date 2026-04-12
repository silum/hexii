/* Released under ISC License
 *
 * Copyright (c) 2021--2026, Deneys S. Maartens.
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
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>

#include "ansi.h"
#include "arg.h"

#define CPRINTF(color, ...) \
	do { \
		printf("%s", ansi_fmt(color)); \
		printf(__VA_ARGS__); \
		printf("%s", ansi_fmt(ANSI_RESET)); \
	} while(0)

#ifndef HEXII_MAX_COLS
#define HEXII_MAX_COLS 0x1000
#endif

char *argv0;

static void addr(int wid, off_t off, unsigned cols);
static const char * ansi_fmt(const char *s);
static void cell(unsigned char c);
static void eof(unsigned addr_wid, off_t off, unsigned cols);
static off_t fsize(int fd);
static void head(int nspace, unsigned cols);
static int hexii(int, unsigned);
static int hexwid(unsigned long x);
static void putescchar(const char c);
static int row(char *buf, ssize_t len, off_t base, off_t off, unsigned addr_wid, unsigned cols);
static void usage(void);
static void version(void);

static struct {
	bool ansi;      /* ANSI output enabled (default: true) */
	bool escape;    /* C escape-char output (default: false) */
	bool hex;       /* hex display mode (default: false) */
	bool lowercase; /* lowercase hex (default: false) */
	bool squash;    /* squash blank lines (default: true) */
	bool verbose;   /* verbose output (default: false) */
	unsigned cols;  /* column count (default: 16) */
} opt = {
	.ansi = true,
	.escape = false,
	.hex = false,
	.lowercase = false,
	.squash = true,
	.verbose = false,
	.cols = 16,
};

int
main(int argc, char *argv[])
{
	ARGBEGIN {
	case 'a':
		opt.ansi = true;
		break;
	case 'A':
		opt.ansi = false;
		break;
	case 'c':
		opt.cols = atoi(EARGF(usage()));
		opt.cols = (opt.cols <= 0) ? 1
		                           : opt.cols;
		opt.cols = (HEXII_MAX_COLS <= opt.cols) ? HEXII_MAX_COLS
		                                        : opt.cols;
		break;
	case 'e':
		opt.escape = true;
		break;
	case 'E':
		opt.escape = false;
		break;
	case 'h':
		opt.hex = true;
		break;
	case 'H':
		opt.hex = false;
		break;
	case 'q':
		opt.verbose = false;
		break;
	case 's':
		opt.squash = true;
		break;
	case 'S':
		opt.squash = false;
		break;
	case 'v':
		opt.verbose = true;
		break;
	case 'V':
		version();
		break;
	case 'x':
		opt.lowercase = true;
		break;
	case 'X':
		opt.lowercase = false;
		break;
	default: usage();
	} ARGEND

	if (!*argv) {
		usage();
	}

	int rval = EXIT_SUCCESS;
	for (; argc; argc--, argv++) {
		const char* fn = *argv;
		const bool is_stdin = '-' == fn[0] && '\0' == fn[1];
		int fd = (is_stdin) ? STDIN_FILENO
		                    : open(fn, O_RDONLY, 0);
		if (fd < 0) {
			warn("%s", fn);
			rval = EXIT_FAILURE;
			continue;
		}
		if (hexii(fd, opt.cols)) {
			warn("%s", (fd == STDIN_FILENO) ? "stdin"
			                                : fn);
			rval = EXIT_FAILURE;
		}
		if (! is_stdin) {
			close(fd);
		}
	}

	exit(rval);
}

static
void
addr(int wid, off_t off, unsigned cols)
{
	static off_t prev = 0;
	off_t xor = off ^ prev;

	int w = wid;
	if (xor != 0 && cols == (off - prev)) {
		w = hexwid(xor);
	}

	off_t modulo = 1UL << (4 * w);  /* 16^w using bit shift */
	off_t val = off % modulo;

	puts("");
	CPRINTF(ANSI_YEL,
	        (w == wid) ? "%0*llx:"
	                   : "%*llX:",
	        wid, (unsigned long long)val);

	prev = off;
}

static
const char *
ansi_fmt(const char *s)
{
	return (opt.ansi) ? s
	                  : "";
}

static
void
cell(unsigned char c)
{
	if (0x00 == c) {
		if (opt.verbose) {
			CPRINTF(ANSI_BBLK, "00");
		} else {
			printf("  ");
		}
	} else if (0xff == c) {
		CPRINTF(ANSI_RED, "%s", (opt.verbose) ? "FF"
		                                      : "##");
	} else if (isprint(c)) {
		CPRINTF(ANSI_CYN,
		        (opt.hex) ? (opt.lowercase) ? "%02x"
		                                    : "%02X"
		                  : ".%c",
		        c);
	} else {
		bool escape = opt.escape;
		if (escape) {
			switch (c) {
			case '\a': putescchar('a'); break;
			case '\b': putescchar('b'); break;
			case '\033': putescchar('e'); break;
			case '\f': putescchar('f'); break;
			case '\n': putescchar('n'); break;
			case '\r': putescchar('r'); break;
			case '\t': putescchar('t'); break;
			case '\v': putescchar('v'); break;
			default: escape = false;
			}
		}
		if (!escape) {
			printf((opt.lowercase) ? "%02x"
			                       : "%02X", c);
		}
	}
}

static
void
eof(unsigned addr_wid, off_t off, unsigned cols)
{
	if (0 == (off % cols)) {
		addr(addr_wid, off, cols);
	}
	putchar(' ');
	CPRINTF(ANSI_BWHT, "]");
	puts("");
}

static
off_t
fsize(int fd)
{
	struct stat st;
	int ret = fstat(fd, &st);
	if (-1 == ret) {
		return ret;
	}

	return st.st_size;
}

static
void
head(int nspace, unsigned cols)
{
	printf("%*s", nspace, " ");
	for (unsigned i = 0; i < cols; i++) {
		CPRINTF(ANSI_YEL, "%3X", i);
	}
	puts("");
}

static
int
hexii(int fd, unsigned cols)
{
	off_t sz = fsize(fd);
	int addr_wid = (sz > 0) ? hexwid(sz)
	                        : 16;
	head(addr_wid + 1, cols);

	char buf[cols];
	size_t wrlen = 0;
	off_t off = 0;
	for (;;) {
		ssize_t len = read(fd, buf, cols);
		if (-1 == len) {
			return 1;
		}
		if (0 == len) {
			eof(addr_wid, off, cols);
			return 0;
		}

		off_t base = wrlen;
		while (off - base < len) {
			int nr = row(buf, len, base, off - base, addr_wid, cols);
			off += nr;
		}
		wrlen += len;
	}
}

static
int
hexwid(unsigned long x)
{
	int w = 1;
	for (; x > 15; x >>= 4) {  /* bit-shift division by 16 (or 1 hex digit) */
		w++;
	}
	return w;
}

static
void
putescchar(const char c)
{
	CPRINTF(ANSI_MAG, "\\%c", c);
}

static
int
row(char *buf, ssize_t len, off_t base, off_t off, unsigned addr_wid, unsigned cols)
{
	bool zeros = true;
	unsigned ncols = (len < off + cols) ? (len - off)
	                                    : cols;
	for (unsigned c = 0; c < ncols && zeros; c++) {
		zeros = ('\0' == buf[off + c]);
	}
	if (zeros && ncols == cols && opt.squash) {
		return cols;
	}

	addr(addr_wid, base + off, cols);

	unsigned i = 0;
	for (; i < ncols; i++) {
		putchar(' ');
		cell(buf[off + i]);
	}

	return ncols;
}

static
void
usage(void)
{
	fprintf(stderr, "usage: %s [-aAeEhHqsSvxX] [-c num] FILE\n", argv0);
	fprintf(stderr, "       %s -V\n", argv0);
	fprintf(stderr, "Maximum columns: %u (compile-time limit)\n", HEXII_MAX_COLS);
	exit(EXIT_FAILURE);
}

static
void
version(void)
{
	printf("%s version 0.2\n", argv0);
	exit(EXIT_SUCCESS);
}
