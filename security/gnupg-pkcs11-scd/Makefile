# $NetBSD: Makefile,v 1.2 2011/04/22 13:44:34 obache Exp $
#

VERSION=	0.7.0
DISTNAME=	gnupg-pkcs11-scd-${VERSION}
PKGREVISION=	1
CATEGORIES=	security
MASTER_SITES=	${MASTER_SITE_SOURCEFORGE:=gnupg-pkcs11/gnupg-pkcs11-scd/${VERSION}/}
EXTRACT_SUFX=	.tar.bz2

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	http://gnupg-pkcs11.sourceforge.net/
COMMENT=	OpenSC smart card support for GnuPG
LICENSE=	modified-bsd

PKG_DESTDIR_SUPPORT=	user-destdir

GNU_CONFIGURE=	yes
USE_TOOLS+=     pkg-config
LIBS.OperatingSystem+=	-ldl
CONFIGURE_ARGS+=	--with-libgpg-error-prefix=${PREFIX}
CONFIGURE_ARGS+=	--with-libassuan-prefix=${PREFIX}
CONFIGURE_ARGS+=	--with-libgcrypt-prefix=${PREFIX}

.include "../../mk/dlopen.buildlink3.mk"
.include "../../mk/pthread.buildlink3.mk"
.include "../../security/pkcs11-helper/buildlink3.mk"
.include "../../security/openssl/buildlink3.mk"
.include "../../security/libgpg-error/buildlink3.mk"
.include "../../security/libassuan2/buildlink3.mk"
.include "../../security/libgcrypt/buildlink3.mk"

# url2pkg-marker (please do not remove this line.)
.include "../../mk/bsd.pkg.mk"
