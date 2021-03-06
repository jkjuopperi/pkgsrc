# $NetBSD: Makefile,v 1.3 2011/07/21 13:05:48 obache Exp $

DISTNAME=	mysql-workbench-gpl-5.2.33b-src
PKGNAME=	${DISTNAME:S/-gpl//:S/b-src$//}
PKGREVISION=	2
CATEGORIES=	databases
MASTER_SITES=	${MASTER_SITE_MYSQL:=MySQLGUITools/}

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	http://wb.mysql.com/
COMMENT=	Cross-platform, visual database design tool
LICENSE=	gnu-gpl-v2

WRKSRC=		${WRKDIR}/${DISTNAME:S/b-src$/-src/}

PKG_DESTDIR_SUPPORT=	user-destdir

USE_LANGUAGES=		c c++
USE_LIBTOOL=		yes
USE_TOOLS+=		bash gmake
GNU_CONFIGURE=		yes
CONFIGURE_ARGS+=	--with-system-ctemplate

CHECK_PORTABILITY_SKIP=	build/make_dmg.sh
CHECK_PORTABILITY_SKIP+=ext/ctemplate/ctemplate-src/configure.ac

SUBST_CLASSES+=		python
SUBST_STAGE.python=	pre-configure
SUBST_MESSAGE.python=	Fixing hardcoded python binary
SUBST_FILES.python=	configure configure.in
SUBST_SED.python=	-e "s,python -c,${PYTHONBIN} -c,g"

SUBST_CLASSES+=		bash
SUBST_STAGE.bash=	pre-install
SUBST_MESSAGE.bash=	Fixing hardcoded bash path
SUBST_FILES.bash=	frontend/linux/workbench/mysql-workbench
SUBST_SED.bash=		-e "s,/bin/bash,${BASH},g"

pre-build:
	${CP} ${WRKSRC}/res/include/wb_config_gpl.h ${WRKSRC}/wb_config.h

.if exists(/System/Library/Frameworks/OpenGL.framework)
CONFIGURE_ENV+=		ac_cv_header_GL_gl_h=yes
CONFIGURE_ENV+=		ac_cv_header_GL_glx_h=yes

SUBST_CLASSES+=		osx-gl
SUBST_STAGE.osx-gl=	pre-configure
SUBST_MESSAGE.osx-gl=	Using Mac OS X OpenGL
SUBST_FILES.osx-gl=	configure
SUBST_SED.osx-gl=	-e 's,-lGL,-framework OpenGL,g'
.else
.include "../../graphics/MesaLib/buildlink3.mk"
.endif

.include "../../archivers/libzip/buildlink3.mk"
.include "../../databases/sqlite3/buildlink3.mk"
.include "../../devel/boost-headers/buildlink3.mk"
.include "../../devel/ctemplate/buildlink3.mk"
.include "../../devel/libglade/buildlink3.mk"
.include "../../devel/libgnome/buildlink3.mk"
.include "../../devel/libuuid/buildlink3.mk"
.include "../../devel/pcre/buildlink3.mk"
.include "../../graphics/cairo/buildlink3.mk"
.include "../../lang/python/pyversion.mk"
.include "../../lang/lua/buildlink3.mk"
.include "../../security/gnome-keyring/buildlink3.mk"
.include "../../sysutils/desktop-file-utils/desktopdb.mk"
.include "../../textproc/libxml2/buildlink3.mk"
.include "../../x11/gtkmm/buildlink3.mk"
.include "../../mk/mysql.buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
