# $NetBSD: buildlink3.mk,v 1.6 2007/01/31 21:33:31 cbiere Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBMUSEPACK_BUILDLINK3_MK:=	${LIBMUSEPACK_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libmusepack
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibmusepack}
BUILDLINK_PACKAGES+=	libmusepack
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}libmusepack

.if !empty(LIBMUSEPACK_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.libmusepack+=		libmusepack>=1.2.4
BUILDLINK_PKGSRCDIR.libmusepack?=	../../audio/libmusepack
.endif	# LIBMUSEPACK_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
