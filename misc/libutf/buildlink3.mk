# $NetBSD: buildlink3.mk,v 1.2 2004/10/03 00:13:00 tv Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBUTF_BUILDLINK3_MK:=	${LIBUTF_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libutf
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibutf}
BUILDLINK_PACKAGES+=	libutf

.if !empty(LIBUTF_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libutf+=	libutf>=2.10nb1
BUILDLINK_RECOMMENDED.libutf+=	libutf>=2.10nb2
BUILDLINK_PKGSRCDIR.libutf?=	../../misc/libutf
.endif	# LIBUTF_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
