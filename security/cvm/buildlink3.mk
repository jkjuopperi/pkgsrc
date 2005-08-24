# $NetBSD: buildlink3.mk,v 1.2 2005/08/24 04:49:31 schmonz Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
CVM_BUILDLINK3_MK:=	${CVM_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	cvm
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ncvm}
BUILDLINK_PACKAGES+=	cvm

.if !empty(CVM_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.cvm+=		cvm>=0.75
BUILDLINK_PKGSRCDIR.cvm?=	../../security/cvm
BUILDLINK_DEPMETHOD.cvm?=	build
.endif	# CVM_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
