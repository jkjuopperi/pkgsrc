# $NetBSD: buildlink3.mk,v 1.1.1.1 2008/04/12 10:56:18 wiz Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
EXEMPI_BUILDLINK3_MK:=	${EXEMPI_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	exempi
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nexempi}
BUILDLINK_PACKAGES+=	exempi
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}exempi

.if ${EXEMPI_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.exempi+=	exempi>=1.99.9
BUILDLINK_PKGSRCDIR.exempi?=	../../devel/exempi
.endif	# EXEMPI_BUILDLINK3_MK

.include "../../textproc/expat/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
