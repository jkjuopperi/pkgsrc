# $NetBSD: buildlink2.mk,v 1.2 2002/08/25 19:21:46 jlam Exp $

.if !defined(FLAC_BUILDLINK2_MK)
FLAC_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		flac
BUILDLINK_DEPENDS.flac?=	flac>=1.0
BUILDLINK_PKGSRCDIR.flac?=	../../audio/flac

EVAL_PREFIX+=			BUILDLINK_PREFIX.flac=flac
BUILDLINK_PREFIX.flac_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.flac=		include/FLAC/*
BUILDLINK_FILES.flac+=		lib/libFLAC.*

BUILDLINK_TARGETS+=	flac-buildlink

flac-buildlink: _BUILDLINK_USE

.endif	# FLAC_BUILDLINK2_MK
