# $NetBSD: buildlink2.mk,v 1.8 2004/03/26 02:27:59 wiz Exp $
#

.if !defined(GNUSTEP_BACK_BUILDLINK2_MK)
GNUSTEP_BACK_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			gnustep-back
BUILDLINK_DEPENDS.gnustep-back?=	gnustep-back>=0.9.0nb1
BUILDLINK_RECOMMENDED.gnustep-back?=	gnustep-back>=0.9.0nb3
BUILDLINK_PKGSRCDIR.gnustep-back?=	../../x11/gnustep-back

EVAL_PREFIX+=	BUILDLINK_PREFIX.gnustep-back=gnustep-back
BUILDLINK_PREFIX.gnustep-back_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.gnustep-back=	share/GNUstep/System/Headers/gnustep/gsc/*
BUILDLINK_FILES.gnustep-back+=	share/GNUstep/System/Headers/gnustep/x11/*
BUILDLINK_FILES.gnustep-back+=	share/GNUstep/System/Headers/gnustep/xlib/*

.include "../../graphics/libart2/buildlink2.mk"
.include "../../x11/gnustep-gui/buildlink2.mk"

BUILDLINK_TARGETS+=	gnustep-back-buildlink

gnustep-back-buildlink: _BUILDLINK_USE

.endif	# GNUSTEP_BACK_BUILDLINK2_MK
