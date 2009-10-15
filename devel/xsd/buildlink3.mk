# $NetBSD: buildlink3.mk,v 1.1 2009/10/15 12:39:42 hasso Exp $

BUILDLINK_DEPMETHOD.xsd?=	build

BUILDLINK_TREE+=	xsd

.if !defined(XSD_BUILDLINK3_MK)
XSD_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.xsd+=	xsd>=3.2
BUILDLINK_ABI_DEPENDS.xsd+=	xsd>=3.2
BUILDLINK_PKGSRCDIR.xsd?=	../../devel/xsd

.endif # XSD_BUILDLINK3_MK

BUILDLINK_TREE+=	-xsd
