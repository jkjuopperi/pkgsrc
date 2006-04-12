# $NetBSD: buildlink3.mk,v 1.4 2006/04/12 10:27:30 rillig Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
NETBSD_TAP_BUILDLINK3_MK:=	${NETBSD_TAP_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	netbsd-tap
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nnetbsd-tap}
BUILDLINK_PACKAGES+=	netbsd-tap

.if !empty(NETBSD_TAP_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.netbsd-tap+=	netbsd-tap>=20050120
BUILDLINK_PKGSRCDIR.netbsd-tap?=	../../net/netbsd-tap
.endif	# NETBSD_TAP_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
