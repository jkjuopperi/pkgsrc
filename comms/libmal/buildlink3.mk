# $NetBSD: buildlink3.mk,v 1.5 2006/04/12 10:27:03 rillig Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBMAL_BUILDLINK3_MK:=	${LIBMAL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libmal
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibmal}
BUILDLINK_PACKAGES+=	libmal

.if !empty(LIBMAL_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.libmal+=	libmal>=0.40
BUILDLINK_ABI_DEPENDS.libmal+=	libmal>=0.40nb2
BUILDLINK_PKGSRCDIR.libmal?=	../../comms/libmal
.endif	# LIBMAL_BUILDLINK3_MK

.include "../../comms/pilot-link-libs/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
