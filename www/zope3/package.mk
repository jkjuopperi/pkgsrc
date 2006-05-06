# $NetBSD: package.mk,v 1.2 2006/05/06 22:38:28 wiz Exp $
#

DEPENDS+=		zope3>=3.2.1:../../www/zope3

.include "Makefile.common"

HAS_CONFIGURE=		yes
CONFIGURE_ARGS+=	--with-python ${PYTHONBIN} \
			--prefix ${ZOPE3_DIR} \
			--force

BUILD_TARGET=		build
