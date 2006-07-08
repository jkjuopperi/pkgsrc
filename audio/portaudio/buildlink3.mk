# $NetBSD: buildlink3.mk,v 1.7 2006/07/08 22:39:01 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PORTAUDIO_BUILDLINK3_MK:=	${PORTAUDIO_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	portaudio
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nportaudio}
BUILDLINK_PACKAGES+=	portaudio
BUILDLINK_ORDER+=	portaudio

.if !empty(PORTAUDIO_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.portaudio+=	portaudio>=18.1
BUILDLINK_ABI_DEPENDS.portaudio?=	portaudio>=18.1nb2
BUILDLINK_PKGSRCDIR.portaudio?=	../../audio/portaudio
.endif	# PORTAUDIO_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
