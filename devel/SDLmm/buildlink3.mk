# $NetBSD: buildlink3.mk,v 1.3 2005/12/11 09:40:38 wiz Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
SDLMM_BUILDLINK3_MK:=	${SDLMM_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	SDLmm
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NSDLmm}
BUILDLINK_PACKAGES+=	SDLmm

.if !empty(SDLMM_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.SDLmm+=	SDLmm>=0.1.8nb1
BUILDLINK_RECOMMENDED.SDLmm?=	SDLmm>=0.1.8nb4
BUILDLINK_PKGSRCDIR.SDLmm?=	../../devel/SDLmm
.endif	# SDLMM_BUILDLINK3_MK

.include "../../devel/SDL/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
