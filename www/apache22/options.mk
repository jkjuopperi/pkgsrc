# $NetBSD: options.mk,v 1.1.1.1 2006/12/08 23:31:52 xtraeme Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.apache
PKG_SUPPORTED_OPTIONS=	suexec

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Msuexec)
BUILD_DEFS+=		VARBASE APACHE_USER APACHE_SUEXEC_PATH
BUILD_DEFS+=		APACHE_SUEXEC_DOCROOT APACHE_SUEXEC_LOGFILE

APACHE_SUEXEC_DOCROOT?=	${PREFIX}/share/httpd/htdocs
APACHE_SUEXEC_PATH=	/bin:/usr/bin:${PREFIX}/bin:/usr/local/bin
APACHE_SUEXEC_LOGFILE?=	${VARBASE}/log/httpd/suexec.log
APACHE_SUEXEC_CONFIGURE_ARGS+=						\
	--with-suexec-bin=${PREFIX}/sbin/suexec				\
	--with-suexec-caller=${APACHE_USER}				\
	--with-suexec-safepath='${APACHE_SUEXEC_PATH:Q}'		\
	--with-suexec-docroot=${APACHE_SUEXEC_DOCROOT:Q}		\
	--with-suexec-logfile=${APACHE_SUEXEC_LOGFILE:Q}

APACHE_MODULES+=        suexec
CONFIGURE_ARGS+=        ${APACHE_SUEXEC_CONFIGURE_ARGS:M--with-suexec-*}
BUILD_DEFS+=            APACHE_SUEXEC_CONFIGURE_ARGS
PLIST_SUBST+=           SUEXEC_COMMENT=
.else
PLIST_SUBST+=           SUEXEC_COMMENT="@comment "
.endif
