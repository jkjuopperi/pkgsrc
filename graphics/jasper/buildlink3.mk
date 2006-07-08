# $NetBSD: buildlink3.mk,v 1.8 2006/07/08 22:39:19 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
JASPER_BUILDLINK3_MK:=	${JASPER_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	jasper
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Njasper}
BUILDLINK_PACKAGES+=	jasper
BUILDLINK_ORDER+=	jasper

.if !empty(JASPER_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.jasper+=	jasper>=1.600.0
BUILDLINK_ABI_DEPENDS.jasper+=	jasper>=1.701.0nb2
BUILDLINK_PKGSRCDIR.jasper?=	../../graphics/jasper
.endif	# JASPER_BUILDLINK3_MK

.include "../../graphics/jpeg/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
