# $NetBSD: buildlink3.mk,v 1.2 2004/01/21 18:22:39 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
NAS_BUILDLINK3_MK:=	${NAS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	nas
.endif

.if !empty(NAS_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=		nas
BUILDLINK_DEPENDS.nas?=		nas>=1.4.2
BUILDLINK_PKGSRCDIR.nas?=	../../audio/nas
.endif	# NAS_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
