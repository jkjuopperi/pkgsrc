# $NetBSD: Makefile,v 1.15 2011/04/22 13:44:10 obache Exp $

DISTNAME=	kdeaccessibility-${_KDE_VERSION}
PKGREVISION=	1
CATEGORIES=	misc
COMMENT=	Accessibility support for the KDE integrated X11 desktop

.include "../../meta-pkgs/kde4/Makefile.kde4"

# BUILD_MAKE_FLAGS+= VERBOSE=1

CMAKE_ARGS+=	-DKDE4_KTTSD_ALSA:BOOL=OFF

.include "../../meta-pkgs/kde4/kde4.mk"

.include "../../graphics/hicolor-icon-theme/buildlink3.mk"
.include "../../sysutils/desktop-file-utils/desktopdb.mk"
.include "../../x11/kdelibs4/buildlink3.mk"
.include "../../x11/kdebase-runtime4/buildlink3.mk"
.include "../../x11/kdebase-workspace4/buildlink3.mk"

.include "../../mk/bsd.pkg.mk"
