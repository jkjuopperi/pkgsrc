# $NetBSD: Makefile,v 1.9 2007/12/01 03:57:28 rillig Exp $
#

DISTNAME=	chtfont
PKGREVISION=	1
CATEGORIES=	fonts

MAINTAINER=	tech-pkg-ja@jp.NetBSD.org
COMMENT=	Asian Font Packs for Acrobat Reader 4.0 (Chinese Traditional)

DEPENDS+=	acroread-font-share>=4.0nb2:../../fonts/acroread-font-share

WRKSRC=		${WRKDIR}/CHTKIT
TAR_FILE=	${WRKSRC}/LANGCHT.TAR

.include "../../fonts/acroread-font-share/Makefile.common"
