# $NetBSD: buildlink3.mk,v 1.7 2010/09/14 11:01:18 wiz Exp $

BUILDLINK_TREE+=	py-at-spi

.if !defined(PY_AT_SPI_BUILDLINK3_MK)
PY_AT_SPI_BUILDLINK3_MK:=

.include "../../lang/python/pyversion.mk"

BUILDLINK_API_DEPENDS.py-at-spi+=	${PYPKGPREFIX}-at-spi>=1.20.1
BUILDLINK_ABI_DEPENDS.py-at-spi?=	${PYPKGPREFIX}-at-spi>=1.30.1nb2
BUILDLINK_PKGSRCDIR.py-at-spi?=		../../devel/py-at-spi

.include "../../devel/at-spi/buildlink3.mk"
.endif # PY_AT_SPI_BUILDLINK3_MK

BUILDLINK_TREE+=	-py-at-spi
