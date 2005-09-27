# $NetBSD: buildlink3.mk,v 1.2 2005/09/27 12:24:06 tonio Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
BTPARSE_BUILDLINK3_MK:=	${BTPARSE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	btparse
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nbtparse}
BUILDLINK_PACKAGES+=	btparse

.if !empty(BTPARSE_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.btparse+=	btparse>=0.34
BUILDLINK_PKGSRCDIR.btparse?=	../../textproc/btparse
.endif	# BTPARSE_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
