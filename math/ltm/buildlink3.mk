# $NetBSD: buildlink3.mk,v 1.7 2009/03/20 19:24:57 joerg Exp $

BUILDLINK_TREE+=	ltm

.if !defined(LTM_BUILDLINK3_MK)
LTM_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.ltm+=	ltm>=0.30
BUILDLINK_ABI_DEPENDS.ltm?=	ltm>=0.30nb1
BUILDLINK_PKGSRCDIR.ltm?=	../../math/ltm
BUILDLINK_DEPMETHOD.ltm?=	build
.endif # LTM_BUILDLINK3_MK

BUILDLINK_TREE+=	-ltm
