# $NetBSD: buildlink3.mk,v 1.5 2004/10/03 00:14:49 tv Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
CAL3D_BUILDLINK3_MK:=	${CAL3D_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	cal3d
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ncal3d}
BUILDLINK_PACKAGES+=	cal3d

.if !empty(CAL3D_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.cal3d+=	cal3d>=0.9.1
BUILDLINK_RECOMMENDED.cal3d+=	cal3d>=0.9.1nb1
BUILDLINK_PKGSRCDIR.cal3d?=	../../graphics/cal3d
.endif	# CAL3D_BUILDLINK3_MK

.include "../../graphics/Mesa/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
