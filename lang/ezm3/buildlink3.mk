# $NetBSD: buildlink3.mk,v 1.7 2009/03/20 19:24:48 joerg Exp $

BUILDLINK_TREE+=	ezm3

.if !defined(EZM3_BUILDLINK3_MK)
EZM3_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.ezm3+=	ezm3>=1.1nb1
BUILDLINK_DEPMETHOD.ezm3?=	build
BUILDLINK_ABI_DEPENDS.ezm3?=	ezm3>=1.2nb1
BUILDLINK_PKGSRCDIR.ezm3?=	../../lang/ezm3

BUILDLINK_PASSTHRU_DIRS+=	${PREFIX}/ezm3
.endif # EZM3_BUILDLINK3_MK

BUILDLINK_TREE+=	-ezm3
