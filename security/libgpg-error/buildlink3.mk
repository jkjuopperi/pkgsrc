# $NetBSD: buildlink3.mk,v 1.6 2004/10/15 18:21:56 minskim Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBGPG_ERROR_BUILDLINK3_MK:=	${LIBGPG_ERROR_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libgpg-error
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibgpg-error}
BUILDLINK_PACKAGES+=	libgpg-error

.if !empty(LIBGPG_ERROR_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libgpg-error+=	libgpg-error>=0.6
BUILDLINK_RECOMMENDED.libgpg-error+=	libgpg-error>=0.6nb2
BUILDLINK_PKGSRCDIR.libgpg-error?=	../../security/libgpg-error
.endif	# LIBGPG_ERROR_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
