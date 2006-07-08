# $NetBSD: buildlink3.mk,v 1.7 2006/07/08 22:39:37 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBPRELUDE_BUILDLINK3_MK:=	${LIBPRELUDE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libprelude
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibprelude}
BUILDLINK_PACKAGES+=	libprelude
BUILDLINK_ORDER+=	libprelude

.if !empty(LIBPRELUDE_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.libprelude+=	libprelude>=0.9.0
BUILDLINK_ABI_DEPENDS.libprelude?=	libprelude>=0.9.7
BUILDLINK_PKGSRCDIR.libprelude?=	../../security/libprelude
.endif	# LIBPRELUDE_BUILDLINK3_MK

.include "../../security/gnutls/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
