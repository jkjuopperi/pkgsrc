# $NetBSD: buildlink3.mk,v 1.3 2005/12/11 09:40:38 wiz Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
SDL_GFX_BUILDLINK3_MK:=	${SDL_GFX_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	SDL_gfx
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NSDL_gfx}
BUILDLINK_PACKAGES+=	SDL_gfx

.if !empty(SDL_GFX_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.SDL_gfx+=	SDL_gfx>=2.0.3nb2
BUILDLINK_RECOMMENDED.SDL_gfx?=	SDL_gfx>=2.0.13nb2
BUILDLINK_PKGSRCDIR.SDL_gfx?=	../../devel/SDL_gfx
.endif	# SDL_GFX_BUILDLINK3_MK

.include "../../devel/SDL/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
