# $NetBSD: Makefile,v 1.31 2011/01/17 11:15:16 jmcneill Exp $
#

DISTNAME=	pwm-20060517
PKGNAME=	${DISTNAME:S/-/-1.0./}
PKGREVISION=	1
CATEGORIES=	wm x11
MASTER_SITES=	http://modeemi.fi/~tuomov/pwm/dl/

MAINTAINER=	salo@NetBSD.org
HOMEPAGE=	http://modeemi.fi/~tuomov/ion/pwm.html
COMMENT=	Window manager that frames multiple client windows in a single frame

PKG_INSTALLATION_TYPES=	overwrite pkgviews
PKG_DESTDIR_SUPPORT=	user-destdir

CONFLICTS+=	ion<=20040729nb2

USE_TOOLS+=	gmake

CFLAGS+=	-DPKG_SYSCONFDIR="\"${PKG_SYSCONFDIR}\""
MAKE_FLAGS+=	MANDIR=${PREFIX:Q}/${PKGMANDIR:Q}

PKG_SYSCONFSUBDIR=	pwm

EGDIR=		${PREFIX}/share/examples/pwm
CONF_FILES=	${EGDIR}/pwm.conf.default ${PKG_SYSCONFDIR}/pwm.conf

CONFS=		buttons-default.conf
CONFS+=		keys-default.conf
CONFS+=		menus-default.conf
CONFS+=		look-beoslike.conf
CONFS+=		look-brownsteel.conf
CONFS+=		look-cdelike.conf
.for f in ${CONFS}
CONF_FILES+=	${EGDIR}/${f} ${PKG_SYSCONFDIR}/${f}
.endfor

post-install:
	${INSTALL_DATA} ${FILESDIR}/look-cdelike.conf ${DESTDIR}${EGDIR}

.include "../../x11/libX11/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
