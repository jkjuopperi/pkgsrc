# $NetBSD: buildlink3.mk,v 1.2 2004/10/03 00:13:03 tv Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
MPEG_BUILDLINK3_MK:=	${MPEG_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	mpeg
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nmpeg}
BUILDLINK_PACKAGES+=	mpeg

.if !empty(MPEG_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.mpeg+=	mpeg>=1.3.1
BUILDLINK_RECOMMENDED.mpeg+=	mpeg>=1.3.1nb1
BUILDLINK_PKGSRCDIR.mpeg?=	../../multimedia/mpeg-lib
.endif	# MPEG_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
