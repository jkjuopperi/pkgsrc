# $NetBSD: Makefile,v 1.19 2011/08/23 13:06:48 obache Exp $
#

DISTNAME=	gdbm-prim-1.15
PKGNAME=	${DISTNAME:S/-prim/_primitive/}
PKGREVISION=	3
CATEGORIES=	databases
MASTER_SITES=	${MASTER_SITE_LOCAL}
EXTRACT_SUFX=	.tar.gz-link.gz

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	# http://homepage.mac.com/leffert/FileSharing.html
COMMENT=	Shell primitives for working with GDBMs

PKG_DESTDIR_SUPPORT=	user-destdir

EXTRACT_OPTS=		-f tar
MAKE_ENV+=		BUILDLINK_LDFLAGS=${BUILDLINK_LDFLAGS:Q}
MAKE_ENV+=		PKGMANDIR=${PKGMANDIR:Q}
WRKSRC=			${WRKDIR}/${PKGNAME_NOREV}

.include "../../databases/gdbm/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
