/*	$NetBSD: str.c,v 1.2 2003/01/06 04:34:17 jschauma Exp $	*/

#if 0
#include <sys/cdefs.h>
#ifndef lint
#if 0
static const char *rcsid = "Id: str.c,v 1.5 1997/10/08 07:48:21 charnier Exp";
#else
__RCSID("$NetBSD: str.c,v 1.2 2003/01/06 04:34:17 jschauma Exp $");
#endif
#endif
#endif

/*
 * FreeBSD install - a package for the installation and maintainance
 * of non-core utilities.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * Jordan K. Hubbard
 * 18 July 1993
 *
 * Miscellaneous string utilities.
 *
 */
#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#ifdef HAVE_ASSERT_H
#include <assert.h>
#endif

#ifdef HAVE_ERR_H
#include <err.h>
#endif

#ifdef HAVE_FNMATCH_H
#include <fnmatch.h>
#endif

#ifdef HAVE_LIMITS_H
#include <limits.h>
#endif

#include "lib.h"

/*
 * Return the suffix portion of a path
 */
const char *
suffix_of(const char *str)
{
	const char *dot;

	return ((dot = strrchr(basename_of(str), '.')) == NULL) ? "" : dot + 1;
}

/*
 * Return the filename portion of a path
 */
const char *
basename_of(const char *str)
{
	const char *slash;

	return ((slash = strrchr(str, '/')) == NULL) ? str : slash + 1;
}

/*
 * Return the dirname portion of a path
 */
const char *
dirname_of(const char *path)
{
	size_t  cc;
	char   *s;
	static char buf[PATH_MAX];

	if ((s = strrchr(path, '/')) == NULL) {
		return ".";
	}
	if (s == path) {
		/* "/foo" -> return "/" */
		return "/";
	}
	cc = (size_t) (s - path);
	if (cc >= sizeof(buf))
		errx(EXIT_FAILURE, "dirname_of: too long dirname: '%s'", path);
	(void) memcpy(buf, path, cc);
	buf[cc] = 0;
	return buf;
}

/*
 * Get a string parameter as a file spec or as a "contents follow -" spec
 */
char   *
get_dash_string(char **s)
{
	return *s = (**s == '-') ? strdup(*s + 1) : fileGetContents(*s);
}

/*
 * Lowercase a whole string
 */
void
str_lowercase(char *s)
{
	for (; *s; s++) {
		*s = tolower(*s);
	}
}

/* pull in definitions and macros for resizing arrays as we go */
#include "defs.h"

/* do not modify these values, or things will NOT work */
enum {
        RC = -1,
        Dot = 0,
        Patch = 1
};

/* this struct defines a version number */
typedef struct arr_t {
	unsigned	c;              /* # of version numbers */
	unsigned	size;           /* size of array */
	int64_t        *v;              /* array of decimal numbers */
	int64_t		netbsd;         /* any "nb" suffix */
} arr_t;

/* this struct describes a test */
typedef struct test_t {
	const char     *s;              /* string representation */
	unsigned	len;            /* length of string */
	int		t;              /* enumerated type of test */
} test_t;

enum {
	LT,
	LE,
	EQ,
	GE,
	GT,
	NE
};

/* the tests that are recognised. */
static const test_t   tests[] = {
        {	"<=",	2,	LE	},
        {	"<",	1,	LT	},
        {	">=",	2,	GE	},
        {	">",	1,	GT	},
        {	"==",	2,	EQ	},
        {	"!=",	2,	NE	},
        {	NULL,	0,	0	}
};


/* locate the test in the tests array */
static int
mktest(int *op, char *test)
{
	const test_t *tp;

	for (tp = tests ; tp->s ; tp++) {
		if (strncasecmp(test, tp->s, tp->len) == 0) {
			*op = tp->t;
			return tp->len;
		}
	}
	warnx("relational test not found `%.10s'", test);
	return -1;
}

/*
 * make a component of a version number.
 * '.' encodes as Dot which is '0'
 * '_' encodes as 'patch level', or 'Dot', which is 0.
 * 'pl' encodes as 'patch level', or 'Dot', which is 0.
 * 'rc' encodes as 'release candidate', or RC, which is -1.
 * 'nb' encodes as 'netbsd version', which is used after all other tests
 */
static int
mkcomponent(arr_t *ap, char *num)
{
	static const char       alphas[] = "abcdefghijklmnopqrstuvwxyz";
	int64_t                 n;
	char                   *cp;

	if (*num == 0) {
		return 0;
	}
	ALLOC(int64_t, ap->v, ap->size, ap->c, 62, "mkver", exit(EXIT_FAILURE));
	if (*num == '_') {
		num += 1;
		if (isdigit(*(num + 1))) {
			ap->v[ap->c++] = Dot;
			return 1;
		}
	}
	if (isdigit(*num)) {
		for (cp = num, n = 0 ; isdigit(*num) ; num++) {
			n = (n * 10) + (*num - '0');
		}
		ap->v[ap->c++] = n;
		return (int)(num - cp);
	}
	if (strncasecmp(num, "rc", 2) == 0) {
		ap->v[ap->c++] = RC;
		return 2;
	}
	if (strncasecmp(num, "pl", 2) == 0) {
		ap->v[ap->c++] = Dot;
		return 2;
	}
	if (strncasecmp(num, "nb", 2) == 0) {
		for (cp = num, num += 2, n = 0 ; isdigit(*num) ; num++) {
			n = (n * 10) + (*num - '0');
		}
		ap->netbsd = n;
		return (int)(num - cp);
	}
	if (*num == '.') {
		ap->v[ap->c++] = Dot;
		return 1;
	}
	if (isalpha(*num)) {
		ap->v[ap->c++] = Dot;
		cp = strchr(alphas, tolower(*num));
		ALLOC(int64_t, ap->v, ap->size, ap->c, 62, "mkver", exit(EXIT_FAILURE));
		ap->v[ap->c++] = (int64_t)(cp - alphas) + 1;
		return 1;
	}
	warnx("`%c' not recognised", *num);
	return 1;
}

/* make a version number string into an array of comparable 64bit ints */
static int
mkversion(arr_t *ap, char *num)
{
	(void) memset(ap, 0, sizeof(arr_t));
	while (*num) {
		num += mkcomponent(ap, num);
	}
	return 1;
}

#define DIGIT(v, c, n) (((n) < (c)) ? v[n] : 0)

/* compare the result against the test we were expecting */
static int
result(int64_t cmp, int tst)
{
	switch(tst) {
	case LT:
		return cmp < 0;
	case LE:
		return cmp <= 0;
	case GT:
		return cmp > 0;
	case GE:
		return cmp >= 0;
	case EQ:
		return cmp == 0;
	case NE:
		return cmp != 0;
	default:
		warnx("result: unknown test %d", tst);
		return 0;
	}
}

/* do the test on the 2 vectors */
static int
vtest(arr_t *lhs, int tst, arr_t *rhs)
{
	int64_t cmp;
	int     c;
	int     i;

	for (i = 0, c = MAX(lhs->c, rhs->c) ; i < c ; i++) {
		if ((cmp = DIGIT(lhs->v, lhs->c, i) - DIGIT(rhs->v, rhs->c, i)) != 0) {
			return result(cmp, tst);
		}
	}
	return result(lhs->netbsd - rhs->netbsd, tst);
}

/*
 * Compare two dewey decimal numbers
 */
static int
deweycmp(char *lhs, int op, char *rhs)
{
	arr_t	right;
	arr_t	left;

	(void) memset(&left, 0, sizeof(left));
	if (!mkversion(&left, lhs)) {
		warnx("Bad lhs version `%s'", lhs);
		return 0;
	}
	(void) memset(&right, 0, sizeof(right));
	if (!mkversion(&right, rhs)) {
		warnx("Bad rhs version `%s'", rhs);
		return 0;
	}
        return vtest(&left, op, &right);
}

/*
 * Perform alternate match on "pkg" against "pattern",
 * calling pmatch (recursively) to resolve any other patterns.
 * Return 1 on match, 0 otherwise
 */
static int
alternate_match(const char *pattern, const char *pkg)
{
	char   *sep;
	char    buf[FILENAME_MAX];
	char   *last;
	char   *alt;
	char   *cp;
	int     cnt;
	int     found;

	if ((sep = strchr(pattern, '{')) == (char *) NULL) {
		errx(EXIT_FAILURE, "alternate_match(): '{' expected in `%s'", pattern);
	}
	(void) strncpy(buf, pattern, (size_t) (sep - pattern));
	alt = &buf[sep - pattern];
	last = (char *) NULL;
	for (cnt = 0, cp = sep; *cp && last == (char *) NULL; cp++) {
		if (*cp == '{') {
			cnt++;
		} else if (*cp == '}' && --cnt == 0 && last == (char *) NULL) {
			last = cp + 1;
		}
	}
	if (cnt != 0) {
		errx(EXIT_FAILURE, "Malformed alternate `%s'", pattern);
	}
	for (found = 0, cp = sep + 1; *sep != '}'; cp = sep + 1) {
		for (cnt = 0, sep = cp; cnt > 0 || (cnt == 0 && *sep != '}' && *sep != ','); sep++) {
			if (*sep == '{') {
				cnt++;
			} else if (*sep == '}') {
				cnt--;
			}
		}
		(void) snprintf(alt, sizeof(buf) - (alt - buf), "%.*s%s", (int) (sep - cp), cp, last);
		if (pmatch(buf, pkg) == 1) {
			found = 1;
		}
	}
	return found;
}

/*
 * Perform dewey match on "pkg" against "pattern".
 * Return 1 on match, 0 otherwise
 */
static int
dewey_match(const char *pattern, const char *pkg)
{
	char   *cp;
	char   *sep;
	char   *ver;
	char    name[FILENAME_MAX];
	int	op;
	int     n;

	if ((sep = strpbrk(pattern, "<>")) == NULL) {
		errx(EXIT_FAILURE, "dewey_match(): '<' or '>' expected in `%s'", pattern);
	}
	(void) snprintf(name, sizeof(name), "%.*s", (int) (sep - pattern), pattern);
        if ((n = mktest(&op, sep)) < 0) {
                warnx("Bad comparison `%s'", sep);
		return 0;
        }
	ver = sep + n;
	n = (int) (sep - pattern);
	if ((cp = strrchr(pkg, '-')) != (char *) NULL) {
		if (strncmp(pkg, name, (size_t) (cp - pkg)) == 0 &&
		    n == (int)(cp - pkg)) {
			if (deweycmp(cp + 1, op, ver)) {
				return 1;
			}
		}
	}
	return 0;
}

/*
 * Perform glob match on "pkg" against "pattern".
 * Return 1 on match, 0 otherwise
 */
static int
glob_match(const char *pattern, const char *pkg)
{
	return fnmatch(pattern, pkg, FNM_PERIOD) == 0;
}

/*
 * Perform simple match on "pkg" against "pattern". 
 * Return 1 on match, 0 otherwise
 */
static int
simple_match(const char *pattern, const char *pkg)
{
	return strcmp(pattern, pkg) == 0;
}

/*
 * Match pkg against pattern, return 1 if matching, 0 else
 */
int
pmatch(const char *pattern, const char *pkg)
{
	if (strchr(pattern, '{') != (char *) NULL) {
		/* emulate csh-type alternates */
		return alternate_match(pattern, pkg);
	}
	if (strpbrk(pattern, "<>") != (char *) NULL) {
		/* perform relational dewey match on version number */
		return dewey_match(pattern, pkg);
	}
	if (strpbrk(pattern, "*?[]") != (char *) NULL) {
		/* glob match */
		return glob_match(pattern, pkg);
	}
	
	/* no alternate, dewey or glob match -> simple compare */
	return simple_match(pattern, pkg);
}

/*
 * Search dir for pattern, calling match(pkg_found, data) for every match.
 * Returns -1 on error, 1 if found, 0 otherwise.
 */
int
findmatchingname(const char *dir, const char *pattern, matchfn match, void *data)
{
	struct dirent *dp;
	char tmp_pattern[PKG_PATTERN_MAX];
	DIR    *dirp;
	int     found;
	char pat_sfx[PKG_SUFFIX_MAX], file_sfx[PKG_SUFFIX_MAX];	/* suffixes */

	if (strlen(pattern) >= PKG_PATTERN_MAX)
		errx(EXIT_FAILURE, "too long pattern '%s'", pattern);

	found = 0;
	if ((dirp = opendir(dir)) == (DIR *) NULL) {
		/* warnx("can't opendir dir '%s'", dir); */
		return -1;
	}

	/* chop any possible suffix off of 'pattern' and
	 * store it in pat_sfx
	 */
	strip_txz(tmp_pattern, pat_sfx, pattern);
	
	while ((dp = readdir(dirp)) != (struct dirent *) NULL) {
		char    tmp_file[FILENAME_MAX];
		
		if (strcmp(dp->d_name, ".") == 0 ||
		    strcmp(dp->d_name, "..") == 0)
			continue;

		/* chop any possible suffix off of 'tmp_file' and
		 * store it in file_sfx
		 */
		strip_txz(tmp_file, file_sfx, dp->d_name);
		
		/* we need to match pattern and suffix separately, in case
		 * each is a different pattern class (e.g. dewey and
		 * character class (.t[bg]z)) */
		if (pmatch(tmp_pattern, tmp_file)
		    && pmatch(pat_sfx, file_sfx)) {
			if (match) {
				match(dp->d_name, data);
				/* return value ignored for now */
			}
			found = 1;
		}
	}
	(void) closedir(dirp);
	return found;
}

/*
 * Does the pkgname contain any of the special chars ("{[]?*<>")? 
 * If so, return 1, else 0
 */
int
ispkgpattern(const char *pkg)
{
	return strpbrk(pkg, "<>[]?*{") != NULL;
}

/*
 * Auxiliary function called by findbestmatchingname() if pkg > data
 * Also called for FTP matching
 */
int
findbestmatchingname_fn(const char *found, void *vp)
{
	char *best = vp;
	char *found_version, *best_version;
	char found_no_sfx[PKG_PATTERN_MAX];
	char best_no_sfx[PKG_PATTERN_MAX];

	/* The same suffix-hack-off again, but we can't do it
	 * otherwise without changing the function call interface
	 */
	found_version = strrchr(found, '-');
	if (found_version) {
		/* skip '-', if any version found */
		found_version++;
	}
	strip_txz(found_no_sfx, NULL, found_version);
	found_version = found_no_sfx;
	
	best_version=NULL;
	if (best && best[0] != '\0') {
		best_version = strrchr(best, '-');
		if (best_version) {
			/* skip '-' if any version found */
			best_version++;
		}
		strip_txz(best_no_sfx, NULL, best_version);
		best_version = best_no_sfx;
	}

	if (found_version == NULL) {
		fprintf(stderr, "'%s' is not a usable package(version)\n",
			found);
	} else {
		/* if best_version==NULL only if best==NULL
		 * (or best[0]='\0') */
		if (best == NULL || best[0] == '\0' || deweycmp(found_version, GT, best_version)) {
			/* found pkg(version) is bigger than current "best"
			 * version - remember! */
			strcpy(best, found);
		}
	}

	return 0;
}

/*
 * Find best matching filename, i.e. the pkg with the highest
 * matching(!) version. 
 * Returns pointer to pkg name (which can be free(3)ed),
 * or NULL if no match is available.
 */
char *
findbestmatchingname(const char *dir, const char *pattern)
{
	char    buf[FILENAME_MAX];

	buf[0] = '\0';
	if (findmatchingname(dir, pattern, findbestmatchingname_fn, buf) > 0
	    && buf[0] != '\0') {
		return strdup(buf);
	}
	return NULL;
}

/*
 * Bounds-checking strncpy()
 */
char   *
strnncpy(char *to, size_t tosize, char *from, size_t cc)
{
	size_t  len;

	if ((len = cc) >= tosize - 1) {
		len = tosize - 1;
	}
	(void) strncpy(to, from, len);
	to[len] = 0;
	return to;
}

/*
 * Strip off any .tgz, .tbz or .t[bg]z suffix from fname,
 * and copy into buffer "buf", the suffix is stored in "sfx"
 * if "sfx" is not NULL. If no suffix is found, "sfx" is set
 * to an empty string. 
 */
void
strip_txz(char *buf, char *sfx, const char *fname)
{
	static const char *const suffixes[] = {
		".tgz", ".tbz", ".t[bg]z", 0};
	const char *const *suffixp;
	size_t len;

	len = strlen(fname);
	assert(len < PKG_PATTERN_MAX);

	if (sfx)
		sfx[0] = '\0';

	for (suffixp = suffixes; *suffixp; suffixp++) {
		size_t suffixlen = strlen(*suffixp);

		if (memcmp(&fname[len - suffixlen], *suffixp, suffixlen))
			continue;

		/* matched! */
		memcpy(buf, fname, len - suffixlen);
		buf[len - suffixlen] = 0;
		if (sfx) {
			if (suffixlen >= PKG_SUFFIX_MAX)
				errx(EXIT_FAILURE, "too long suffix '%s'", fname);
			memcpy(sfx, *suffixp, suffixlen+1);
			return;
		}
	}

	/* not found */
	memcpy(buf, fname, len+1);
}

/*
 * Called to see if pkg is already installed as some other version, 
 * note found version in "note".
 */
int
note_whats_installed(const char *found, void *vp)
{
	char *note = vp;

	(void) strlcpy(note, found, FILENAME_MAX);
	return 0;
}

/*
 * alloc lpkg for pkg and add it to list.
 */
int
add_to_list_fn(const char *pkg, void *vp)
{
	lpkg_head_t *pkgs = vp;
	lpkg_t *lpp;
	char fn[FILENAME_MAX];

	snprintf(fn, sizeof(fn), "%s/%s", _pkgdb_getPKGDB_DIR(), pkg);
	if (!isfile(fn)) {	/* might as well use sanity_check() */
		lpp = alloc_lpkg(pkg);
		TAILQ_INSERT_TAIL(pkgs, lpp, lp_link);
	}

	return 0;
}

#ifndef HAVE_STRSEP
/*
 * Get next token from string *stringp, where tokens are possibly-empty
 * strings separated by characters from delim.  
 *
 * Writes NULs into the string at *stringp to end tokens.
 * delim need not remain constant from call to call.
 * On return, *stringp points past the last NUL written (if there might
 * be further tokens), or is NULL (if there are definitely no more tokens).
 *
 * If *stringp is NULL, strsep returns NULL.
 */
char *
strsep(char **stringp, const char *delim)
{
	char *s;
	const char *spanp;
	int c, sc;
	char *tok;

	if ((s = *stringp) == NULL)
		return (NULL);
	for (tok = s;;) {
		c = *s++;
		spanp = delim;
		do {
			if ((sc = *spanp++) == c) {
				if (c == 0)
					s = NULL;
				else
					s[-1] = 0;
				*stringp = s;
				return (tok);
			}
		} while (sc != 0);
	}
	/* NOTREACHED */
}
#endif

#ifndef HAVE_STRLCPY
/*
 * Copy src to string dst of size siz.  At most siz-1 characters
 * will be copied.  Always NUL terminates (unless siz == 0).
 * Returns strlen(src); if retval >= siz, truncation occurred.
 */
size_t
strlcpy(char *dst, const char *src, size_t siz)
{
	char *d = dst;
	const char *s = src;
	size_t n = siz;

	/* Copy as many bytes as will fit */
	if (n != 0 && --n != 0) {
		do {
			if ((*d++ = *s++) == 0)
				break;
		} while (--n != 0);
	}

	/* Not enough room in dst, add NUL and traverse rest of src */
	if (n == 0) {
		if (siz != 0)
			*d = '\0';		/* NUL-terminate dst */
		while (*s++)
			;
	}

	return(s - src - 1);	/* count does not include NUL */
}
#endif
