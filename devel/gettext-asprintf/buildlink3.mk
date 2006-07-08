# $NetBSD: buildlink3.mk,v 1.3 2006/07/08 22:39:08 jlam Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
GETTEXT_ASPRINTF_BUILDLINK3_MK:=	${GETTEXT_ASPRINTF_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gettext-asprintf
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngettext-asprintf}
BUILDLINK_PACKAGES+=	gettext-asprintf
BUILDLINK_ORDER+=	gettext-asprintf

.if !empty(GETTEXT_ASPRINTF_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.gettext-asprintf+=	gettext-asprintf>=0.14.5
BUILDLINK_PKGSRCDIR.gettext-asprintf?=	../../devel/gettext-asprintf
.endif	# GETTEXT_ASPRINTF_BUILDLINK3_MK

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH:S/+$//}
