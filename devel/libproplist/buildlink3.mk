# $NetBSD: buildlink3.mk,v 1.3 2004/10/03 00:13:30 tv Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBPROPLIST_BUILDLINK3_MK:=	${LIBPROPLIST_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libproplist
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibproplist}
BUILDLINK_PACKAGES+=	libproplist

.if !empty(LIBPROPLIST_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libproplist+=		libproplist>=0.10.1
BUILDLINK_RECOMMENDED.libproplist+=	libproplist>=0.10.1nb1
BUILDLINK_PKGSRCDIR.libproplist?=	../../devel/libproplist
.endif	# LIBPROPLIST_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
