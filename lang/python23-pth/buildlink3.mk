# $NetBSD: buildlink3.mk,v 1.5 2004/03/05 19:25:37 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
PYTHON23_PTH_BUILDLINK3_MK:=	${PYTHON23_PTH_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	python23-pth
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npython23-pth}
BUILDLINK_PACKAGES+=	python23-pth

.if !empty(PYTHON23_PTH_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.python23-pth+=	python23-pth>=2.3
BUILDLINK_PKGSRCDIR.python23-pth?=	../../lang/python23-pth

.if defined(BUILDLINK_DEPMETHOD.python)
BUILDLINK_DEPMETHOD.python23pth?=	${BUILDLINK_DEPMETHOD.python}
.endif

BUILDLINK_INCDIRS.python23-pth+=	include/python2p3
BUILDLINK_LIBDIRS.python23-pth+=	lib/python2p3/config
BUILDLINK_TRANSFORM+=			l:python:python2p3

.endif	# PYTHON23_PTH_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
