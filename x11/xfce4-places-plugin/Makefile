# $NetBSD: Makefile,v 1.10 2011/04/22 13:42:18 obache Exp $

PKG_DESTDIR_SUPPORT=	user-destdir

.include "../../meta-pkgs/xfce4/Makefile.common"

XFCE4_VERSION=	1.0.0

DISTNAME=	xfce4-places-plugin-${XFCE4_VERSION}
PKGREVISION=	7
CATEGORIES=	x11
MASTER_SITES=	http://goodies.xfce.org/releases/xfce4-places-plugin/
COMMENT=	Xfce Places plugin

.include "../../sysutils/xfce4-thunar/buildlink3.mk"
.include "../../x11/xfce4-panel/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
