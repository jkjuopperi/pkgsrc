# $NetBSD: buildlink3.mk,v 1.4 2006/02/05 23:10:01 joerg Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
CLN_BUILDLINK3_MK:=	${CLN_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	cln
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ncln}
BUILDLINK_PACKAGES+=	cln

.if !empty(CLN_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.cln+=		cln>=1.1.6
BUILDLINK_RECOMMENDED.cln+=	cln>=1.1.9nb1
BUILDLINK_PKGSRCDIR.cln?=	../../math/cln
.endif	# CLN_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
