# $NetBSD: Makefile,v 1.18 2011/04/22 13:45:16 obache Exp $

PKG_DESTDIR_SUPPORT=	user-destdir

.include "../../meta-pkgs/xfce4/Makefile.common"

XFCE4_VERSION=	2.6.0

DISTNAME=	gtk-xfce-engine-${XFCE4_VERSION}
PKGNAME=	xfce4-gtk2-engine-${XFCE4_VERSION}
PKGREVISION=	5
CATEGORIES=	x11
COMMENT=	Xfce GTK2 themes

MAKE_DIRS+=	${PREFIX}/share/themes/Xfce

.include "../../x11/gtk2/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
