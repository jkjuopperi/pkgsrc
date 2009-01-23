# $NetBSD: buildlink3.mk,v 1.1.1.1 2009/01/23 14:54:23 jmcneill Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GPAC_BUILDLINK3_MK:=	${GPAC_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	gpac
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngpac}
BUILDLINK_PACKAGES+=	gpac
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}gpac

.if ${GPAC_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.gpac+=	gpac>=0.4.5
BUILDLINK_PKGSRCDIR.gpac?=	../../multimedia/gpac
.endif	# GPAC_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
