# $NetBSD: buildlink3.mk,v 1.2 2006/07/08 22:39:20 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PY_MATPLOTLIB_BUILDLINK3_MK:=	${PY_MATPLOTLIB_BUILDLINK3_MK}+

.include "../../lang/python/pyversion.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pymatplotlib
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npymatplotlib}
BUILDLINK_PACKAGES+=	pymatplotlib
BUILDLINK_ORDER+=	pymatplotlib

.if !empty(PY_MATPLOTLIB_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.pymatplotlib+=	${PYPKGPREFIX}-matplotlib>=0.87.2
BUILDLINK_PKGSRCDIR.pymatplotlib?=	../../graphics/py-matplotlib
.endif	# PY_MATPLOTLIB_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
