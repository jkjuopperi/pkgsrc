/*	$NetBSD: perform.c,v 1.71 2008/04/26 14:56:34 joerg Exp $	*/
#if HAVE_CONFIG_H
#include "config.h"
#endif
#include <nbcompat.h>
#if HAVE_SYS_CDEFS_H
#include <sys/cdefs.h>
#endif
__RCSID("$NetBSD: perform.c,v 1.71 2008/04/26 14:56:34 joerg Exp $");

/*-
 * Copyright (c) 2003 Grant Beattie <grant@NetBSD.org>
 * Copyright (c) 2005 Dieter Baron <dillo@NetBSD.org>
 * Copyright (c) 2007 Roland Illig <rillig@NetBSD.org>
 * Copyright (c) 2008 Joerg Sonnenberger <joerg@NetBSD.org>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <sys/utsname.h>
#include <archive.h>
#include <archive_entry.h>
#include <err.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "lib.h"
#include "add.h"

struct pkg_meta {
	char *meta_contents;
	char *meta_comment;
	char *meta_desc;
	char *meta_mtree;
	char *meta_build_version;
	char *meta_build_info;
	char *meta_size_pkg;
	char *meta_size_all;
	char *meta_required_by;
	char *meta_display;
	char *meta_install;
	char *meta_deinstall;
	char *meta_preserve;
	char *meta_views;
	char *meta_installed_info;
};

struct pkg_task {
	const char *pkgname;

	const char *prefix;
	const char *install_prefix;

	char *logdir;
	char *other_version;

	package_t plist;

	struct pkg_meta meta_data;

	struct archive *archive;
	struct archive_entry *entry;

	char *buildinfo[BI_ENUM_COUNT];

	size_t dep_length, dep_allocated;
	char **dependencies;
};

static const struct pkg_meta_desc {
	size_t entry_offset;
	const char *entry_filename;
	int required_file;
	mode_t perm;
} pkg_meta_descriptors[] = {
	{ offsetof(struct pkg_meta, meta_contents), CONTENTS_FNAME, 1, 0644 },
	{ offsetof(struct pkg_meta, meta_comment), COMMENT_FNAME, 1, 0444},
	{ offsetof(struct pkg_meta, meta_desc), DESC_FNAME, 1, 0444},
	{ offsetof(struct pkg_meta, meta_install), INSTALL_FNAME, 0, 0555 },
	{ offsetof(struct pkg_meta, meta_deinstall), DEINSTALL_FNAME, 0, 0555 },
	{ offsetof(struct pkg_meta, meta_display), DISPLAY_FNAME, 0, 0444 },
	{ offsetof(struct pkg_meta, meta_mtree), MTREE_FNAME, 0, 0444 },
	{ offsetof(struct pkg_meta, meta_build_version), BUILD_VERSION_FNAME, 0, 0444 },
	{ offsetof(struct pkg_meta, meta_build_info), BUILD_INFO_FNAME, 0, 0444 },
	{ offsetof(struct pkg_meta, meta_size_pkg), SIZE_PKG_FNAME, 0, 0444 },
	{ offsetof(struct pkg_meta, meta_size_all), SIZE_ALL_FNAME, 0, 0444 },
	{ offsetof(struct pkg_meta, meta_preserve), PRESERVE_FNAME, 0, 0444 },
	{ offsetof(struct pkg_meta, meta_views), VIEWS_FNAME, 0, 0444 },
	{ offsetof(struct pkg_meta, meta_required_by), REQUIRED_BY_FNAME, 0, 0644 },
	{ offsetof(struct pkg_meta, meta_installed_info), INSTALLED_INFO_FNAME, 0, 0644 },
	{ 0, NULL, 0 },
};

static int pkg_do(const char *, int);

static int
mkdir_p(const char *path)
{
	return fexec(MKDIR_CMD, "-p", path, (void *)NULL);	
}

/*
 * Read meta data from archive.
 * Bail out if a required entry is missing or entries are in the wrong order.
 */
static int
read_meta_data(struct pkg_task *pkg)
{
	const struct pkg_meta_desc *descr, *last_descr;
	const char *fname;
	char **target;
	int64_t size;
	int r, found_required;

	found_required = 0;

	last_descr = 0;
	while ((r = archive_read_next_header(pkg->archive, &pkg->entry)) ==
	    ARCHIVE_OK) {
		fname = archive_entry_pathname(pkg->entry);

		for (descr = pkg_meta_descriptors; descr->entry_filename;
		     ++descr) {
			if (strcmp(descr->entry_filename, fname) == 0)
				break;
		}
		if (descr->entry_filename == NULL)
			break;

		if (descr->required_file)
			++found_required;

		target = (char **)((char *)&pkg->meta_data +
		    descr->entry_offset);
		if (*target) {
			warnx("duplicate entry, package corrupt");
			return -1;
		}
		if (descr < last_descr) {
			warnx("misordered package");
			return -1;
		}
		last_descr = descr;

		size = archive_entry_size(pkg->entry);
		if (size > SSIZE_MAX - 1) {
			warnx("package meta data too large to process");
			return -1;
		}
		if ((*target = malloc(size + 1)) == NULL)
			err(2, "cannot allocate meta data");
		if (archive_read_data(pkg->archive, *target, size) != size) {
			warn("cannot read package meta data");
			return -1;
		}
		(*target)[size] = '\0';
	}

	if (r != ARCHIVE_OK)
		pkg->entry = NULL;

	for (descr = pkg_meta_descriptors; descr->entry_filename; ++descr) {
		if (descr->required_file)
			--found_required;
	}

	return !found_required ? 0 : -1;
}

/*
 * Free meta data.
 */
static void
free_meta_data(struct pkg_task *pkg)
{
	const struct pkg_meta_desc *descr;
	char **target;

	for (descr = pkg_meta_descriptors; descr->entry_filename; ++descr) {
		target = (char **)((char *)&pkg->meta_data +
		    descr->entry_offset);
		free(*target);
		*target = NULL;
	}
}

/*
 * Parse PLIST and populate pkg.
 */
static int
pkg_parse_plist(struct pkg_task *pkg)
{
	plist_t *p;

	parse_plist(&pkg->plist, pkg->meta_data.meta_contents);
	if ((p = find_plist(&pkg->plist, PLIST_NAME)) == NULL) {
		warnx("Invalid PLIST: missing @name");
		return -1;
	}
	pkg->pkgname = p->name;
	if ((p = find_plist(&pkg->plist, PLIST_CWD)) == NULL) {
		warnx("Invalid PLIST: missing @cwd");
		return -1;
	}
	/* XXX change first @cwd in PLIST? */
	pkg->prefix = p->name;
	pkg->install_prefix = Prefix != NULL ? Prefix : pkg->prefix;

	return 0;
}

/*
 * Helper function to extract value from a string of the
 * form key=value ending at eol.
 */
static char *
dup_value(const char *line, const char *eol)
{
	const char *key;
	char *val;

	key = strchr(line, '=');
	val = malloc(eol - key);
	if (val == NULL)
		err(2, "malloc failed");
	memcpy(val, key + 1, eol - key - 1);
	val[eol - key - 1] = '\0';
	return val;
}

static int
check_already_installed(struct pkg_task *pkg)
{
	char *filename;
	int fd;

	if (Force)
		return -1;

	filename = pkgdb_pkg_file(pkg->pkgname, CONTENTS_FNAME);
	fd = open(filename, O_RDONLY);
	free(filename);
	if (fd == -1)
		return -1;

	/* We can only arrive here for explicitly requested packages. */
	if (!Automatic && is_automatic_installed(pkg->pkgname)) {
		if (Fake ||
		    mark_as_automatic_installed(pkg->pkgname, 0) == 0)
			warnx("package `%s' was already installed as "
			      "dependency, now marked as installed "
			      "manually", pkg->pkgname);
	} else {
		warnx("package `%s' already recorded as installed",
		      pkg->pkgname);
	}
	return 0;

}

static int
check_other_installed(struct pkg_task *pkg)
{
	FILE *f, *f_pkg;
	size_t len;
	char *pkgbase, *iter, *filename;
	package_t plist;
	plist_t *p;
	int status;

	if ((pkgbase = strdup(pkg->pkgname)) == NULL) {
		warnx("strdup failed");
		return -1;
	}
	if ((iter = strrchr(pkgbase, '-')) == NULL) {
		free(pkgbase);
		warnx("Invalid package name %s", pkg->pkgname);
		return -1;
	}
	*iter = '\0';
	pkg->other_version = find_best_matching_installed_pkg(pkgbase);
	free(pkgbase);
	if (pkg->other_version == NULL)
		return 0;

	if (!Replace) {
		/* XXX This is redundant to the implicit conflict check. */
		warnx("A different version of %s is already installed: %s",
		    pkg->pkgname, pkg->other_version);
		return -1;
	}

	filename = pkgdb_pkg_file(pkg->other_version, REQUIRED_BY_FNAME);
	errno = 0;
	f = fopen(filename, "r");
	free(filename);
	if (f == NULL) {
		if (errno == ENOENT) {
			/* No packages depend on this, so everything is well. */
			return 0; 
		}
		warnx("Can't open +REQUIRED_BY of %s", pkg->other_version);
		return -1;
	}

	status = 0;

	while ((iter = fgetln(f, &len)) != NULL) {
		if (iter[len - 1] == '\n')
			iter[len - 1] = '\0';
		filename = pkgdb_pkg_file(iter, CONTENTS_FNAME);
		if ((f_pkg = fopen(filename, "r")) == NULL) {
			warnx("Can't open +CONTENTS of depending package %s",
			    iter);
			fclose(f);
			return -1;
		}
		plist.head = plist.tail = NULL;
		read_plist(&plist, f_pkg);
		fclose(f_pkg);
		for (p = plist.head; p != NULL; p = p->next) {
			if (p->type == PLIST_IGNORE) {
				p = p->next;
				continue;
			} else if (p->type != PLIST_PKGDEP)
				continue;
			/*
			 * XXX This is stricter than necessary.
			 * XXX One pattern might be fulfilled by
			 * XXX a different package and still need this
			 * XXX one for a different pattern.
			 */
			if (pkg_match(p->name, pkg->other_version) == 0)
				continue;
			if (pkg_match(p->name, pkg->pkgname) == 1)
				continue; /* Both match, ok. */
			warnx("Dependency of %s fulfilled by %s, but not by %s",
			    iter, pkg->other_version, pkg->pkgname);
			if (!Force)
				status = -1;
			break;
		}
		free_plist(&plist);		
	}

	fclose(f);

	return status;
}

/*
 * Read package build information from meta data.
 */
static int
read_buildinfo(struct pkg_task *pkg)
{
	const char *data, *eol, *next_line;

	data = pkg->meta_data.meta_build_info;

	for (; *data != '\0'; data = next_line) {
		if ((eol = strchr(data, '\n')) == NULL) {
			eol = data + strlen(data);
			next_line = eol;
		} else
			next_line = eol + 1;

		if (strncmp(data, "OPSYS=", 6) == 0)
			pkg->buildinfo[BI_OPSYS] = dup_value(data, eol);
		else if (strncmp(data, "OS_VERSION=", 11) == 0)
			pkg->buildinfo[BI_OS_VERSION] = dup_value(data, eol);
		else if (strncmp(data, "MACHINE_ARCH=", 13) == 0)
			pkg->buildinfo[BI_MACHINE_ARCH] = dup_value(data, eol);
		else if (strncmp(data, "IGNORE_RECOMMENDED=", 19) == 0)
			pkg->buildinfo[BI_IGNORE_RECOMMENDED] = dup_value(data,
			    eol);
		else if (strncmp(data, "USE_ABI_DEPENDS=", 16) == 0)
			pkg->buildinfo[BI_USE_ABI_DEPENDS] = dup_value(data,
			    eol);
	}
	if (pkg->buildinfo[BI_OPSYS] == NULL ||
	    pkg->buildinfo[BI_OS_VERSION] == NULL ||
	    pkg->buildinfo[BI_MACHINE_ARCH] == NULL) {
		warnx("Not all required build information are present.");
		return -1;
	}

	if ((pkg->buildinfo[BI_USE_ABI_DEPENDS] != NULL &&
	    strcasecmp(pkg->buildinfo[BI_USE_ABI_DEPENDS], "YES") != 0) ||
	    (pkg->buildinfo[BI_IGNORE_RECOMMENDED] != NULL &&
	    strcasecmp(pkg->buildinfo[BI_IGNORE_RECOMMENDED], "NO") != 0)) {
		warnx("%s was built to ignore ABI dependencies", pkg->pkgname);
	}

	return 0;
}

/*
 * Free buildinfo.
 */
static void
free_buildinfo(struct pkg_task *pkg)
{
	size_t i;

	for (i = 0; i < BI_ENUM_COUNT; ++i) {
		free(pkg->buildinfo[i]);
		pkg->buildinfo[i] = NULL;
	}
}

/*
 * Write meta data files to pkgdb after creating the directory.
 */
static int
write_meta_data(struct pkg_task *pkg)
{
	const struct pkg_meta_desc *descr;
	char *filename, **target;
	size_t len;
	ssize_t ret;
	int fd;

	if (Fake)
		return 0;

	if (mkdir_p(pkg->logdir)) {
		warn("Can't create pkgdb entry: %s", pkg->logdir);
		return -1;
	}

	for (descr = pkg_meta_descriptors; descr->entry_filename; ++descr) {
		target = (char **)((char *)&pkg->meta_data +
		    descr->entry_offset);
		if (*target == NULL)
			continue;
		if (asprintf(&filename, "%s/%s", pkg->logdir,
		    descr->entry_filename) == -1) {
			    warn("asprintf failed");
			    return -1;
		}
		(void)unlink(filename);
		fd = open(filename, O_WRONLY | O_TRUNC | O_CREAT, descr->perm);
		if (fd == -1) {
			warn("Can't open meta data file: %s", filename);
			return -1;
		}
		len = strlen(*target);
		do {
			ret = write(fd, *target, len);
			if (ret == -1) {
				warn("Can't write meta data file: %s",
				    filename);
				free(filename);
				return -1;
			}
			len -= ret;
		} while (ret > 0);
		if (close(fd) == -1) {
			warn("Can't close meta data file: %s", filename);
			free(filename);
			return -1;
		}
		free(filename);
	}

	return 0;
}

/*
 * Helper function for extract_files.
 */
static int
copy_data_to_disk(struct archive *reader, struct archive *writer,
    const char *filename)
{
	int r;
	const void *buff;
	size_t size;
	off_t offset;

	for (;;) {
		r = archive_read_data_block(reader, &buff, &size, &offset);
		if (r == ARCHIVE_EOF)
			return 0;
		if (r != ARCHIVE_OK) {
			warnx("Read error for %s: %s", filename,
			    archive_error_string(reader));
			return -1;
		}
		r = archive_write_data_block(writer, buff, size, offset);
		if (r != ARCHIVE_OK) {
			warnx("Write error for %s: %s", filename,
			    archive_error_string(writer));
			return -1;
		}
	}
}

/*
 * Extract package.
 * Any misordered, missing or unlisted file in the package is an error.
 */

static const int extract_flags = /* ARCHIVE_EXTRACT_OWNER | */
    ARCHIVE_EXTRACT_PERM | ARCHIVE_EXTRACT_TIME | ARCHIVE_EXTRACT_UNLINK |
    ARCHIVE_EXTRACT_ACL | ARCHIVE_EXTRACT_FFLAGS | ARCHIVE_EXTRACT_XATTR;

static int
extract_files(struct pkg_task *pkg)
{
	char    cmd[MaxPathSize];
	const char *owner, *group, *permissions;
	struct archive *writer;
	int r;
	plist_t *p;
	const char *last_file;
	char *fullpath;

	if (Fake)
		return 0;

	if (mkdir_p(pkg->install_prefix)) {
		warn("Can't create prefix: %s", pkg->install_prefix);
		return -1;
	}

	if (chdir(pkg->install_prefix) == -1) {
		warn("Can't change into prefix: %s", pkg->install_prefix);
		return -1;
	}

	if (!NoRecord && !pkgdb_open(ReadWrite)) {
		warn("Can't open pkgdb for writing");
		return -1;
	}

	writer = archive_write_disk_new();
	archive_write_disk_set_options(writer, extract_flags);
	archive_write_disk_set_standard_lookup(writer);

	owner = NULL;
	group = NULL;
	permissions = NULL;
	last_file = NULL;

	r = -1;

	for (p = pkg->plist.head; p != NULL; p = p->next) {
		switch (p->type) {
		case PLIST_FILE:
			last_file = p->name;
			if (pkg->entry == NULL) {
				warnx("PLIST entry not in package (%s)",
				    archive_entry_pathname(pkg->entry));
				goto out;
			}
			if (strcmp(p->name, archive_entry_pathname(pkg->entry))) {
				warnx("PLIST entry and package don't match (%s vs %s)",
				    p->name, archive_entry_pathname(pkg->entry));
				goto out;
			}
			if (asprintf(&fullpath, "%s/%s", pkg->install_prefix, p->name) == -1) {
				warnx("asprintf failed");
				goto out;
			}
			pkgdb_store(fullpath, pkg->pkgname);
			free(fullpath);
			if (Verbose)
				printf("%s", p->name);
			break;

		case PLIST_CMD:
			if (format_cmd(cmd, sizeof(cmd), p->name, pkg->install_prefix, last_file))
				return -1;
			printf("Executing '%s'\n", cmd);
			if (!Fake && system(cmd))
				warnx("command '%s' failed", cmd); /* XXX bail out? */
			continue;

		case PLIST_CHMOD:
			permissions = p->name;
			continue;

		case PLIST_CHOWN:
			owner = p->name;
			continue;

		case PLIST_CHGRP:
			group = p->name;
			continue;

		case PLIST_IGNORE:
			p = p->next;
			continue;

		default:
			continue;
		}

		r = archive_write_header(writer, pkg->entry);
		if (r != ARCHIVE_OK) {
			warnx("Failed to write %s: %s",
			    archive_entry_pathname(pkg->entry),
			    archive_error_string(writer));
			goto out;
		}

		if (owner != NULL)
			archive_entry_set_uname(pkg->entry, owner);
		if (group != NULL)
			archive_entry_set_uname(pkg->entry, group);
		if (permissions != NULL) {
			mode_t mode;

			mode = archive_entry_mode(pkg->entry);
			mode = getmode(setmode(permissions), mode);
			archive_entry_set_mode(pkg->entry, mode);
		}

		r = copy_data_to_disk(pkg->archive, writer,
		    archive_entry_pathname(pkg->entry));
		if (r)
			goto out;
		if (Verbose)
			printf("\n");

		r = archive_read_next_header(pkg->archive, &pkg->entry);
		if (r == ARCHIVE_EOF) {
			pkg->entry = NULL;
			continue;
		}
		if (r != ARCHIVE_OK) {
			warnx("Failed to read from archive: %s",
			    archive_error_string(pkg->archive));
			goto out;
		}
	}

	if (pkg->entry != NULL) {
		warnx("Package contains entries not in PLIST: %s",
		    archive_entry_pathname(pkg->entry));
		goto out;
	}

	r = 0;

out:
	if (!NoRecord)
		pkgdb_close();
	archive_write_close(writer);
	archive_write_finish(writer);

	return r;
}

/*
 * Register dependencies after sucessfully installing the package.
 */
static void
pkg_register_depends(struct pkg_task *pkg)
{
	int fd;
	size_t text_len, i;
	char *required_by, *text;

	if (Fake)
		return;

	if (pkg->other_version != NULL)
		return; /* XXX It's using the old dependencies. */

	if (asprintf(&text, "%s\n", pkg->pkgname) == -1)
		err(2, "asprintf failed");
	text_len = strlen(text);

	for (i = 0; i < pkg->dep_length; ++i) {
		required_by = pkgdb_pkg_file(pkg->dependencies[i], REQUIRED_BY_FNAME);

		fd = open(required_by, O_WRONLY | O_APPEND | O_CREAT, 644);
		if (fd == -1)
			warn("can't open dependency file '%s',"
			    "registration is incomplete!", required_by);
		else if (write(fd, text, text_len) != text_len)
			warn("can't write to dependency file `%s'", required_by);
		else if (close(fd) == -1)
			warn("cannot close file %s", required_by);

		free(required_by);
	}

	free(text);
}

/*
 * Reduce the result from uname(3) to a canonical form.
 */
static void
normalise_platform(struct utsname *host_name)
{
#ifdef NUMERIC_VERSION_ONLY
	size_t span;

	span = strspn(host_name->release, "0123456789.");
	host_name->release[span] = '\0';
#endif
}

/*
 * Check build platform of the package against local host.
 */
static int
check_platform(struct pkg_task *pkg)
{
	struct utsname host_uname;
	const char *effective_arch;
	int fatal;

	if (uname(&host_uname) < 0) {
		if (Force) {
			warnx("uname() failed, continuing.");
			return 0;
		} else {
			warnx("uname() failed, aborting.");
			return -1;
		}
	}

	normalise_platform(&host_uname);

	if (OverrideMachine != NULL)
		effective_arch = OverrideMachine;
	else
		effective_arch = MACHINE_ARCH;

	/* If either the OS or arch are different, bomb */
	if (strcmp(OPSYS_NAME, pkg->buildinfo[BI_OPSYS]) ||
	    strcmp(effective_arch, pkg->buildinfo[BI_MACHINE_ARCH]) != 0)
		fatal = 1;
	else
		fatal = 0;

	if (fatal ||
	    strcmp(host_uname.release, pkg->buildinfo[BI_OS_VERSION]) != 0) {
		warnx("Warning: package `%s' was built for a platform:",
		    pkg->pkgname);
		warnx("%s/%s %s (pkg) vs. %s/%s %s (this host)",
		    pkg->buildinfo[BI_OPSYS],
		    pkg->buildinfo[BI_MACHINE_ARCH],
		    pkg->buildinfo[BI_OS_VERSION],
		    OPSYS_NAME,
		    effective_arch,
		    host_uname.release);
		if (!Force && fatal)
			return -1;
	}
	return 0;
}

/*
 * Run the install script.
 */
static int
run_install_script(struct pkg_task *pkg, const char *argument)
{
	int ret;
	char *filename;

	if (pkg->meta_data.meta_install == NULL || NoInstall)
		return 0;

	setenv(PKG_PREFIX_VNAME, pkg->install_prefix, 1); /* XXX or prefix? */
	setenv(PKG_METADATA_DIR_VNAME, pkg->logdir, 1);
	setenv(PKG_REFCOUNT_DBDIR_VNAME, pkgdb_refcount_dir(), 1);

	filename = pkgdb_pkg_file(pkg->pkgname, INSTALL_FNAME);
	if (Verbose)
		printf("Running install with PRE-INSTALL for %s.\n", pkg->pkgname);
	if (Fake) {
		free(filename);
		return 0;
	}

	ret = 0;

	if (chdir(pkg->logdir) == -1) {
		warn("Can't change to %s", pkg->logdir);
		ret = -1;
	}

	errno = 0;
	if (ret == 0 && fexec(filename, pkg->pkgname, argument, (void *)NULL)) {
		if (errno != 0)
			warn("exec of install script failed");
		else
			warnx("install script returned error status");
		ret = -1;
	}

	free(filename);
	return ret;
}

static int
check_explicit_conflict(struct pkg_task *pkg)
{
	char *installed, *installed_pattern;
	plist_t *p;
	int status;

	status = 0;

	for (p = pkg->plist.head; p != NULL; p = p->next) {
		if (p->type == PLIST_IGNORE) {
			p = p->next;
			continue;
		} else if (p->type != PLIST_PKGCFL)
			continue;
		installed = find_best_matching_installed_pkg(p->name);
		if (installed) {
			warnx("Package `%s' conflicts with `%s', and `%s' is installed.",
			    pkg->pkgname, p->name, installed);
			free(installed);
			status = -1;
		}
	}

	if (some_installed_package_conflicts_with(pkg->pkgname,
	    pkg->other_version, &installed, &installed_pattern)) {
		warnx("Installed package `%s' conflicts with `%s' when trying to install `%s'.",
			installed, installed_pattern, pkg->pkgname);
		free(installed);
		free(installed_pattern);
		status = -1;
	}

	return status;
}

static int
check_implicit_conflict(struct pkg_task *pkg)
{
	plist_t *p;
	char *fullpath, *existing;
	int status;

	if (!pkgdb_open(ReadOnly)) {
#if notyet /* XXX empty pkgdb without database? */
		warn("Can't open pkgdb for reading");
		return -1;
#else
		return 0;
#endif
	}

	status = 0;

	for (p = pkg->plist.head; p != NULL; p = p->next) {
		if (p->type == PLIST_IGNORE) {
			p = p->next;
			continue;
		} else if (p->type != PLIST_FILE)
			continue;

		if (asprintf(&fullpath, "%s/%s", pkg->install_prefix, p->name) == -1) {
			warnx("asprintf failed");
			status = -1;
			break;
		}
		existing = pkgdb_retrieve(fullpath);
		free(fullpath);
		if (existing == NULL)
			continue;
		if (pkg->other_version != NULL &&
		    strcmp(pkg->other_version, existing) == 0)
			continue;

		warnx("Conflicting PLIST with %s: %s", existing, p->name);
		if (!Force) {
			status = -1;
			if (!Verbose)
				break;
		}
	}

	pkgdb_close();
	return status;
}

static int
check_dependencies(struct pkg_task *pkg)
{
	plist_t *p;
	char *best_installed;
	int status;
	size_t i;

	status = 0;

	for (p = pkg->plist.head; p != NULL; p = p->next) {
		if (p->type == PLIST_IGNORE) {
			p = p->next;
			continue;
		} else if (p->type != PLIST_PKGDEP)
			continue;

		best_installed = find_best_matching_installed_pkg(p->name);

		if (best_installed == NULL) {
			/* XXX check cyclic dependencies? */
			if (Fake || NoRecord) {
				if (!Force) {
					warnx("Missing dependency %s\n",
					     p->name);
					status = -1;
					break;
				}
				warnx("Missing dependency %s, continuing",
				    p->name);
				continue;
			}
			if (pkg_do(p->name, 1)) {
				warnx("Can't install dependency %s", p->name);
				status = -1;
				break;
			}
			best_installed = find_best_matching_installed_pkg(p->name);
			if (best_installed == NULL && Force) {
				warnx("Missing dependency %s ignored", p->name);
				continue;
			} else if (best_installed == NULL) {
				warnx("Just installed dependency %s disappeared", p->name);
				status = -1;
				break;
			}
		}
		for (i = 0; i < pkg->dep_length; ++i) {
			if (strcmp(best_installed, pkg->dependencies[i]) == 0)
				break;
		}
		if (i < pkg->dep_length) {
			/* Already used as dependency, so skip it. */
			free(best_installed);
			continue;
		}
		if (pkg->dep_length + 1 >= pkg->dep_allocated) {
			char **tmp;
			pkg->dep_allocated = 2 * pkg->dep_allocated + 1;
			tmp = realloc(pkg->dependencies,
			    pkg->dep_allocated * sizeof(*tmp));
			if (tmp == NULL) {
				warnx("realloc failed");
				free(pkg->dependencies);
				pkg->dependencies = NULL;
				pkg->dep_length = pkg->dep_allocated = 0;
				free(best_installed);
				return -1;
			}
			pkg->dependencies = tmp;
		}
		pkg->dependencies[pkg->dep_length++] = best_installed;
	}

	return status;
}

/*
 * If this package uses pkg_views, register it in the default view.
 */
static void
pkg_register_views(struct pkg_task *pkg)
{
	if (Fake || NoView || pkg->meta_data.meta_views == NULL)
		return;

	if (Verbose) {
		printf("%s/pkg_view -d %s %s%s %s%s %sadd %s\n",
			BINDIR, _pkgdb_getPKGDB_DIR(),
			View ? "-w " : "", View ? View : "",
			Viewbase ? "-W " : "", Viewbase ? Viewbase : "",
			Verbose ? "-v " : "", pkg->pkgname);
	}

	fexec_skipempty(BINDIR "/pkg_view", "-d", _pkgdb_getPKGDB_DIR(),
			View ? "-w " : "", View ? View : "",
			Viewbase ? "-W " : "", Viewbase ? Viewbase : "",
			Verbose ? "-v " : "", "add", pkg->pkgname,
			(void *)NULL);
}

static int
start_replacing(struct pkg_task *pkg)
{
	char *old_required_by, *new_required_by;

	old_required_by = pkgdb_pkg_file(pkg->other_version,
	    REQUIRED_BY_FNAME);
	new_required_by = pkgdb_pkg_file(pkg->pkgname,
	    REQUIRED_BY_FNAME);

	if (!Fake) {
		if (rename(old_required_by, new_required_by) == -1 &&
		    errno != ENOENT) {
			warn("Can't move +REQUIRED_BY from %s to %s",
			    old_required_by, new_required_by);
			return -1;			
		}
	}

	if (Verbose || Fake) {
		printf("%s/pkg_delete -K %s -p %s '%s'\n",
			BINDIR, _pkgdb_getPKGDB_DIR(), pkg->install_prefix,
			pkg->other_version);
	}
	if (!Fake)
		fexec(BINDIR "/pkg_delete", "-K", _pkgdb_getPKGDB_DIR(),
		    "-p", pkg->install_prefix,
		    pkg->other_version, NULL);

	/* XXX Check return value and do what? */
	return 0;
}

/*
 * Install a single package.
 */
static int
pkg_do(const char *pkgpath, int mark_automatic)
{
	int status;
	void *archive_cookie;
	struct pkg_task *pkg;

	if ((pkg = calloc(1, sizeof(*pkg))) == NULL)
		err(2, "malloc failed");

	status = -1;

	if ((pkg->archive = find_archive(pkgpath, &archive_cookie)) == NULL) {
		warnx("no pkg found for '%s', sorry.", pkgpath);
		goto clean_memory;
	}
	if (read_meta_data(pkg))
		goto clean_memory;

	/* Parse PLIST early, so that messages can use real package name. */
	if (pkg_parse_plist(pkg))
		goto clean_memory;

	if (pkg->meta_data.meta_mtree != NULL)
		warnx("mtree specification in pkg `%s' ignored", pkg->pkgname);

	if (pkg->meta_data.meta_views != NULL) {
		if ((pkg->logdir = strdup(pkg->install_prefix)) == NULL)
			err(EXIT_FAILURE, "strdup failed");
		_pkgdb_setPKGDB_DIR(dirname_of(pkg->logdir));
	} else {
		if (asprintf(&pkg->logdir, "%s/%s", _pkgdb_getPKGDB_DIR(),
			     pkg->pkgname) == -1)
			err(EXIT_FAILURE, "asprintf failed");
	}

	if (NoRecord && !Fake) {
		const char *tmpdir;

		tmpdir = getenv("TMPDIR");
		if (tmpdir == NULL)
			tmpdir = "/tmp";

		free(pkg->logdir);
		if (asprintf(&pkg->logdir, "%s/pkg_install.XXXXXX", tmpdir) == -1)
			err(EXIT_FAILURE, "asprintf failed");
		/* XXX pkg_add -u... */
		if (mkdtemp(pkg->logdir) == NULL) {
			warn("mkdtemp failed");
			goto clean_memory;
		}
	}

	if (check_already_installed(pkg) == 0) {
		status = 0;
		goto clean_memory;
	}

	if (read_buildinfo(pkg))
		goto clean_memory;

	if (check_platform(pkg))
		goto clean_memory;

	if (check_other_installed(pkg))
		goto clean_memory; 

	if (check_explicit_conflict(pkg))
		goto clean_memory;

	if (check_implicit_conflict(pkg))
		goto clean_memory;

	if (pkg->other_version != NULL) {
		/*
		 * Replacing an existing package.
		 * Write meta-data, get rid of the old version,
		 * install/update dependencies and finally extract.
		 */
		if (write_meta_data(pkg))
			goto nuke_pkgdb;

		if (start_replacing(pkg))
			goto nuke_pkgdb;

		if (check_dependencies(pkg))
			goto nuke_pkgdb;
	} else {
		/*
		 * Normal installation.
		 * Install/update dependencies first and
		 * write the current package to disk afterwards.
		 */ 
		if (check_dependencies(pkg))
			goto clean_memory;

		if (write_meta_data(pkg))
			goto nuke_pkgdb;
	}

	if (run_install_script(pkg, "PRE-INSTALL"))
		goto nuke_pkgdb;

	if (extract_files(pkg))
		goto nuke_pkg;

	if (run_install_script(pkg, "POST-INSTALL"))
		goto nuke_pkgdb;

	/* XXX keep +INSTALL_INFO for updates? */
	/* XXX keep +PRESERVE for updates? */
	if (mark_automatic)
		mark_as_automatic_installed(pkg->pkgname, 1);

	pkg_register_depends(pkg);

	if (Verbose)
		printf("Package %s registered in %s\n", pkg->pkgname, pkg->logdir);

	if (pkg->meta_data.meta_display != NULL)
		fputs(pkg->meta_data.meta_display, stdout);

	pkg_register_views(pkg);

	status = 0;
	goto clean_memory;

nuke_pkg:
	if (!Fake) {
		if (pkg->other_version) {
			warnx("Updating of %s to %s failed.",
			    pkg->other_version, pkg->pkgname);
			warnx("Remember to run pkg_admin rebuild-tree after fixing this.");
		}
		delete_package(FALSE, FALSE, &pkg->plist, FALSE);
	}

nuke_pkgdb:
	if (!Fake) {
		(void) fexec(REMOVE_CMD, "-fr", pkg->logdir, (void *)NULL);
		free(pkg->logdir);
		pkg->logdir = NULL;
	}

clean_memory:
	if (pkg->logdir != NULL && NoRecord && !Fake)
		(void) fexec(REMOVE_CMD, "-fr", pkg->logdir, (void *)NULL);
	free(pkg->logdir);
	free_buildinfo(pkg);
	free_plist(&pkg->plist);
	free_meta_data(pkg);
	if (pkg->archive) {
		archive_read_close(pkg->archive);
		close_archive(archive_cookie);
	}
	free(pkg->other_version);
	free(pkg);
	return status;
}

int
pkg_perform(lpkg_head_t *pkgs)
{
	int     errors = 0;
	lpkg_t *lpp;

	while ((lpp = TAILQ_FIRST(pkgs)) != NULL) {
		path_prepend_from_pkgname(lpp->lp_name);
		if (pkg_do(lpp->lp_name, Automatic))
			++errors;
		path_prepend_clear();
		TAILQ_REMOVE(pkgs, lpp, lp_link);
		free_lpkg(lpp);
	}

	return errors;
}
