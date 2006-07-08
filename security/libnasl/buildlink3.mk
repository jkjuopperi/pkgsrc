# $NetBSD: buildlink3.mk,v 1.9 2006/07/08 22:39:37 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBNASL_BUILDLINK3_MK:=	${LIBNASL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libnasl
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibnasl}
BUILDLINK_PACKAGES+=	libnasl
BUILDLINK_ORDER+=	libnasl

.if !empty(LIBNASL_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.libnasl+=	libnasl>=2.2.7
BUILDLINK_ABI_DEPENDS.libnasl?=	libnasl>=2.2.7
BUILDLINK_PKGSRCDIR.libnasl?=	../../security/libnasl
.endif	# LIBNASL_BUILDLINK3_MK

.include "../../security/nessus-libraries/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
