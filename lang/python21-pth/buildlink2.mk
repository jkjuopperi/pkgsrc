# $NetBSD: buildlink2.mk,v 1.6 2002/10/12 09:00:35 jlam Exp $

.if !defined(PYTHON21_BUILDLINK2_MK)
PYTHON21_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.prefs.mk"

BUILDLINK_PACKAGES+=			python21-pth
BUILDLINK_PKGBASE.python21-pth?=	python21-pth
BUILDLINK_DEPENDS.python21-pth?=	python21-pth>=2.1
BUILDLINK_PKGSRCDIR.python21-pth?=	../../lang/python21-pth

.if defined(BUILDLINK_DEPMETHOD.python)
BUILDLINK_DEPMETHOD.python21-pth?=	${BUILDLINK_DEPMETHOD.python}
.endif

EVAL_PREFIX+=	BUILDLINK_PREFIX.python21-pth=python21-pth
BUILDLINK_PREFIX.python21-pth_DEFAULT=	${LOCALBASE}
_PY21_PTH_BLNK_FILES= \
	${BUILDLINK_PLIST_CMD.python21-pth} |				\
		${GREP} '^\(include\|lib.*/lib[^/]*$$\)'
BUILDLINK_FILES.python21-pth=	`${_PY21_PTH_BLNK_FILES}`
BUILDLINK_TRANSFORM+=		l:python:python2p1

BUILDLINK_CPPFLAGS.python21-pth+= \
	-I${BUILDLINK_PREFIX.python21-pth}/include/python2p1
BUILDLINK_LDFLAGS.python21-pth+= \
	-L${BUILDLINK_PREFIX.python21-pth}/lib/python2p1/config		\
	-Wl,-R${BUILDLINK_PREFIX.python21-pth}/lib/python2p1/config

BUILDLINK_TARGETS+=	python21-pth-buildlink

python21-pth-buildlink: _BUILDLINK_USE

.endif	# PYTHON21_BUILDLINK2_MK
