# $NetBSD: buildlink3.mk,v 1.1 2005/08/03 13:40:38 adam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
QALCULATE_BUILDLINK3_MK:=	${QALCULATE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	qalculate
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nqalculate}
BUILDLINK_PACKAGES+=	qalculate

.if !empty(QALCULATE_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.qalculate+=	qalculate>=0.8.1.1
BUILDLINK_PKGSRCDIR.qalculate?=	../../adam/qalculate
.endif	# QALCULATE_BUILDLINK3_MK

.include "../../devel/glib2/buildlink3.mk"
.include "../../math/cln/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
