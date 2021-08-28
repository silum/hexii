/* Released under MIT License
 *
 * Copyright (c) 2021 Deneys S. Maartens.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

/* Uses exit() & EXIT_FAILURE (from stdlib.h), and NULL (from stddef.h). */

/* The following files served as inspiration for the code below:
 *
 * - <http://9p.io/sources/plan9/sys/include/libc.h>; last ~23 lines
 */

#ifndef ARG_H
#define ARG_H

#define ARG_H_SET(x)  ((void)(x))

extern char *argv0;
#define ARGBEGIN \
	for ((NULL != argv0 || (argv0 = *argv)), argv++, argc--; \
	     NULL != argv[0] && '-' == argv[0][0] && '\0' != argv[0][1]; \
	     argc--, argv++) { \
		char _argc, *_argt; \
		char *_args = &argv[0][1]; \
		if ('-' == _args[0] && '\0' == _args[1]) { \
			argc--; argv++; break; \
		} \
		_argc = '\0'; \
		while (*_args && (_argc = *_args++)) \
			switch (_argc)
#define ARGEND  ARG_H_SET(_argt);}
#define ARGF() \
	(_argt = _args, _args = "", \
	 (('\0' != *_argt) \
	  ? _argt \
	  : (NULL != argv[1]) \
	    ? (argc--, *++argv) \
	    : 0))
#define EARGF(x) \
	(_argt = _args, _args = "", \
	 (('\0' != *_argt) \
	  ? _argt \
	  : (NULL != argv[1]) \
	    ? (argc--, *++argv) \
	    : ((x), exit(EXIT_FAILURE), (char*)NULL)))

#define ARGC()  _argc

#endif  /* ARG_H */
