# $NetBSD: buildlink3.mk,v 1.4 2006/04/06 06:21:55 reed Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PTHREAD_SEM_BUILDLINK3_MK:=	${PTHREAD_SEM_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pthread-sem
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npthread-sem}
BUILDLINK_PACKAGES+=	pthread-sem

.if !empty(PTHREAD_SEM_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.pthread-sem+=		pthread-sem>=1.0
BUILDLINK_PKGSRCDIR.pthread-sem?=	../../devel/pthread-sem
.endif	# PTHREAD_SEM_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
