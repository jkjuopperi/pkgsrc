# $NetBSD: Makefile,v 1.16 2009/03/18 18:38:00 darcy Exp $
#

DISTNAME=	generate-2.6
PKGREVISION=	1
PKGNAME=	${PYPKGPREFIX}-${DISTNAME}
CATEGORIES=	devel python
MASTER_SITES=	ftp://ftp.druid.net/pub/distrib/
EXTRACT_SUFX=	.tgz

OWNER=		darcy@NetBSD.org
HOMEPAGE=	http://www.druid.net/darcy/readme-generate.html
COMMENT=	Python interface to Generate

PKG_DESTDIR_SUPPORT=	user-destdir

MAKE_ENV+=		MANDIR=${DESTDIR}${PREFIX}/${PKGMANDIR}
MAKE_ENV+=		BINDIR=${DESTDIR}${PREFIX}/bin
USE_TOOLS+=		gmake

LIBS.SunOS+=	-lnsl -lsocket
LIBS.QNX=		-lsocket

PYDISTUTILSPKG=	yes

.include "../../lang/python/extension.mk"
.include "../../mk/bsd.pkg.mk"
