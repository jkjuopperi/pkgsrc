# $NetBSD: buildlink3.mk,v 1.1 2004/05/08 05:25:12 snj Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
P5_NET_GOOGLE_BUILDLINK3_MK:=	${P5_NET_GOOGLE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	p5-Net-Google
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Np5-Net-Google}
BUILDLINK_PACKAGES+=	p5-Net-Google

.if !empty(P5_NET_GOOGLE_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.p5-Net-Google+=	p5-Net-Google>=0.61
BUILDLINK_PKGSRCDIR.p5-Net-Google?=	../../net/p5-Net-Google
.endif	# P5_NET_GOOGLE_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
