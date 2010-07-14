# $NetBSD: buildlink3.mk,v 1.8 2010/07/14 09:29:04 sbd Exp $

BUILDLINK_TREE+=	mDNSResponder

.if !defined(MDNSRESPONDER_BUILDLINK3_MK)
MDNSRESPONDER_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.mDNSResponder+=	mDNSResponder>=98
BUILDLINK_ABI_DEPENDS.mDNSResponder?=	mDNSResponder>=214.3.2
BUILDLINK_PKGSRCDIR.mDNSResponder?=	../../net/mDNSResponder
.endif # MDNSRESPONDER_BUILDLINK3_MK

BUILDLINK_TREE+=	-mDNSResponder
