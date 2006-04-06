# $NetBSD: buildlink3.mk,v 1.6 2006/04/06 06:22:32 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GNET_BUILDLINK3_MK:=	${GNET_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gnet
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngnet}
BUILDLINK_PACKAGES+=	gnet

.if !empty(GNET_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.gnet+=	gnet>=2.0.3nb1
BUILDLINK_ABI_DEPENDS.gnet+=	gnet>=2.0.7nb2
BUILDLINK_PKGSRCDIR.gnet?=	../../net/gnet
.endif	# GNET_BUILDLINK3_MK

.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
