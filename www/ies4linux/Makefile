# $NetBSD: Makefile,v 1.5 2010/02/10 19:17:47 joerg Exp $
#

DISTNAME=	ies4linux-2.99.0.1
PKGREVISION=	2
CATEGORIES=	www
MASTER_SITES=	http://www.tatanka.com.br/ies4linux/downloads/

MAINTAINER=	abs@NetBSD.org
HOMEPAGE=	http://www.tatanka.com.br/ies4linux/page/Main_Page
COMMENT=	Microsoft Internet Explorer installer

DEPENDS+=  bash-[0-9]*:../../shells/bash
DEPENDS+=  unzip-[0-9]*:../../archivers/unzip
DEPENDS+=  wget-[0-9]*:../../net/wget
DEPENDS+=  wine-[0-9]*:../../emulators/wine
DEPENDS+=  ${PYPKGPREFIX}-gtk2-[0-9]*:../../x11/py-gtk2
BUILD_DEPENDS+= cabextract-[0-9]*:../../archivers/cabextract

NO_BUILD= 	yes
PKG_DESTDIR_SUPPORT=    user-destdir
USE_LANGUAGES=	# none
USE_TOOLS+=	pax

SHAREDIR=		share/ies4linux

SUBST_CLASSES+=		sharedir
SUBST_STAGE.sharedir=	post-patch
SUBST_FILES.sharedir=	${WRKSRC}/ies4linux
SUBST_SED.sharedir=	-e "s|.dirname ..0..|${PREFIX}/${SHAREDIR}|g"

INSTALLATION_DIRS	= bin ${SHAREDIR}

do-install:
	cd ${WRKSRC} && rm -f lib/functions.sh.orig
	cd ${WRKSRC} && rm -fr ui/.svn
	cd ${WRKSRC} && pax -rwppm . ${DESTDIR}${PREFIX}/${SHAREDIR}
	mv ${DESTDIR}${PREFIX}/${SHAREDIR}/ies4linux ${DESTDIR}${PREFIX}/bin

.include "../../lang/python/application.mk"
.include "../../mk/bsd.pkg.mk"
