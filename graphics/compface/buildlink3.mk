# $NetBSD: buildlink3.mk,v 1.3 2006/02/05 23:09:28 joerg Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
COMPFACE_BUILDLINK3_MK:=	${COMPFACE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	compface
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ncompface}
BUILDLINK_PACKAGES+=	compface

.if !empty(COMPFACE_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.compface+=	compface>=1.4
BUILDLINK_RECOMMENDED.compface?=	compface>=1.5.1nb1
BUILDLINK_PKGSRCDIR.compface?=	../../graphics/compface
.endif	# COMPFACE_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
