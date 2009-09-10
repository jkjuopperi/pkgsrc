# $NetBSD: buildlink3.mk,v 1.1.1.1 2009/09/10 20:16:44 wiz Exp $

BUILDLINK_TREE+=	bml

.if !defined(BML_BUILDLINK3_MK)
BML_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.bml+=	bml>=0.5.0
BUILDLINK_PKGSRCDIR.bml?=	../../nih/bml
.endif # BML_BUILDLINK3_MK

BUILDLINK_TREE+=	-bml
