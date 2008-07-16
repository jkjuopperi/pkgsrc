# $NetBSD: buildlink3.mk,v 1.2 2008/07/16 07:40:14 wiz Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
XLT_BUILDLINK3_MK:=	${XLT_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	xlt
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxlt}
BUILDLINK_PACKAGES+=	xlt
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}xlt

.if ${XLT_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.xlt+=	xlt>=13.0.13
BUILDLINK_PKGSRCDIR.xlt?=	../../x11/xlt
.endif	# XLT_BUILDLINK3_MK

.include "../../x11/libX11/buildlink3.mk"
.include "../../x11/libXext/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
