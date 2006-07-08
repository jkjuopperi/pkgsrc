# $NetBSD: buildlink3.mk,v 1.4 2006/07/08 22:39:16 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GEOS_BUILDLINK3_MK:=	${GEOS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	geos
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngeos}
BUILDLINK_PACKAGES+=	geos
BUILDLINK_ORDER+=	geos

.if !empty(GEOS_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.geos+=	geos>=2.0.0
BUILDLINK_PKGSRCDIR.geos?=	../../geography/geos
.endif	# GEOS_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
