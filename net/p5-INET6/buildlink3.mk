# $NetBSD: buildlink3.mk,v 1.1 2004/05/08 07:37:40 snj Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
P5_INET6_BUILDLINK3_MK:=	${P5_INET6_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	p5-INET6
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Np5-INET6}
BUILDLINK_PACKAGES+=	p5-INET6

.if !empty(P5_INET6_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.p5-INET6+=	p5-INET6>=2.00
BUILDLINK_PKGSRCDIR.p5-INET6?=	../../net/p5-INET6
.endif	# P5_INET6_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
