# $NetBSD: buildlink3.mk,v 1.2 2004/03/05 19:25:35 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBEXIF_BUILDLINK3_MK:=	${LIBEXIF_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libexif
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibexif}
BUILDLINK_PACKAGES+=	libexif

.if !empty(LIBEXIF_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libexif+=	libexif>=0.5.12
BUILDLINK_PKGSRCDIR.libexif?=	../../graphics/libexif

.include "../../devel/gettext-lib/buildlink3.mk"

.endif	# LIBEXIF_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
