# $NetBSD: buildlink3.mk,v 1.16 2010/06/13 22:45:50 wiz Exp $

BUILDLINK_TREE+=	pyqt3-mod

.if !defined(PYQT3_MOD_BUILDLINK3_MK)
PYQT3_MOD_BUILDLINK3_MK:=

.include "../../lang/python/pyversion.mk"

BUILDLINK_API_DEPENDS.pyqt3-mod+=	${PYPKGPREFIX}-qt3-modules>=3.11
BUILDLINK_ABI_DEPENDS.pyqt3-mod+=	${PYPKGPREFIX}-qt3-modules>=3.18.1nb5
BUILDLINK_PKGSRCDIR.pyqt3-mod?=	../../x11/py-qt3-modules

BUILDLINK_LIBDIRS.pyqt3-mod+=	${PYSITELIB}

.include "../../x11/py-qt3-base/buildlink3.mk"
.endif # PYQT3_MOD_BUILDLINK3_MK

BUILDLINK_TREE+=	-pyqt3-mod