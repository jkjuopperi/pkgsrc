# $NetBSD: Makefile,v 1.18 2011/03/16 05:09:16 macallan Exp $

DISTNAME=	estd-r7
PKGNAME=	estd-0.7
CATEGORIES=	sysutils
MASTER_SITES=	http://www.ecademix.com/JohannesHofmann/

MAINTAINER=	dillo@NetBSD.org
HOMEPAGE=	http://www.ecademix.com/JohannesHofmann/estd.html
COMMENT=	Dynamically sets the CPU-frequency on SpeedStep and PowerNow CPUs
LICENSE=	2-clause-bsd

PKG_DESTDIR_SUPPORT=	user-destdir

INSTALLATION_DIRS=	share/examples/rc.d

ONLY_FOR_PLATFORM=	NetBSD-2.99.*-i386 NetBSD-[3-9]*-i386 \
			NetBSD-[4-9]*-x86_64 DragonFly-*-i386 \
			NetBSD-5.99.*-powerpc

RCD_SCRIPTS=		estd
RCD_SCRIPT_SRC.estd=	${WRKSRC}/estd.sh

SUBST_CLASSES+=		rcd
SUBST_STAGE.rcd=	do-configure
SUBST_MESSAGE.rcd=	Fixing startup script.
SUBST_FILES.rcd=	estd.sh
SUBST_SED.rcd=		-e 's|@PREFIX@|${PREFIX}|'
SUBST_SED.rcd+=		-e 's|@ECHO@|${ECHO}|'

.include "../../mk/bsd.pkg.mk"
