# $NetBSD: Makefile,v 1.5 2011/08/23 13:06:51 obache Exp $
#

DISTNAME=	gnome-mplayer-1.0.4
PKGREVISION=	1
CATEGORIES=	multimedia
MASTER_SITES=	http://gnome-mplayer.googlecode.com/files/

MAINTAINER=	obache@NetBSD.org
HOMEPAGE=	http://code.google.com/p/gnome-mplayer/
COMMENT=	GNOME Frontend for MPlayer
LICENSE=	gnu-gpl-v2

DEPENDS+=	mplayer-[0-9]*:../../multimedia/mplayer

PKG_DESTDIR_SUPPORT=	user-destdir

GNU_CONFIGURE=		yes
USE_LIBTOOL=		yes
USE_PKGLOCALEDIR=	yes
USE_TOOLS+=		pkg-config msgfmt

CONFIGURE_ARGS+=	--with-gconf
CONFIGURE_ARGS+=	--disable-gtk3

GCONF_SCHEMAS+=	gnome-mplayer.schemas

.include "options.mk"

.include "../../devel/GConf/schemas.mk"
.include "../../devel/glib2/buildlink3.mk"
.include "../../graphics/hicolor-icon-theme/buildlink3.mk"
.include "../../sysutils/desktop-file-utils/desktopdb.mk"
.include "../../sysutils/dbus/buildlink3.mk"
.include "../../sysutils/dbus-glib/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"
.include "../../x11/libX11/buildlink3.mk"
.include "../../x11/libXScrnSaver/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
