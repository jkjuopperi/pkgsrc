# $NetBSD: buildlink2.mk,v 1.3 2003/03/14 19:37:41 jlam Exp $

.if !defined(OGLE_BUILDLINK2_MK)
OGLE_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		ogle
BUILDLINK_DEPENDS.ogle?=	ogle>=0.8.5
BUILDLINK_PKGSRCDIR.ogle?=	../../graphics/ogle

EVAL_PREFIX+=			BUILDLINK_PREFIX.ogle=ogle
BUILDLINK_PREFIX.ogle_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.ogle=		include/ogle/*.h
BUILDLINK_FILES.ogle+=		lib/ogle/libmsgevents.*
BUILDLINK_FILES.ogle+=		lib/ogle/libdvdcontrol.*

BUILDLINK_LDFLAGS.ogle=		-L${BUILDLINK_PREFIX.ogle}/lib/ogle
BUILDLINK_LDFLAGS.ogle+=	-Wl,${RPATH_FLAG}${BUILDLINK_PREFIX.ogle}/lib/ogle

BUILDLINK_TARGETS+=	ogle-buildlink

ogle-buildlink: _BUILDLINK_USE

.endif	# OGLE_BUILDLINK2_MK
