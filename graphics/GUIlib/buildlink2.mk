# $NetBSD: buildlink2.mk,v 1.2 2002/08/25 19:22:43 jlam Exp $

.if !defined(GUILIB_BUILDLINK2_MK)
GUILIB_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		GUIlib
BUILDLINK_DEPENDS.GUIlib?=	GUIlib>=1.1.0
BUILDLINK_PKGSRCDIR.GUIlib?=	../../graphics/GUIlib

EVAL_PREFIX+=			BUILDLINK_PREFIX.GUIlib=GUIlib
BUILDLINK_PREFIX.GUIlib_DEFAULT=${LOCALBASE}
BUILDLINK_FILES.GUIlib=		include/GUI/*.h
BUILDLINK_FILES.GUIlib+=	lib/libGUI-*
BUILDLINK_FILES.GUIlib+=	lib/libGUI.*

.include "../../devel/SDL/buildlink2.mk"

BUILDLINK_TARGETS+=	GUIlib-buildlink

GUIlib-buildlink: _BUILDLINK_USE

.endif	# GUILIB_BUILDLINK2_MK
