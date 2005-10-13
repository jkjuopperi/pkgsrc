# $NetBSD: buildlink3.mk,v 1.1.1.1 2005/10/13 15:15:28 wiz Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBMIMEDIR_BUILDLINK3_MK:=	${LIBMIMEDIR_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libmimedir
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibmimedir}
BUILDLINK_PACKAGES+=	libmimedir

.if !empty(LIBMIMEDIR_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libmimedir+=	libmimedir>=0.4
BUILDLINK_PKGSRCDIR.libmimedir?=	../../devel/libmimedir
BUILDLINK_DEPMETHOD.libmimedir?=	build
.endif	# LIBMIMEDIR_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
