# $NetBSD: buildlink3.mk,v 1.9 2006/06/12 16:28:05 wiz Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
SDL_SOUND_BUILDLINK3_MK:=	${SDL_SOUND_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	SDL_sound
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NSDL_sound}
BUILDLINK_PACKAGES+=	SDL_sound

.if !empty(SDL_SOUND_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.SDL_sound+=	SDL_sound>=1.0.1
BUILDLINK_ABI_DEPENDS.SDL_sound+=	SDL_sound>=1.0.1nb5
BUILDLINK_PKGSRCDIR.SDL_sound?=	../../audio/SDL_sound
.endif	# SDL_SOUND_BUILDLINK3_MK

.include "../../audio/libmikmod/buildlink3.mk"
.include "../../audio/libvorbis/buildlink3.mk"
.include "../../devel/SDL/buildlink3.mk"
.include "../../multimedia/smpeg/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
