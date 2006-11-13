# $NetBSD: buildlink3.mk,v 1.1.1.1 2006/11/13 15:55:55 wulf Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PY_EPHEM_BUILDLINK3_MK:=	${PY_EPHEM_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	py-ephem
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npy-ephem}
BUILDLINK_PACKAGES+=	py-ephem
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}py-ephem

.if ${PY_EPHEM_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.py-ephem+=	${PYPKGPREFIX}-ephem>=3.7b
BUILDLINK_PKGSRCDIR.py-ephem?=	../../math/py-ephem
.endif	# PY_EPHEM_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
