# $NetBSD: buildlink2.mk,v 1.1 2002/08/31 14:16:15 wiz Exp $

.if !defined(LIBA52_BUILDLINK2_MK)
LIBA52_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			liba52
BUILDLINK_DEPENDS.liba52?=		liba52>=0.7.4
BUILDLINK_PKGSRCDIR.liba52?=		../../audio/liba52

EVAL_PREFIX+=	BUILDLINK_PREFIX.liba52=liba52
BUILDLINK_PREFIX.liba52_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.liba52=			include/a52dec/*
BUILDLINK_FILES.liba52+=		lib/liba52.*

BUILDLINK_TARGETS+=	liba52-buildlink

liba52-buildlink: _BUILDLINK_USE

.endif	# LIBA52_BUILDLINK2_MK
