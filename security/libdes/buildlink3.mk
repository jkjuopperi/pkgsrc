# $NetBSD: buildlink3.mk,v 1.1 2004/04/12 20:46:28 snj Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBDES_BUILDLINK3_MK:=	${LIBDES_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libdes
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibdes}
BUILDLINK_PACKAGES+=	libdes

.if !empty(LIBDES_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libdes+=	libdes>=4.04b
BUILDLINK_PKGSRCDIR.libdes?=	../../security/libdes
BUILDLINK_DEPMETHOD.libdes?=	build
.endif	# LIBDES_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
