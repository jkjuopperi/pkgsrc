# $NetBSD: Makefile,v 1.15 2010/10/09 11:55:22 obache Exp $
#

DISTNAME=		strace-4.5.15
PKGREVISION=		1
CATEGORIES=		sysutils
MASTER_SITES=		${MASTER_SITE_SOURCEFORGE:=strace/}
EXTRACT_SUFX=		.tar.bz2

MAINTAINER=		christos@NetBSD.org
HOMEPAGE=		http://sourceforge.net/projects/strace/
COMMENT=		Trace system calls
LICENSE=		modified-bsd

PKG_DESTDIR_SUPPORT=	user-destdir

#			NetBSD < 3.99.16
NOT_FOR_PLATFORM=	NetBSD-[012]*-* NetBSD-3.[0-9][._]*-* \
			NetBSD-3.99.[0-9]-* NetBSD-3.99.1[0-5]-*
NOT_FOR_PLATFORM+=	DragonFly-*-*

GNU_CONFIGURE=		yes

REPLACE_PERL=		strace-graph

.include "../../mk/bsd.prefs.mk"
.if ${OPSYS} == "Linux"
USE_TOOLS+=		autoconf
pre-configure:
	cd ${WRKSRC} && autoconf
.endif

.if ${OPSYS} == "NetBSD"
MAKE_ENV+=	NETBSD_SRCDIR=${BSD_SRCDIR:Q}
pre-configure:
	${CP} -f ${WRKSRC}/syscalls.pl ${WRKSRC}/netbsd

.endif

.include "../../mk/bsd.pkg.mk"