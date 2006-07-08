# $NetBSD: buildlink3.mk,v 1.6 2006/07/08 23:10:52 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIB3DS_BUILDLINK3_MK:=	${LIB3DS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	lib3ds
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlib3ds}
BUILDLINK_PACKAGES+=	lib3ds
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}lib3ds

.if !empty(LIB3DS_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.lib3ds+=	lib3ds>=1.2.0nb2
BUILDLINK_ABI_DEPENDS.lib3ds?=	lib3ds>=1.2.0nb4
BUILDLINK_PKGSRCDIR.lib3ds?=	../../graphics/lib3ds
.endif	# LIB3DS_BUILDLINK3_MK

.include "../../graphics/Mesa/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
