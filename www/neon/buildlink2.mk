# $NetBSD: buildlink2.mk,v 1.7 2003/05/25 09:34:30 epg Exp $

.if !defined(NEON_BUILDLINK2_MK)
NEON_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		neon
BUILDLINK_DEPENDS.neon?=	neon>=0.23.9
BUILDLINK_PKGSRCDIR.neon?=	../../www/neon

EVAL_PREFIX+=			BUILDLINK_PREFIX.neon=neon
BUILDLINK_PREFIX.neon_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.neon=		include/neon/*
BUILDLINK_FILES.neon+=		lib/libneon.*

.include "../../devel/zlib/buildlink2.mk"
.include "../../security/openssl/buildlink2.mk"
.include "../../textproc/expat/buildlink2.mk"

BUILDLINK_TARGETS+=		neon-buildlink

neon-buildlink: _BUILDLINK_USE

.endif	# NEON_BUILDLINK2_MK
