# $NetBSD: buildlink3.mk,v 1.10 2008/06/08 13:01:48 obache Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
UIM_BUILDLINK3_MK:=	${UIM_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	uim
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nuim}
BUILDLINK_PACKAGES+=	uim
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}uim

.if !empty(UIM_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.uim+=	uim>=1.5.1
BUILDLINK_ABI_DEPENDS.uim?=	uim>=1.5.1
BUILDLINK_PKGSRCDIR.uim?=	../../inputmethod/uim
.endif  # UIM_BUILDLINK3_MK

.include "../../devel/libgcroots/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
