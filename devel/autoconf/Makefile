# $NetBSD: Makefile,v 1.78 2010/09/24 09:46:42 wiz Exp $

DISTNAME=		autoconf-2.68
CATEGORIES=		devel
MASTER_SITES=		${MASTER_SITE_GNU:=autoconf/}

MAINTAINER=		wiz@NetBSD.org
HOMEPAGE=		http://www.gnu.org/software/autoconf/autoconf.html
COMMENT=		Generates automatic source code configuration scripts
LICENSE=		gnu-gpl-v3 AND gnu-fdl-v1.3

# XXX: needs m4>1.4.6; wants m4>1.4.13
USE_TOOLS+=		gm4:run perl:run

# The next line is for conflicts with old versions of this package,
# which had autoconf-devel as PKGNAME.
CONFLICTS=		autoconf-devel-[0-9]*
# old versions of devel/gdb6 installed standards.info as well.
CONFLICTS+=		gdb<6.2.1nb5

PKG_INSTALLATION_TYPES=	overwrite pkgviews
PKG_DESTDIR_SUPPORT=	user-destdir

USE_LANGUAGES=		# empty
GNU_CONFIGURE=		YES
CONFIGURE_ARGS+=	--without-lispdir
CONFIGURE_ENV+=		ac_cv_prog_TEST_EMACS=no

TEXINFO_REQD=		4.0
INFO_FILES=		YES

AUTOMAKE_OVERRIDE=	NO

# [GNU Autoconf 2.67] testsuite: 213 268 269 failed
# 213?; other two ok because of buildlink
TEST_TARGET=		check

CHECK_WRKREF_SKIP+=	${PREFIX}/share/autoconf/autoconf/autoconf.m4f
CHECK_WRKREF_SKIP+=	${PREFIX}/share/autoconf/autotest/autotest.m4f
CHECK_WRKREF_SKIP+=	${PREFIX}/share/autoconf/m4sugar/m4sugar.m4f
CHECK_WRKREF_SKIP+=	${PREFIX}/share/autoconf/m4sugar/m4sh.m4f


.include "../../mk/bsd.pkg.mk"
