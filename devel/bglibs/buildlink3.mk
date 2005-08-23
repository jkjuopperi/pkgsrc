# $NetBSD: buildlink3.mk,v 1.4 2005/08/23 19:33:52 schmonz Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
BGLIBS_BUILDLINK3_MK:=	${BGLIBS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	bglibs
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nbglibs}
BUILDLINK_PACKAGES+=	bglibs

.if !empty(BGLIBS_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.bglibs+=	bglibs>=1.027
BUILDLINK_PKGSRCDIR.bglibs?=	../../devel/bglibs
BUILDLINK_DEPMETHOD.bglibs?=	build
.endif	# BGLIBS_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
