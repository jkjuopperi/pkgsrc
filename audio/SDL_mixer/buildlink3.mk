# $NetBSD: buildlink3.mk,v 1.5 2004/02/10 20:45:01 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
SDL_MIXER_BUILDLINK3_MK:=	${SDL_MIXER_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	SDL_mixer
.endif

.if !empty(SDL_MIXER_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=		SDL_mixer
BUILDLINK_DEPENDS.SDL_mixer+=	SDL_mixer>=1.2.5nb2
BUILDLINK_PKGSRCDIR.SDL_mixer?=	../../audio/SDL_mixer
BUILDLINK_INCDIRS.SDL_mixer?=	include/SDL

.  include "../../devel/SDL/buildlink3.mk"
.endif	# SDL_MIXER_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
