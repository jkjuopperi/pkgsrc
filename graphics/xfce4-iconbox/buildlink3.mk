# $NetBSD: buildlink3.mk,v 1.1 2004/03/10 11:53:37 xtraeme Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
XFCE4_ICONBOX_BUILDLINK3_MK:=	${XFCE4_ICONBOX_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	xfce4-iconbox
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxfce4-iconbox}
BUILDLINK_PACKAGES+=	xfce4-iconbox

.if !empty(XFCE4_ICONBOX_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.xfce4-iconbox+=	xfce4-iconbox>=4.0.4nb1
BUILDLINK_PKGSRCDIR.xfce4-iconbox?=	../../graphics/xfce4-iconbox

.include "../../x11/xfce4-mcs-plugins/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"

.endif	# XFCE4_ICONBOX_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
