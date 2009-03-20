# $NetBSD: buildlink3.mk,v 1.14 2009/03/20 17:30:11 joerg Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PY_NUMERIC_BUILDLINK3_MK:=	${PY_NUMERIC_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pynumeric
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npynumeric}
BUILDLINK_PACKAGES+=	pynumeric
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}pynumeric

.if !empty(PY_NUMERIC_BUILDLINK3_MK:M+)
.  include "../../lang/python/pyversion.mk"

BUILDLINK_API_DEPENDS.pynumeric+=	${PYPKGPREFIX}-Numeric-[0-9]*
BUILDLINK_ABI_DEPENDS.pynumeric+=	${PYPKGPREFIX}-Numeric>=23.7nb1
BUILDLINK_PKGSRCDIR.pynumeric?=	../../math/py-Numeric
.endif	# PY_NUMERIC_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
