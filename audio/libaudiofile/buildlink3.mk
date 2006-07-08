# $NetBSD: buildlink3.mk,v 1.13 2006/07/08 23:10:36 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
AUDIOFILE_BUILDLINK3_MK:=	${AUDIOFILE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	audiofile
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Naudiofile}
BUILDLINK_PACKAGES+=	audiofile
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}audiofile

.if !empty(AUDIOFILE_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.audiofile+=	libaudiofile>=0.2.1
BUILDLINK_ABI_DEPENDS.audiofile+=	libaudiofile>=0.2.6nb1
BUILDLINK_PKGSRCDIR.audiofile?=	../../audio/libaudiofile
.endif	# AUDIOFILE_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
