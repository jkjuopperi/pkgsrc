# $NetBSD: Makefile,v 1.6 2008/06/20 01:09:31 joerg Exp $

DISTNAME=	vmpsd-1.3
PKGNAME=	openvmps-1.3
PKGREVISION=	2
CATEGORIES=	net
MASTER_SITES=	${MASTER_SITE_SOURCEFORGE:=vmps/}

MAINTAINER=	bouyer@NetBSD.org
HOMEPAGE=	http://vmps.sourceforge.net/
COMMENT=	GPL implementation of the VMPS protocol

PKG_DESTDIR_SUPPORT=	user-destdir

WRKSRC=		${WRKDIR}/vmpsd

GNU_CONFIGURE=	YES

EGDIR=		${PREFIX}/share/examples/openvmps
RCD_SCRIPTS=	vmpsd
RCD_SCRIPT_WRK.vmpsd= ${WRKDIR}/vmpsd.rcd #conflict with ${WRKSRC}

CONF_FILES=	${EGDIR}/vlan.db ${PKG_SYSCONFDIR}/vlan.db

.include "../../mk/bsd.pkg.mk"
