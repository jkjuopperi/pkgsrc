/*	$NetBSD: parse-config.c,v 1.8 2009/08/16 21:10:15 joerg Exp $	*/

#if HAVE_CONFIG_H
#include "config.h"
#endif
#include <nbcompat.h>
#if HAVE_SYS_CDEFS_H
#include <sys/cdefs.h>
#endif
__RCSID("$NetBSD: parse-config.c,v 1.8 2009/08/16 21:10:15 joerg Exp $");

/*-
 * Copyright (c) 2008, 2009 Joerg Sonnenberger <joerg@NetBSD.org>.
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

#if HAVE_ERR_H
#include <err.h>
#endif
#include <errno.h>
#if HAVE_STRING_H
#include <string.h>
#endif

#include "lib.h"

const char     *config_file = SYSCONFDIR"/pkg_install.conf";

char fetch_flags[10] = ""; /* Workaround Mac OS X linker issues with BSS */
static const char *active_ftp;
static const char *verbose_netio;
static const char *ignore_proxy;
const char *cert_chain_file;
const char *certs_packages;
const char *certs_pkg_vulnerabilities;
const char *check_vulnerabilities;
const char *config_pkg_path;
const char *do_license_check;
const char *verified_installation;
const char *gpg_cmd;
const char *gpg_keyring_pkgvuln;
const char *gpg_keyring_sign;
const char *gpg_keyring_verify;
const char *gpg_sign_as;
const char *pkg_vulnerabilities_dir;
const char *pkg_vulnerabilities_file;
const char *pkg_vulnerabilities_url;
const char *ignore_advisories = NULL;
const char tnf_vulnerability_base[] = "ftp://ftp.NetBSD.org/pub/NetBSD/packages/vulns";
const char *acceptable_licenses = NULL;

static struct config_variable {
	const char *name;
	const char **var;
} config_variables[] = {
	{ "ACCEPTABLE_LICENSES", &acceptable_licenses },
	{ "ACTIVE_FTP", &active_ftp },
	{ "CERTIFICATE_ANCHOR_PKGS", &certs_packages },
	{ "CERTIFICATE_ANCHOR_PKGVULN", &certs_pkg_vulnerabilities },
	{ "CERTIFICATE_CHAIN", &cert_chain_file },
	{ "CHECK_LICENSE", &do_license_check },
	{ "CHECK_VULNERABILITIES", &check_vulnerabilities },
	{ "DEFAULT_ACCEPTABLE_LICENSES", &default_acceptable_licenses },
	{ "GPG", &gpg_cmd },
	{ "GPG_KEYRING_PKGVULN", &gpg_keyring_pkgvuln },
	{ "GPG_KEYRING_SIGN", &gpg_keyring_sign },
	{ "GPG_KEYRING_VERIFY", &gpg_keyring_verify },
	{ "GPG_SIGN_AS", &gpg_sign_as },
	{ "IGNORE_PROXY", &ignore_proxy },
	{ "IGNORE_URL", &ignore_advisories },
	{ "PKG_PATH", &config_pkg_path },
	{ "PKGVULNDIR", &pkg_vulnerabilities_dir },
	{ "PKGVULNURL", &pkg_vulnerabilities_url },
	{ "VERBOSE_NETIO", &verbose_netio },
	{ "VERIFIED_INSTALLATION", &verified_installation },
	{ NULL, NULL }
};

char *config_tmp_variables[sizeof config_variables/sizeof config_variables[0]];

static void
parse_pkg_install_conf(void)
{
	struct config_variable *var;
	FILE *fp;
	char *line, *value;
	size_t len, var_len, i;

	fp = fopen(config_file, "r");
	if (!fp) {
		if (errno != ENOENT)
			warn("Can't open '%s' for reading", config_file);
		return;
	}

	while ((line = fgetln(fp, &len)) != (char *) NULL) {
		if (line[len - 1] == '\n')
			--len;
		for (i = 0; (var = &config_variables[i])->name != NULL; ++i) {
			var_len = strlen(var->name);
			if (strncmp(var->name, line, var_len) != 0)
				continue;
			if (line[var_len] != '=')
				continue;
			line += var_len + 1;
			len -= var_len + 1;
			if (config_tmp_variables[i])
				value = xasprintf("%s\n%.*s",
				    config_tmp_variables[i], (int)len, line);
			else
				value = xasprintf("%.*s", (int)len, line);
			free(config_tmp_variables[i]);
			config_tmp_variables[i] = value;
			break;
		}
	}

	for (i = 0; (var = &config_variables[i])->name != NULL; ++i) {
		if (config_tmp_variables[i] == NULL)
			continue;
		*var->var = config_tmp_variables[i];
		config_tmp_variables[i] = NULL;
	}
}

void
pkg_install_config(void)
{
	char *value;
	parse_pkg_install_conf();

	if (pkg_vulnerabilities_dir == NULL)
		pkg_vulnerabilities_dir = _pkgdb_getPKGDB_DIR();
	pkg_vulnerabilities_file = xasprintf("%s/pkg-vulnerabilities",
	    pkg_vulnerabilities_dir);
	if (pkg_vulnerabilities_url == NULL) {
		pkg_vulnerabilities_url = xasprintf("%s/pkg-vulnerabilities.gz",
		    tnf_vulnerability_base);
	}
	if (verified_installation == NULL)
		verified_installation = "never";

	if (check_vulnerabilities == NULL)
		check_vulnerabilities = "never";

	if (do_license_check == NULL)
		do_license_check = "no";

	if ((value = getenv("PKG_PATH")) != NULL)
		config_pkg_path = value;

	snprintf(fetch_flags, sizeof(fetch_flags), "%s%s%s",
	    (verbose_netio && *verbose_netio) ? "v" : "",
	    (active_ftp && *active_ftp) ? "a" : "",
	    (ignore_proxy && *ignore_proxy) ? "d" : "");
}

void
pkg_install_show_variable(const char *var_name)
{
	struct config_variable *var;

	for (var = config_variables; var->name != NULL; ++var) {
		if (strcmp(var->name, var_name) != 0)
			continue;
		if (*var->var != NULL)
			puts(*var->var);
	}
}
