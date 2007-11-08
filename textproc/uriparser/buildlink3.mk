# $NetBSD: buildlink3.mk,v 1.1.1.1 2007/11/08 18:36:14 bjs Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
URIPARSER_BUILDLINK3_MK:=	${URIPARSER_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	uriparser
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nuriparser}
BUILDLINK_PACKAGES+=	uriparser
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}uriparser

.if ${URIPARSER_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.uriparser+=	uriparser>=0.6.0
BUILDLINK_PKGSRCDIR.uriparser?=	../../textproc/uriparser
.endif	# URIPARSER_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
