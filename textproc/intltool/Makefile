# $NetBSD: Makefile,v 1.55 2011/08/21 11:23:14 obache Exp $
#

DISTNAME=		intltool-0.41.1
CATEGORIES=		textproc devel gnome
MASTER_SITES=		http://launchpad.net/intltool/trunk/${PKGVERSION_NOREV}/+download/

MAINTAINER=		pkgsrc-users@NetBSD.org
HOMEPAGE=		http://launchpad.net/intltool/
COMMENT=		Internationalization Tool Collection
LICENSE=		gnu-gpl-v2

PKG_INSTALLATION_TYPES=	overwrite pkgviews
PKG_DESTDIR_SUPPORT=	user-destdir

DEPENDS+=		p5-XML-Parser>=2.34nb4:../../textproc/p5-XML-Parser

CONFLICTS=		xml-i18n-tools-[0-9]*

USE_TOOLS+=		gmake perl:run
GNU_CONFIGURE=		YES
CHECK_INTERPRETER_SKIP=	share/intltool/*.in
TEST_TARGET=		check

.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../converters/libiconv/buildlink3.mk"

.include "../../mk/bsd.pkg.mk"
