# $NetBSD: buildlink3.mk,v 1.2 2006/02/05 23:09:36 joerg Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
OPENEXR_BUILDLINK3_MK:=	${OPENEXR_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	openexr
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nopenexr}
BUILDLINK_PACKAGES+=	openexr

.if !empty(OPENEXR_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.openexr+=	openexr>=1.2.1
BUILDLINK_RECOMMENDED.openexr?=	openexr>=1.2.2nb1
BUILDLINK_PKGSRCDIR.openexr?=	../../graphics/openexr
.endif	# OPENEXR_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
