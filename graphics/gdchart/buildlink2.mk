# $NetBSD: buildlink2.mk,v 1.6 2003/06/24 08:20:59 wiz Exp $
#

.if !defined(GDCHART_BUILDLINK2_MK)
GDCHART_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			gdchart
BUILDLINK_DEPENDS.gdchart?=		gdchart>=0.11.4nb1
BUILDLINK_PKGSRCDIR.gdchart?=		../../graphics/gdchart

EVAL_PREFIX+=	BUILDLINK_PREFIX.gdchart=gdchart
BUILDLINK_PREFIX.gdchart_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.gdchart+=	include/gdchart.h
BUILDLINK_FILES.gdchart+=	include/gdc.h
BUILDLINK_FILES.gdchart+=	include/gdcpie.h
BUILDLINK_FILES.gdchart+=	include/gifencode.h
BUILDLINK_FILES.gdchart+=	lib/libgdchart.*

.include "../../graphics/gd/buildlink2.mk"

BUILDLINK_TARGETS+=	gdchart-buildlink

gdchart-buildlink: _BUILDLINK_USE

.endif	# GDCHART_BUILDLINK2_MK
