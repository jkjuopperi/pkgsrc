# $NetBSD: buildlink2.mk,v 1.2 2002/08/25 19:22:29 jlam Exp $

.if !defined(HDF_BUILDLINK2_MK)
HDF_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		hdf
BUILDLINK_DEPENDS.hdf?=		hdf>=4.1r5
BUILDLINK_PKGSRCDIR.hdf?=	../../devel/hdf

EVAL_PREFIX+=			BUILDLINK_PREFIX.hdf=hdf
BUILDLINK_PREFIX.hdf_DEFAULT=	${LOCALBASE}

BUILDLINK_FILES.hdf=	include/hdf/*
BUILDLINK_FILES.hdf+=	lib/libdf.*
BUILDLINK_FILES.hdf+=	lib/libmfhdf.*

BUILDLINK_TARGETS+=	hdf-buildlink

hdf-buildlink: _BUILDLINK_USE

.endif	# HDF_BUILDLINK2_MK
