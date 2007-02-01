# $NetBSD: buildlink3.mk,v 1.1.1.1 2007/02/01 16:52:28 drochner Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
WAVPACK_BUILDLINK3_MK:=	${WAVPACK_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	wavpack
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nwavpack}
BUILDLINK_PACKAGES+=	wavpack
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}wavpack

.if ${WAVPACK_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.wavpack+=	wavpack>=4.40.0
BUILDLINK_PKGSRCDIR.wavpack?=	../../audio/wavpack
.endif	# WAVPACK_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
