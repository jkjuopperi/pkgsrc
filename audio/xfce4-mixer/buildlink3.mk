# $NetBSD: buildlink3.mk,v 1.20 2007/04/12 09:55:08 martti Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
XFCE4_MIXER_BUILDLINK3_MK:=	${XFCE4_MIXER_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	xfce4-mixer
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxfce4-mixer}
BUILDLINK_PACKAGES+=	xfce4-mixer
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}xfce4-mixer

.if ${XFCE4_MIXER_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.xfce4-mixer+=	xfce4-mixer>=4.4.1
BUILDLINK_PKGSRCDIR.xfce4-mixer?=	../../audio/xfce4-mixer
.endif	# XFCE4_MIXER_BUILDLINK3_MK

.include "../../graphics/hicolor-icon-theme/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"
.include "../../x11/xfce4-panel/buildlink3.mk"
.include "../../devel/xfce4-dev-tools/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
