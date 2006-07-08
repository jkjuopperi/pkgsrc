# $NetBSD: buildlink3.mk,v 1.6 2006/07/08 23:10:35 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
FLUIDSYNTH_BUILDLINK3_MK:=	${FLUIDSYNTH_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	fluidsynth
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nfluidsynth}
BUILDLINK_PACKAGES+=	fluidsynth
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}fluidsynth

.if !empty(FLUIDSYNTH_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.fluidsynth+=		fluidsynth>=1.0.5
BUILDLINK_PKGSRCDIR.fluidsynth?=	../../audio/fluidsynth
.endif	# FLUIDSYNTH_BUILDLINK3_MK

.include "../../devel/readline/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
