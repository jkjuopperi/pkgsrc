# $NetBSD: buildlink3.mk,v 1.2 2005/01/28 22:28:44 hira Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PYTHON23_NTH_BUILDLINK3_MK:=	${PYTHON23_NTH_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	python23-nth
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npython23-nth}
BUILDLINK_PACKAGES+=	python23-nth

.if !empty(PYTHON23_NTH_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.python23-nth+=	python23-nth>=2.3.4
BUILDLINK_PKGSRCDIR.python23-nth?=	../../lang/python23-nth

.if defined(BUILDLINK_DEPMETHOD.python)
BUILDLINK_DEPMETHOD.python23nth?=	${BUILDLINK_DEPMETHOD.python}
.endif

BUILDLINK_INCDIRS.python23-nth+=	include/python2n3
BUILDLINK_LIBDIRS.python23-nth+=	lib/python2n3/config
BUILDLINK_TRANSFORM+=			l:python:python2n3

.endif	# PYTHON23_NTH_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
