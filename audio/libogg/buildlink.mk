# $NetBSD: buildlink.mk,v 1.3 2001/07/20 01:54:33 jlam Exp $
#
# This Makefile fragment is included by packages that use libogg.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.libogg to the dependency pattern
#     for the version of libogg desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(LIGOGG_BUILDLINK_MK)
LIGOGG_BUILDLINK_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

BUILDLINK_DEPENDS.libogg?=	libogg>=1.0.0.4
DEPENDS+=	${BUILDLINK_DEPENDS.libogg}:../../audio/libogg

EVAL_PREFIX+=			BUILDLINK_PREFIX.libogg=libogg
BUILDLINK_FILES.libogg=		include/ogg/config_types.h
BUILDLINK_FILES.libogg+=	include/ogg/ogg.h
BUILDLINK_FILES.libogg+=	include/ogg/os_types.h
BUILDLINK_FILES.libogg+=	lib/libogg.*

BUILDLINK_TARGETS.libogg=	libogg-buildlink
BUILDLINK_TARGETS+=	${BUILDLINK_TARGETS.libogg}

pre-configure: ${BUILDLINK_TARGETS.libogg}
libogg-buildlink: _BUILDLINK_USE

.endif	# LIGOGG_BUILDLINK_MK
