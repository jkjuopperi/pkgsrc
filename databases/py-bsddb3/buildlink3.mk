# $NetBSD: buildlink3.mk,v 1.2 2005/01/24 16:58:13 seb Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PY_BSDDB3_BUILDLINK3_MK:=	${PY_BSDDB3_BUILDLINK3_MK}+

.include "../../mk/pthread.buildlink3.mk"
.if defined(PTHREAD_TYPE) && ${PTHREAD_TYPE} == "native"
PYTHON_VERSIONS_ACCEPTED=	24 23 22
.endif
.include "../../lang/python/pyversion.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	py-bsddb3
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npy-bsddb3}
BUILDLINK_PACKAGES+=	py-bsddb3

.if !empty(PY_BSDDB3_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.py-bsddb3+=	${PYPKGPREFIX}-bsddb3>=4.2.4nb1
BUILDLINK_PKGSRCDIR.py-bsddb3?=	../../databases/py-bsddb3
.endif	# PY_BSDDB3_BUILDLINK3_MK

.include "../../databases/db4/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
