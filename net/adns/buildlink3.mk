# $NetBSD: buildlink3.mk,v 1.2 2004/10/03 00:17:49 tv Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
ADNS_BUILDLINK3_MK:=	${ADNS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	adns
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nadns}
BUILDLINK_PACKAGES+=	adns

.if !empty(ADNS_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.adns+=	adns>=1.0
BUILDLINK_RECOMMENDED.adns+=	adns>=1.1nb1
BUILDLINK_PKGSRCDIR.adns?=	../../net/adns
.endif	# ADNS_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
