# $NetBSD: Makefile,v 1.26 2011/01/13 13:38:14 wiz Exp $

MODNAME=		gd
PKGREVISION=		1
CATEGORIES+=		graphics
COMMENT=		PHP extension for GD graphics library

PKG_DESTDIR_SUPPORT=	user-destdir

CONFLICTS=	php-gd-[0-9]*

# XXX we use bundled GD so that extension is usable also by non-threaded
# PHP, such as CLI/CGI version or ap-php on Apache 1.x.

CONFIGURE_ARGS+=	--with-${MODNAME}
CONFIGURE_ARGS+=	--with-jpeg-dir=${BUILDLINK_DIR:Q}
CONFIGURE_ARGS+=	--with-png-dir=${BUILDLINK_DIR:Q}
CONFIGURE_ARGS+=	--with-zlib-dir=${BUILDLINK_DIR:Q}
CONFIGURE_ARGS+=	--with-freetype-dir=${BUILDLINK_DIR:Q}
CONFIGURE_ARGS+=	--enable-${MODNAME}-native-ttf
CONFIGURE_ARGS+=	--enable-${MODNAME}-jis-conv
CONFIGURE_ARGS+=	--without-t1lib

USE_PHP_EXT_PATCHES=	yes

.include "../../devel/zlib/buildlink3.mk"
.include "../../graphics/freetype2/buildlink3.mk"
.include "../../mk/jpeg.buildlink3.mk"
.include "../../graphics/png/buildlink3.mk"
.include "../../lang/php/ext.mk"
.include "../../mk/bsd.pkg.mk"
