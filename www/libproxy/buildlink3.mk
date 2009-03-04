# $NetBSD: buildlink3.mk,v 1.1.1.1 2009/03/04 02:11:07 jmcneill Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBPROXY_BUILDLINK3_MK:=	${LIBPROXY_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	libproxy
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibproxy}
BUILDLINK_PACKAGES+=	libproxy
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}libproxy

.if ${LIBPROXY_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.libproxy+=	libproxy>=0.2.3
BUILDLINK_PKGSRCDIR.libproxy?=	../../www/libproxy
.endif	# LIBPROXY_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
