# $NetBSD: Makefile,v 1.7 2009/10/29 22:34:33 tnn Exp $
#

DISTNAME=		ljpg
PKGNAME=		ljpg-1.0
CATEGORIES=		graphics
MASTER_SITES=		ftp://ftp.cs.cornell.edu/pub/multimed/
EXTRACT_SUFX=		.tar.Z

MAINTAINER=		pkgsrc-users@NetBSD.org
HOMEPAGE=		ftp://ftp.cs.cornell.edu/pub/multimed/
COMMENT=		Lossless JPEG codec

PKG_DESTDIR_SUPPORT=	user-destdir

WRKSRC=			${WRKDIR}
DIST_SUBDIR=		${PKGNAME_NOREV}

BUILD_TARGET=		default

INSTALLATION_DIRS+=	bin ${PKGMANDIR}/man1	\
			  share/doc/ljpeg share/examples/ljpeg

post-install:
	${INSTALL_DATA} ${WRKSRC}/Copyright ${DESTDIR}${PREFIX}/share/doc/ljpeg
	${INSTALL_DATA} ${WRKSRC}/README ${DESTDIR}${PREFIX}/share/doc/ljpeg
	${INSTALL_DATA} ${WRKSRC}/F-18* ${DESTDIR}${PREFIX}/share/examples/ljpeg

.include "../../mk/bsd.pkg.mk"
