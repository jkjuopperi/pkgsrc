# $NetBSD: buildlink3.mk,v 1.1 2004/05/31 17:13:26 minskim Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBSCSI_BUILDLINK3_MK:=	${LIBSCSI_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libscsi
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibscsi}
BUILDLINK_PACKAGES+=	libscsi

.if !empty(LIBSCSI_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libscsi+=	libscsi>=1.6
BUILDLINK_PKGSRCDIR.libscsi?=	../../devel/libscsi
BUILDLINK_DEPMETHOD.libscsi?=	build
.endif	# LIBSCSI_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
