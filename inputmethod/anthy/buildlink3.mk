# $NetBSD: buildlink3.mk,v 1.3 2006/04/06 06:22:06 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
ANTHY_BUILDLINK3_MK:=	${ANTHY_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	anthy
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nanthy}
BUILDLINK_PACKAGES+=	anthy

.if !empty(ANTHY_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.anthy+=	anthy>=6300
BUILDLINK_ABI_DEPENDS.anthy?=	anthy>=7100bnb1
BUILDLINK_PKGSRCDIR.anthy?=	../../inputmethod/anthy
.endif  # ANTHY_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
