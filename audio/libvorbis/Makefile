# $NetBSD: Makefile,v 1.51 2010/11/09 13:12:11 adam Exp $

DISTNAME=	libvorbis-1.3.2
CATEGORIES=	devel audio
MASTER_SITES=	http://downloads.xiph.org/releases/vorbis/
EXTRACT_SUFX=	.tar.bz2

MAINTAINER=	wiz@NetBSD.org
HOMEPAGE=	http://www.xiph.org/vorbis/
COMMENT=	Library for the Ogg Vorbis audio encoding format
LICENSE=	modified-bsd

PKG_INSTALLATION_TYPES=	overwrite pkgviews
PKG_DESTDIR_SUPPORT=	user-destdir

USE_LIBTOOL=		yes
GNU_CONFIGURE=		yes

PKGCONFIG_OVERRIDE+=	vorbis.pc.in
PKGCONFIG_OVERRIDE+=	vorbisenc.pc.in
PKGCONFIG_OVERRIDE+=	vorbisfile.pc.in

.include "../../multimedia/libogg/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
