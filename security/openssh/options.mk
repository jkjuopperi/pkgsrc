# $NetBSD: options.mk,v 1.11 2007/01/20 10:03:39 taca Exp $

.include "../../mk/bsd.prefs.mk"

PKG_OPTIONS_VAR=	PKG_OPTIONS.openssh
PKG_SUPPORTED_OPTIONS=	kerberos hpn-patch

.if !empty(OPSYS:MLinux)
PKG_SUPPORTED_OPTIONS+= pam
.endif

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Mkerberos)
.  include "../../mk/krb5.buildlink3.mk"
CONFIGURE_ARGS+=        --with-kerberos5=${KRB5BASE:Q}
.endif

.if !empty(PKG_OPTIONS:Mhpn-patch)
PATCHFILES=		openssh-4.5p1-hpn12v14.diff.gz
PATCH_SITES=		http://www.psc.edu/networking/projects/hpn-ssh/
PATCH_DIST_STRIP=	-p1
.endif

.if !empty(PKG_OPTIONS:Mpam)
# XXX: PAM authentication causes memory faults, and haven't tracked down
# XXX: why yet.  For the moment, disable PAM authentication for non-Linux.
.include "../../mk/pam.buildlink3.mk"
CONFIGURE_ARGS+=	--with-pam
PLIST_SRC+=		${.CURDIR}/PLIST.pam
MESSAGE_SRC+=		${.CURDIR}/MESSAGE.pam
MESSAGE_SUBST+=		EGDIR=${EGDIR}
.endif
