# $NetBSD: buildlink3.mk,v 1.9 2009/01/14 22:28:05 jmcneill Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBDVDREAD_BUILDLINK3_MK:=	${LIBDVDREAD_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libdvdread
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibdvdread}
BUILDLINK_PACKAGES+=	libdvdread
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}libdvdread

.if !empty(LIBDVDREAD_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.libdvdread+=	libdvdread>=4.1.3
BUILDLINK_ABI_DEPENDS.libdvdread+=	libdvdread>=4.1.3
BUILDLINK_PKGSRCDIR.libdvdread?=	../../multimedia/libdvdread
.endif	# LIBDVDREAD_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
