# $NetBSD: buildlink3.mk,v 1.10 2006/07/08 23:10:50 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
CAL3D_BUILDLINK3_MK:=	${CAL3D_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	cal3d
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ncal3d}
BUILDLINK_PACKAGES+=	cal3d
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}cal3d

.if !empty(CAL3D_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.cal3d+=	cal3d>=0.9.1
BUILDLINK_ABI_DEPENDS.cal3d+=	cal3d>=0.9.1nb2
BUILDLINK_PKGSRCDIR.cal3d?=	../../graphics/cal3d
.endif	# CAL3D_BUILDLINK3_MK

.include "../../graphics/Mesa/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
