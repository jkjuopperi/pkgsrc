# $NetBSD: Makefile,v 1.7 2010/01/30 18:25:11 joerg Exp $
#

DISTNAME=		ocaml-mysql-1.0.4
PKGREVISION=		2
CATEGORIES=		databases
MASTER_SITES=		http://raevnos.pennmush.org/code/ocaml-mysql/

MAINTAINER=		pkgsrc-users@NetBSD.org
HOMEPAGE=		http://raevnos.pennmush.org/code/ocaml-mysql/
COMMENT=		Ocaml library for MySQL database access

PKG_DESTDIR_SUPPORT=	user-destdir

BUILD_DEPENDS+=		ocaml-findlib-[0-9]*:../../devel/ocaml-findlib

USE_PKGLOCALEDIR=	yes
GNU_CONFIGURE=		yes
USE_TOOLS+=		gmake

DOCDIR=			${PREFIX}/share/doc/ocaml-mysql
INSTALLATION_DIRS=	${DOCDIR}

post-install:
	cd ${WRKSRC}/doc/html && ${INSTALL_DATA} *.html ${DESTDIR}${DOCDIR}

.include "../../lang/ocaml/buildlink3.mk"
.include "../../databases/mysql5-client/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
