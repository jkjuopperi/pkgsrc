# $NetBSD: buildlink3.mk,v 1.1 2004/04/11 17:43:31 xtraeme Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
OPENAL_BUILDLINK3_MK:=	${OPENAL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	openal
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nopenal}
BUILDLINK_PACKAGES+=	openal

.if !empty(OPENAL_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.openal+=	openal>=20030125nb1
BUILDLINK_PKGSRCDIR.openal?=	../../audio/openal
.endif	# OPENAL_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
