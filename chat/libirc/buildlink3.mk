# $NetBSD: buildlink3.mk,v 1.3 2006/04/06 06:21:38 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBIRC_BUILDLINK3_MK:=	${LIBIRC_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libirc
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibirc}
BUILDLINK_PACKAGES+=	libirc

.if !empty(LIBIRC_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.libirc+=	libirc>=0.2nb1
BUILDLINK_ABI_DEPENDS.libirc+=	libirc>=0.2nb2
BUILDLINK_PKGSRCDIR.libirc?=	../../chat/libirc
.endif	# LIBIRC_BUILDLINK3_MK

.include "../../devel/glib/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
