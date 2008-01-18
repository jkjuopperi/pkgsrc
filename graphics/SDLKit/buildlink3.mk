# $NetBSD: buildlink3.mk,v 1.12 2008/01/18 05:06:38 tnn Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
SDLKIT_BUILDLINK3_MK:=	${SDLKIT_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	SDLKit
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NSDLKit}
BUILDLINK_PACKAGES+=	SDLKit
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}SDLKit

.if !empty(SDLKIT_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.SDLKit+=	SDLKit>=0.3.1r2nb5
BUILDLINK_ABI_DEPENDS.SDLKit?=	SDLKit>=0.3.1r2nb17
BUILDLINK_PKGSRCDIR.SDLKit?=	../../graphics/SDLKit
.endif	# SDLKIT_BUILDLINK3_MK

.include "../../devel/SDL/buildlink3.mk"
.include "../../graphics/RenderKit/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
