# $NetBSD: Makefile,v 1.13 2011/04/22 13:43:49 obache Exp $

DISTNAME=		koverartist-0.5
PKGREVISION=		10
CATEGORIES=		graphics kde
MASTER_SITES=		# empty
EXTRACT_SUFX=		.tar.bz2

MAINTAINER=		markd@NetBSD.org
HOMEPAGE=		http://www.kde-apps.org/content/show.php?content=38195
COMMENT=		CD/DVD case designer

PKG_DESTDIR_SUPPORT=	user-destdir

USE_TOOLS+=		gmake msgfmt perl
USE_LANGUAGES=		c c++
USE_LIBTOOL=		yes
GNU_CONFIGURE=		yes

WRKSRC=			${WRKDIR}/koverartist

.include "../../meta-pkgs/kde3/kde3.mk"
.include "../../graphics/hicolor-icon-theme/buildlink3.mk"
.include "../../x11/kdelibs3/buildlink3.mk"

.include "../../mk/bsd.pkg.mk"
