# $NetBSD: Makefile,v 1.13 2011/02/25 09:47:27 wiz Exp $

DISTNAME=	pycups-${VERSION}
PKGNAME=	${PYPKGPREFIX}-cups-${VERSION}
VERSION=	1.9.47
PKGREVISION=	2
CATEGORIES=	print python
MASTER_SITES=	http://cyberelk.net/tim/data/pycups/
EXTRACT_SUFX=	.tar.bz2

MAINTAINER=	markd@NetBSD.org
HOMEPAGE=	http://cyberelk.net/tim/software/pycups/
COMMENT=	Python bindings for the CUPS API

PKG_DESTDIR_SUPPORT=	user-destdir
CFLAGS+=	-DVERSION=\"${VERSION}\"

PYTHON_VERSIONS_ACCEPTED=	27 26 25
PYDISTUTILSPKG=	yes

SUBST_CLASSES+=		paths
SUBST_MESSAGE.paths=	Fix cups paths.
SUBST_FILES.paths=	cupsconnection.c
SUBST_SED.paths=	-e 's:"/usr/share/cups":"${BUILDLINK_PREFIX.cups}/share/cups/", "/usr/share/cups":'
SUBST_STAGE.paths=	post-patch

.include "../../lang/python/extension.mk"
.include "../../print/cups/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
