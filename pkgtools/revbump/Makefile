# $NetBSD: Makefile,v 1.17 2010/06/20 19:29:50 wiz Exp $

DISTNAME=		revbump-2.1
CATEGORIES=		pkgtools
MASTER_SITES=		# empty
DISTFILES=		# empty

MAINTAINER=		wiz@NetBSD.org
HOMEPAGE=		http://www.pkgsrc.org/
COMMENT=		Tools for bumping PKGREVISIONs (for pkgsrc developers)

PKG_INSTALLATION_TYPES=	overwrite pkgviews
PKG_DESTDIR_SUPPORT=	user-destdir

WRKSRC=		${WRKDIR}
NO_CONFIGURE=	yes
USE_TOOLS+=	perl:run
USE_LANGUAGES=	# empty

INSTALLATION_DIRS=	bin ${PKGMANDIR}/man1

do-build:
	${SED} -e "s!@PERL@!${PERL5}!g" -e "s! make ! ${MAKE} !g" \
		${FILESDIR}/blbump > ${WRKDIR}/blbump
	${SED} -e "s!@PERL@!${PERL5}!g" -e "s! make ! ${MAKE} !g" \
		${FILESDIR}/finddepends > ${WRKDIR}/finddepends
	${SED} -e "s!@PERL@!${PERL5}!g"  -e "s! make ! ${MAKE} !g" \
		${FILESDIR}/revbump > ${WRKDIR}/revbump

do-install:
	${INSTALL_SCRIPT} ${WRKDIR}/blbump ${DESTDIR}${PREFIX}/bin
	${INSTALL_MAN} ${FILESDIR}/blbump.1 ${DESTDIR}${PREFIX}/${PKGMANDIR}/man1
	${INSTALL_SCRIPT} ${WRKDIR}/finddepends ${DESTDIR}${PREFIX}/bin
	${INSTALL_MAN} ${FILESDIR}/finddepends.1 ${DESTDIR}${PREFIX}/${PKGMANDIR}/man1
	${INSTALL_SCRIPT} ${WRKDIR}/revbump ${DESTDIR}${PREFIX}/bin
	${INSTALL_MAN} ${FILESDIR}/revbump.1 ${DESTDIR}${PREFIX}/${PKGMANDIR}/man1

.include "../../mk/bsd.pkg.mk"
