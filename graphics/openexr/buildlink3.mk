# $NetBSD: buildlink3.mk,v 1.8 2006/10/29 13:51:18 dsainty Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
OPENEXR_BUILDLINK3_MK:=	${OPENEXR_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	openexr
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nopenexr}
BUILDLINK_PACKAGES+=	openexr
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}openexr

.if !empty(OPENEXR_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.openexr+=	openexr>=1.2.1
BUILDLINK_ABI_DEPENDS.openexr+=	openexr>=1.2.2nb1
BUILDLINK_PKGSRCDIR.openexr?=	../../graphics/openexr

PTHREAD_OPTS+=	require
.endif	# OPENEXR_BUILDLINK3_MK

.include "../../mk/pthread.buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
