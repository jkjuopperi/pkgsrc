# $NetBSD: buildlink3.mk,v 1.2 2004/03/05 19:25:36 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
PNETC_BUILDLINK3_MK:=	${PNETC_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pnetC
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NpnetC}
BUILDLINK_PACKAGES+=	pnetC

.if !empty(PNETC_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.pnetC+=	pnetC>=0.6.0
BUILDLINK_PKGSRCDIR.pnetC?=	../../lang/pnetC

.include "../../lang/pnet/buildlink3.mk"

.endif	# PNETC_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
