# $NetBSD: buildlink3.mk,v 1.6 2006/07/08 22:39:29 jlam Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
PY_NUMARRAY_BUILDLINK3_MK:=	${PY_NUMARRAY_BUILDLINK3_MK}+

.include "../../lang/python/pyversion.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pynumarray
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npynumarray}
BUILDLINK_PACKAGES+=	pynumarray
BUILDLINK_ORDER+=	pynumarray

.if !empty(PY_NUMARRAY_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.pynumarray+=	${PYPKGPREFIX}-numarray>=1.1.1
BUILDLINK_ABI_DEPENDS.pynumarray?=	${PYPKGPREFIX}-numarray>=1.3.3nb1
BUILDLINK_PKGSRCDIR.pynumarray?=	../../math/py-numarray
.endif	# PY_NUMARRAY_BUILDLINK3_MK

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH:S/+$//}
