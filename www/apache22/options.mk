# $NetBSD: options.mk,v 1.5 2008/09/16 01:47:06 epg Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.apache
PKG_SUPPORTED_OPTIONS=	apache-shared-modules suexec

.include "../../mk/bsd.options.mk"

PLIST_VARS+=		suexec
.if !empty(PKG_OPTIONS:Msuexec)
PKG_USERS_VARS+=	APACHE_USER
PKG_GROUPS_VARS+=	APACHE_GROUP
BUILD_DEFS+=		VARBASE APACHE_SUEXEC_PATH
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
PLIST.suexec=		yes
SPECIAL_PERMS+=		sbin/suexec ${REAL_ROOT_USER} ${APACHE_GROUP} 4510
.endif
