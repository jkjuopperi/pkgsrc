# $NetBSD: buildlink3.mk,v 1.2 2004/03/05 19:25:11 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
ODE_BUILDLINK3_MK:=	${ODE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	ode
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Node}
BUILDLINK_PACKAGES+=	ode

.if !empty(ODE_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.ode+=		ode>=0.039
BUILDLINK_PKGSRCDIR.ode?=	../../devel/ode
.endif	# ODE_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
