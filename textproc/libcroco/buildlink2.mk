# $NetBSD: buildlink2.mk,v 1.3 2004/01/04 18:00:28 xtraeme Exp $
#
# This Makefile fragment is included by packages that use libcroco.
#
# This file was created automatically using createbuildlink 2.6.
#

.if !defined(LIBCROCO_BUILDLINK2_MK)
LIBCROCO_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			libcroco
BUILDLINK_DEPENDS.libcroco?=		libcroco>=0.4.0
BUILDLINK_PKGSRCDIR.libcroco?=		../../textproc/libcroco

EVAL_PREFIX+=	BUILDLINK_PREFIX.libcroco=libcroco
BUILDLINK_PREFIX.libcroco_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.libcroco+=	include/libcroco/*.h
BUILDLINK_FILES.libcroco+=	include/libcroco/layeng/*.h
BUILDLINK_FILES.libcroco+=	include/libcroco/parser/*.h
BUILDLINK_FILES.libcroco+=	include/libcroco/seleng/*.h
BUILDLINK_FILES.libcroco+=	lib/libcrlayeng.*
BUILDLINK_FILES.libcroco+=	lib/libcroco.*
BUILDLINK_FILES.libcroco+=	lib/libcrseleng.*

.include "../../devel/glib2/buildlink2.mk"
.include "../../devel/libgnomeui/buildlink2.mk"
.include "../../devel/pango/buildlink2.mk"
.include "../../devel/pkgconfig/buildlink2.mk"
.include "../../textproc/libxml2/buildlink2.mk"

BUILDLINK_TARGETS+=	libcroco-buildlink

libcroco-buildlink: _BUILDLINK_USE

.endif	# LIBCROCO_BUILDLINK2_MK
