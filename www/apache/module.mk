# $NetBSD: module.mk,v 1.1 2003/02/17 17:32:08 grant Exp $
#
# This Makefile fragment is intended to be included by packages that build
# and install apache modules.
#
# The following targets are provided by this file:
#
# do-build		builds the module using APXS.
#
# do-install		installs the module using APXS.
#
# The following variables may be set prior to including this file:
#
# APACHE_MODULE_NAME	the name of this module, including the .so suffix.
#
# APACHE_MODULE_SRCDIR	the location of the source files for this module,
#			defaults to WRKSRC.
#
# APACHE_MODULE_SRC	the source files to be compiled for this module.
#

.if !defined(_APACHE_MODULE_MK)
_APACHE_MODULE_MK=	# defined
APACHE_MODULE=		# defined

.include "../../www/apache/buildlink2.mk"

# for APXS
USE_PERL5=		build
APACHE_MODULE_SRCDIR?=	${WRKSRC}

apache-module-build:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cd ${APACHE_MODULE_SRCDIR} && ${APXS} -c -o			\
		${APACHE_MODULE_NAME} ${APACHE_MODULE_SRC}

do-build: apache-module-build
	${_PKG_SILENT}${_PKG_DEBUG}${DO_NADA}

apache-module-install:
	${_PKG_SILENT}${PKG_DEBUG}					\
	cd ${APACHE_MODULE_SRCDIR} && ${APXS} -i ${APACHE_MODULE_NAME}

do-install: apache-module-install
	${_PKG_SILENT}${_PKG_DEBUG}${DO_NADA}

.endif	# _APACHE_MODULE_MK
