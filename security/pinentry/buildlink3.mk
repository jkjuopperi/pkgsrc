# $NetBSD: buildlink3.mk,v 1.3 2006/04/06 06:22:44 reed Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PINENTRY_BUILDLINK3_MK:=	${PINENTRY_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pinentry
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npinentry}
BUILDLINK_PACKAGES+=	pinentry

.if !empty(PINENTRY_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.pinentry+=	pinentry>=0.7.1
BUILDLINK_ABI_DEPENDS.pinentry?=	pinentry>=0.7.1nb3
BUILDLINK_PKGSRCDIR.pinentry?=	../../security/pinentry
.endif	# PINENTRY_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
