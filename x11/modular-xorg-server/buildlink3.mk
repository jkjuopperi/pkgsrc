# $NetBSD: buildlink3.mk,v 1.3 2008/04/25 20:39:14 joerg Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
MODULAR_XORG_SERVER_BUILDLINK3_MK:=	${MODULAR_XORG_SERVER_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	modular-xorg-server
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nmodular-xorg-server}
BUILDLINK_PACKAGES+=	modular-xorg-server
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}modular-xorg-server

.if ${MODULAR_XORG_SERVER_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.modular-xorg-server+=	modular-xorg-server>=1.4
BUILDLINK_PKGSRCDIR.modular-xorg-server?=	../../x11/modular-xorg-server14
.endif	# MODULAR_XORG_SERVER_BUILDLINK3_MK

.include "../../x11/compositeproto/buildlink3.mk"
.include "../../x11/fontsproto/buildlink3.mk"
.include "../../x11/inputproto/buildlink3.mk"
.include "../../x11/pixman/buildlink3.mk"
.include "../../x11/randrproto/buildlink3.mk"
.include "../../x11/renderproto/buildlink3.mk"
.include "../../x11/videoproto/buildlink3.mk"
.include "../../x11/xextproto/buildlink3.mk"
.include "../../x11/xf86driproto/buildlink3.mk"
.include "../../x11/xproto/buildlink3.mk"

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH:S/+$//}
