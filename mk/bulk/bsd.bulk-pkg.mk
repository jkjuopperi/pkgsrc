#	$NetBSD: bsd.bulk-pkg.mk,v 1.17 2001/02/01 08:47:29 dmcmahill Exp $

#
# Copyright (c) 1999, 2000 Hubert Feyrer <hubertf@netbsd.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by Hubert Feyrer for
#	the NetBSD Project.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

##
## For this to work, put
##   DEPENDS_TARGET=	bulk-install
##   BATCH=		yes
## into your /etc/mk.conf, then cd /usr/pkgsrc; make bulk-package
##
## bulk-install will only compile pkgs if necessary, and install binary
##	pkgs if possible/available.
## bulk-package will build binary packages, and remove them (together with
##	any depending packages) immediately after that, leaving only the
##	binary package back. Broken packages are marked (``.broken'').
##

LS?=	ls
WC?=	wc

# Shall we remove any packages which are installed, but not required
# to build this package
PRECLEAN?=      yes

.ifdef OBJMACHINE
# This file exists to mark a package as broken
BROKENFILE?=	.broken.${MACHINE}

# This file is where the log of the build goes
BUILDLOG?=	.make.${MACHINE}

# This is a top level file which lists the entire pkgsrc depends tree in the format:
# foo/bar devel/libfoo
# meaning 'foo/bar' is requied to build 'devel/libfoo'
# this is in the format needed by tsort(1)
DEPENDSTREEFILE?=	${PKGSRCDIR}/.dependstree.${MACHINE}

# This is a top level file which lists the entire pkgsrc depends tree in the format:
# foo/bar depends on: devel/libfoo devel/libbar devel/baz .....
# ie, to build foo/bar we need devel/libfoo devel/libbar devel/baz ... installed
DEPENDSFILE?=	${PKGSRCDIR}/.depends.${MACHINE}

# This is a top level file which lists the entire pkgsrc depends tree in the format:
# devel/libfoo is depended upon by: foo/bar graphics/gtkfoo ...
# ie, to build foo/bar we need  devel/libfoo to be installed.
#     to build graphics/gtkfoo we need devel/libfoo to be installed
SUPPORTSFILE?=	${PKGSRCDIR}/.supports.${MACHINE}

# This is a top level file which cross-references each package name and pkg directory
# in the format:
# devel/libfoo libfoo-1.3
INDEXFILE?=	${PKGSRCDIR}/.index.${MACHINE}

# file containing a list of all the packages in the correct order for a bulk build.
# the correct order is one where packages that are required by others are built
# before the packages which require them.
ORDERFILE?=	${PKGSRCDIR}/.order.${MACHINE}

.else
BROKENFILE?=		.broken
BUILDLOG?=		.make
DEPENDSTREEFILE?=	${PKGSRCDIR}/.dependstree
DEPENDSFILE?=		${PKGSRCDIR}/.depends
SUPPORTSFILE?=		${PKGSRCDIR}/.supports
INDEXFILE?=		${PKGSRCDIR}/.index
ORDERFILE?=		${PKGSRCDIR}/.order
.endif


# check if the $REF file is uptodate, i.e. is newer than any of
# the pkg files; prints "1" if upto date, "0" if not.
bulk-check-uptodate:
	@uptodate=1 ; \
	if [ -f "${REF}" ]; then \
		${SHCOMMENT} "Check files of this package" ; \
		newfiles="`find . -type f -newer "${REF}" -print  | ${EGREP} -v -e ./work -e pkg/COMMENT -e pkg/DESCR -e README.html -e CVS -e '^\./\.' || true`" ; \
		nnewfiles="`find . -type f -newer "${REF}" -print  | ${EGREP} -v -e ./work -e pkg/COMMENT -e pkg/DESCR -e README.html -e CVS -e '^\./\.' | ${WC} -l`" ; \
		if [ "$$nnewfiles" -gt 0 ]; then \
			${ECHO_MSG} >&2 "BULK> Package ${PKGNAME} ($$newfiles) modified since last 'make package' re-packaging..." ; \
			uptodate=0 ; \
		else \
			${ECHO_MSG} >&2 "BULK> ${REF} is up to date." ; \
		fi ; \
	else \
		${ECHO_MSG} >&2 "BULK> Package ${PKGNAME} not built yet, packaging..." ; \
		uptodate=0 ; \
	fi ; \
	if [ "$$uptodate" = "1" ]; then \
		${SHCOMMENT} "Check required binary packages" ; \
		deps=`${PKG_INFO} -qf ${REF} \
		      | ${GREP} ^@pkgdep \
		      | ${SED} 's,@pkgdep.,,g'`; \
		for dep in $$deps ; do \
			${SHCOMMENT} "check against the binary pkg that pkg_add would pick, too:" ; \
			${SHCOMMENT} "(Only one should be returned here, really...)" ; \
			pkg=`${PKG_ADMIN} lsbest "${PACKAGES}/All/$$dep"` ;  \
			if [ -z $$pkg ]; then \
				${ECHO_MSG} >&2 "BULK> Required binary package $$dep does not exist, rebuilding... " ; \
				uptodate=0 ; \
			elif [ "$$pkg" -nt "${REF}" ]; then \
				${ECHO_MSG} >&2 "BULK> Required binary package $$dep (`basename $$pkg`) is newer, rebuilding... " ; \
				uptodate=0 ; \
			else \
				${ECHO_MSG} >&2 "BULK> Required binary package $$dep (`basename $$pkg`) is usable. " ; \
			fi ; \
		done ; \
	fi ; \
	${ECHO_MSG} $$uptodate

# rebuild binpkg if any of the pkg files is newer than the binary archive
# set DO to ":" to not actually do anything (debugging, ...)
bulk-package:
	@if [ -f ${BROKENFILE} ]; then \
		${ECHO_MSG} "BULK> *** Package ${PKGNAME} seems broken and needs attention:" ; \
		${LS} -la ${BROKENFILE}; \
		exit 1; \
	fi
	@( \
	if [ "${PRECLEAN}" = "yes" ]; then \
		${ECHO_MSG} '' ; \
		${ECHO_MSG} '' ; \
		${ECHO_MSG} '###' ; \
		${ECHO_MSG} '### ${MAKE} ${.TARGET} for ${PKGNAME}' ; \
		${ECHO_MSG} '### Current pkg count: ' `${LS} -l ${PKG_DBDIR} | ${GREP} ^d | ${WC} -l` installed packages: `${LS} ${PKG_DBDIR} | ${GREP} -v pkgdb.byfile.db`; \
		${ECHO_MSG} '###' ; \
	fi \
	) 2>&1 | tee -a ${BUILDLOG}
	@uptodate=`${MAKE} ${MAKEFLAGS} bulk-check-uptodate REF=${PKGFILE}` ; \
	if ${PKG_INFO} -qe "${PKGNAME:C/-[^-]*$/-[0-9]*/}" ; then \
		installed=1; \
	else \
		installed=0; \
	fi ; \
	if [ $$uptodate = 1 ]; then \
		( if [ $$installed = 1 ]; then \
			${ECHO_MSG} "BULK> Package ${PKGNAME} is upto-date, and still installed" ; \
		else \
			${ECHO_MSG} "BULK> Nothing to be done." ; \
		fi \
		) 2>&1 | tee -a ${BUILDLOG}; \
	else \
		( if [ $$installed = 1 ]; then \
			${ECHO_MSG} "BULK> Removing outdated (installed) package ${PKGNAME} first." ; \
			${ECHO_MSG} ${MAKE} deinstall ; \
			${DO}       ${MAKE} deinstall ; \
		fi ; \
		if [ -f ${PKGFILE} ]; then \
			${ECHO_MSG} "BULK> Removing old binary package..." ; \
			${ECHO_MSG} ${RM} -f ${PKGFILE} ; \
			${DO}       ${RM} -f ${PKGFILE} ; \
		fi; \
			${ECHO_MSG} "BULK> Full rebuild  in progress..." ; \
			${ECHO_MSG} "BULK> Cleaning package and its depends" ;\
			thisdir=`${GREP} " ${PKGNAME} " ${INDEXFILE} | ${AWK} '{print $$1}'` ;\
			for pkgdir in $$thisdir `${GREP} "^$$thisdir " ${DEPENDSFILE} | ${SED} -e 's;^.*:;;g'`; do \
				${ECHO_MSG} "(cd ${PKGSRCDIR}/$$pkgdir && ${MAKE} clean)" ; \
				${DO}       (cd ${PKGSRCDIR}/$$pkgdir && ${MAKE} clean) ; \
			done ;\
		if [ "${PRECLEAN}" = "yes" ]; then \
			${ECHO_MSG} "BULK> Removing installed packages which are not needed to build ${PKGNAME}" ; \
			thisdir=`${GREP} " ${PKGNAME} " ${INDEXFILE} | ${AWK} '{print $$1}'` ;\
			for pkgname in `${PKG_INFO} | ${AWK} '{print $$1}'` ; \
			do \
				pkgdir=`${GREP} " $$pkgname " ${INDEXFILE} | ${AWK} '{print $$1}'` ;\
				if `${PKG_INFO} -qe $$pkgname` ; then \
					if ! `${EGREP} "^$$thisdir.* $$pkgdir( |$$)" ${DEPENDSFILE} >/dev/null 2>&1` ; then \
						${ECHO_MSG} "BULK> ${PKGNAME} does not require installed package $$pkgname ($$pkgdir) to build." ;\
						${ECHO_MSG} "BULK> Deinstalling $$pkgname" ;\
						${ECHO_MSG} ${PKG_DELETE} -r $$pkgname ; \
						${DO}       ${PKG_DELETE} -r $$pkgname || true ; \
						if `${PKG_INFO} -qe $$pkgname` ; then \
							${ECHO_MSG} "BULK> $$pkgname ($$pkgdir) did not nicely deinstall.  Forcing the deinstall." ;\
							${ECHO_MSG} ${PKG_DELETE} -f $$pkgname ; \
							${DO}       ${PKG_DELETE} -f $$pkgname || true ; \
						fi ;\
					else \
						${ECHO_MSG} "BULK> ${PKGNAME}  requires installed package $$pkgname ($$pkgdir) to build." ;\
						${ECHO_MSG} "BULK> Keeping $$pkgname" ;\
					fi ;\
				else \
					${ECHO_MSG} "BULK> package $$pkgname ($$pkgdir) is no longer installed" ;\
				fi ;\
			done ; \
		fi ;\
		thisdir=`${GREP} " ${PKGNAME} " ${INDEXFILE} | ${AWK} '{print $$1}'` ;\
		${ECHO_MSG} "BULK> Installing packages which are required to build ${PKGNAME}." ;\
		for pkgdir in `${GREP} "^$$thisdir " ${DEPENDSFILE} | ${SED} -e 's;^.*:;;g'`; do \
			pkgname=`${GREP} "^$$pkgdir " ${INDEXFILE} | ${AWK} '{print $$2}'` ; \
			pkgfile=${PACKAGES}/All/$${pkgname}.tgz ;\
			if ! `${PKG_INFO} -qe $$pkgname` ; then \
				${ECHO_MSG} "BULK> " ${PKG_ADD} $$pkgfile ; \
				${DO} ${PKG_ADD} $$pkgfile ; \
			else \
				${ECHO_MSG} "BULK> Required package $$pkgname ($$pkgdir) is already installed" ; \
			fi ;\
		done ;\
		${ECHO_MSG} ${MAKE} package '(${PKGNAME})' 2>&1 ; \
		${DO}     ( ${MAKE} package 2>&1 ); \
		) 2>&1 | tee -a ${BUILDLOG} ; \
		if [ -f ${PKGFILE} ]; then \
			${RM} ${BUILDLOG} ; \
		else \
			${MV} ${BUILDLOG} ${BROKENFILE} ; \
			( \
			${ECHO_MSG} "BULK> ${PKGNAME} was marked as broken:" ; \
			${LS} -la ${BROKENFILE} ; \
			${ECHO_MSG} ${MAKE} deinstall ; \
			${DO}       ${MAKE} deinstall ; \
			nerrors=`${GREP} -c '^\*\*\* Error code' ${BROKENFILE} || true`; \
			${ECHO_MSG} " $$nerrors ${PKGPATH}/${BROKENFILE}" >> ${PKGSRCDIR}/${BROKENFILE}; \
			${ECHO_MSG} "BULK> Marking all packages which depend upon ${PKGNAME} as broken:"; \
			thisdir=`${GREP} " ${PKGNAME} " ${INDEXFILE} | ${AWK} '{print $$1}'` ;\
			for pkgdir in `${GREP} "^$$thisdir " ${SUPPORTSFILE} | ${SED} -e 's;^.*:;;g'`; do \
				pkgname=`${GREP} "^$$pkgdir " ${INDEXFILE} | ${AWK} '{print $$2}'` ;\
				${ECHO_MSG} "BULK> marking package that requires ${PKGNAME} as broken:  $$pkgname ($$pkgdir)";\
				pkgerr="-1"; \
				pkgignore=`(cd ${PKGSRCDIR}/$$pkgdir && ${MAKE} show-var VARNAME=IGNORE)`; \
				if [ ! -z "$$pkgignore" -a ! -f ${PKGSRCDIR}/$$pkgdir/${BROKENFILE} ]; then \
					 ${ECHO_MSG} "BULK> $$pkgname ($$pkgdir) may not be packaged because:" >> ${PKGSRCDIR}/$$pkgdir/${BROKENFILE};\
					 ${ECHO_MSG} "BULK> $$pkgignore" >> ${PKGSRCDIR}/$$pkgdir/${BROKENFILE};\
					if [ -z "`(cd ${PKGSRCDIR}/$$pkgdir && ${MAKE} show-var VARNAME=BROKEN)`" ]; then \
						pkgerr="0"; \
					else \
						pkgerr="1"; \
					fi; \
				fi; \
				${ECHO_MSG} "BULK> $$pkgname ($$pkgdir) is broken because it depends upon ${PKGNAME} ($$thisdir) which is broken." \
					>> ${PKGSRCDIR}/$$pkgdir/${BROKENFILE};\
				if ! `${GREP} " $$pkgdir/${BROKENFILE}" ${PKGSRCDIR}/${BROKENFILE} >/dev/null 2>&1` ; then \
					${ECHO} " $$pkgerr $$pkgdir/${BROKENFILE}" >> ${PKGSRCDIR}/${BROKENFILE} ;\
				fi ;\
			done \
			) 2>&1 | tee -a ${BROKENFILE}; \
		fi ; \
		${ECHO_MSG} "BULK> Cleaning packages and its depends" ;\
		thisdir=`${GREP} " ${PKGNAME} " ${INDEXFILE} | ${AWK} '{print $$1}'` ;\
		for pkgdir in $$thisdir `${GREP} "^$$thisdir " ${DEPENDSFILE} | ${SED} -e 's;^.*:;;g'`; do \
			${ECHO_MSG} "(cd ${PKGSRCDIR}/$$pkgdir && ${MAKE} clean)" ; \
			${DO}       (cd ${PKGSRCDIR}/$$pkgdir && ${MAKE} clean) ; \
		done ;\
	fi
	@if [ ! -f ${PKGFILE} ]; then \
		${ECHO_MSG} "BULK>" Build for ${PKGNAME} was not successful, aborting. | tee -a ${BROKENFILE} ; \
		false; \
	else \
		${RM} -f ${BUILDLOG} ;\
	fi

# Install pkg - if possible from binary pkg (i.e. available & upto date)
# else revert to the old recompiling. 
# Don't rely upon pkg_add to snarf in depending pkgs as they may have
# been modified and need rebuilding.
bulk-install:
	@if [ `${MAKE} bulk-check-uptodate REF=${PKGFILE}` = 1 ]; then \
		if ! ${PKG_INFO} -qe ${PKGNAME} ; then \
			${DO} ${MAKE} install-depends ; \
			${ECHO_MSG} "BULK> " ${PKG_ADD} ${PKGFILE} ; \
			${DO} ${PKG_ADD} ${PKGFILE} ; \
		fi ; \
	else \
		${ECHO_MSG} ${MAKE} bulk-package PRECLEAN=no; \
		${DO}       ${MAKE} bulk-package PRECLEAN=no; \
	fi
