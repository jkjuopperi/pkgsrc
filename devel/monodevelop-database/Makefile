# $NetBSD: Makefile,v 1.6 2011/07/21 13:05:51 obache Exp $

DISTNAME=	monodevelop-database-2.4
PKGREVISION=	5
CATEGORIES=	devel
MASTER_SITES=	http://ftp.novell.com/pub/mono/sources/monodevelop-database/
EXTRACT_SUFX=	.tar.bz2

MAINTAINER=	kefren@NetBSD.org
HOMEPAGE=	http://monodevelop.com/
COMMENT=	IDE for C\# and other .NET languages

PKG_DESTDIR_SUPPORT=	user-destdir

.include "options.mk"

GNU_CONFIGURE=	yes
USE_TOOLS+=	gmake pkg-config msgfmt
EXTRACT_USING=	gtar
MAKE_JOBS_SAFE=	no

.include "../../devel/mono-addins/buildlink3.mk"
.include "../../devel/monodevelop/buildlink3.mk"
.include "../../lang/mono/buildlink3.mk"
.include "../../x11/gtk-sharp/buildlink3.mk"
.include "../../x11/gnome-sharp/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
