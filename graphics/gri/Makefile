# $NetBSD: Makefile,v 1.38 2011/04/22 13:43:47 obache Exp $

DISTNAME=		gri-2.12.18
PKGREVISION=		2
CATEGORIES=		graphics
MASTER_SITES=		${MASTER_SITE_SOURCEFORGE:=gri/}

MAINTAINER=		pkgsrc-users@NetBSD.org
HOMEPAGE=		http://gri.sourceforge.net/
COMMENT=		Language for scientific graphics applications

PKG_DESTDIR_SUPPORT=	user-destdir

BUILD_DEPENDS+=		ImageMagick-[0-9]*:../../graphics/ImageMagick
BUILD_DEPENDS+=		dvipsk-[0-9]*:../../print/dvipsk

GNU_CONFIGURE=		yes
USE_LANGUAGES=		c c++
USE_TOOLS+=		gmake gs:run makeinfo perl
REPLACE_PERL+=		src/gri_merge src/gri_unpage
INFO_FILES=		# PLIST
INSTALL_MAKE_FLAGS=	${MAKE_FLAGS} PKGINFODIR=${PKGINFODIR:Q}

TEX_DEPMETHOD=		build	

.include "../../mk/tex.buildlink3.mk"
.include "../../devel/netcdf/buildlink3.mk"
.include "../../devel/readline/buildlink3.mk"
.include "../../devel/popt/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
