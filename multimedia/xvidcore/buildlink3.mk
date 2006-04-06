# $NetBSD: buildlink3.mk,v 1.8 2006/04/06 06:22:30 reed Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
XVIDCORE_BUILDLINK3_MK:=	${XVIDCORE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	xvidcore
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxvidcore}
BUILDLINK_PACKAGES+=	xvidcore

.if !empty(XVIDCORE_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.xvidcore+=	xvidcore>=1.0.0
BUILDLINK_ABI_DEPENDS.xvidcore?=	xvidcore>=1.1.0nb1
BUILDLINK_PKGSRCDIR.xvidcore?=	../../multimedia/xvidcore
.endif	# XVIDCORE_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
