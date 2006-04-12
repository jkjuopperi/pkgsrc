# $NetBSD: buildlink3.mk,v 1.5 2006/04/12 10:27:31 rillig Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
SPREAD_BUILDLINK3_MK:=	${SPREAD_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	spread
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nspread}
BUILDLINK_PACKAGES+=	spread

.if !empty(SPREAD_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.spread+=	spread>=3.17.1
BUILDLINK_PKGSRCDIR.spread?=	../../net/spread
.endif	# SPREAD_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
