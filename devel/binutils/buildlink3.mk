# $NetBSD: buildlink3.mk,v 1.16 2006/04/06 06:21:44 reed Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
BINUTILS_BUILDLINK3_MK:=	${BINUTILS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	binutils
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nbinutils}
BUILDLINK_PACKAGES+=	binutils

.if !empty(BINUTILS_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.binutils+=		binutils>=2.15.0
BUILDLINK_PKGSRCDIR.binutils?=		../../devel/binutils
BUILDLINK_DEPMETHOD.binutils?=		build
.endif	# BINUTILS_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
