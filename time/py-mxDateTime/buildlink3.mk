# $NetBSD: buildlink3.mk,v 1.4 2004/03/06 23:46:06 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PY_MXDATETIME_BUILDLINK3_MK:=	${PY_MXDATETIME_BUILDLINK3_MK}+

.include "../../lang/python/pyversion.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	py-mxDateTime
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npy-mxDateTime}
BUILDLINK_PACKAGES+=	py-mxDateTime

.if !empty(PY_MXDATETIME_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.py-mxDateTime+=	${PYPKGPREFIX}-mxDateTime>=2.0.5
BUILDLINK_PKGSRCDIR.py-mxDateTime?=	../../time/py-mxDateTime

BUILDLINK_INCDIRS.py-mxDateTime+=	${PYSITELIB}/mx/DateTime/mxDateTime

.endif	# PY_MXDATETIME_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
