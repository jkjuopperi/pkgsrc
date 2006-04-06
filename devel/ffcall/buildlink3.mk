# $NetBSD: buildlink3.mk,v 1.4 2006/04/06 06:21:48 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
FFCALL_BUILDLINK3_MK:=	${FFCALL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	ffcall
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nffcall}
BUILDLINK_PACKAGES+=	ffcall

.if !empty(FFCALL_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.ffcall+=	ffcall>=1.9
BUILDLINK_ABI_DEPENDS.ffcall+=	ffcall>=1.10nb1
BUILDLINK_PKGSRCDIR.ffcall?=	../../devel/ffcall
.endif	# FFCALL_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
