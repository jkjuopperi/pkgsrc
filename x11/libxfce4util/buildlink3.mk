# $NetBSD: buildlink3.mk,v 1.2 2004/03/18 09:12:17 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBXFCE4UTIL_BUILDLINK3_MK:=	${LIBXFCE4UTIL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libxfce4util
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibxfce4util}
BUILDLINK_PACKAGES+=	libxfce4util

.if !empty(LIBXFCE4UTIL_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libxfce4util+=	libxfce4util>=4.0.4nb1
BUILDLINK_PKGSRCDIR.libxfce4util?=	../../x11/libxfce4util
.endif	# LIBXFCE4UTIL_BUILDLINK3_MK

.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
