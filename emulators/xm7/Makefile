# $NetBSD: Makefile,v 1.27 2009/05/19 08:59:13 wiz Exp $
#

DISTNAME=		xm71010s
PKGNAME=		xm7-1010s
PKGREVISION=		1
CATEGORIES=		emulators
MASTER_SITES=		http://www.ipc-tokai.or.jp/~ytanaka/fm7/
EXTRACT_SUFX=		.lzh

MAINTAINER=		tech-pkg-ja@jp.NetBSD.org
HOMEPAGE=		http://www.ipc-tokai.or.jp/~ytanaka/fm7/xm7.shtml
COMMENT=		X11-based FM-7 emulator
LICENSE=		xm7-license

RESTRICTED=		source archive is not redistributable
NO_BIN_ON_CDROM=	${RESTRICTED}
NO_SRC_ON_CDROM=	${RESTRICTED}
NO_BIN_ON_FTP=		${RESTRICTED}
NO_SRC_ON_FTP=		${RESTRICTED}

BUILD_DEPENDS+=		nkf>=1.7:../../converters/nkf

PKG_DESTDIR_SUPPORT=	user-destdir
NOT_FOR_BULK_PLATFORM=	Linux-*-*

EXTRACT_OPTS_LHA=	qt	# convert CRLF to LF

WRKSRC=			${WRKDIR}/vm
NO_CONFIGURE=		yes
MAKE_FILE=		makefile.x11
INSTALLATION_DIRS=	bin

post-extract:
	cd ${WRKDIR} && mv linux/* vm

do-install:
	${INSTALL_PROGRAM} ${WRKDIR}/vm/xm7 ${DESTDIR}${PREFIX}/bin

.include "../../x11/libXext/buildlink3.mk"
.include "../../x11/libXt/buildlink3.mk"
.include "../../x11/xextproto/buildlink3.mk"
.include "../../mk/oss.buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
