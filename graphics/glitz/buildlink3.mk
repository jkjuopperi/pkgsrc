# $NetBSD: buildlink3.mk,v 1.8 2006/04/12 10:27:17 rillig Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GLITZ_BUILDLINK3_MK:=	${GLITZ_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	glitz
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nglitz}
BUILDLINK_PACKAGES+=	glitz

.if !empty(GLITZ_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.glitz+=	glitz>=0.4.4
BUILDLINK_ABI_DEPENDS.glitz+=	glitz>=0.4.4nb2
BUILDLINK_PKGSRCDIR.glitz?=	../../graphics/glitz
.endif	# GLITZ_BUILDLINK3_MK

.include "../../graphics/MesaLib/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
