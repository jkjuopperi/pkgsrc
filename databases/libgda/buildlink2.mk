# $NetBSD: buildlink2.mk,v 1.6 2003/07/13 13:50:57 wiz Exp $
#
# This Makefile fragment is included by packages that use libgda.
#
# This file was created automatically using createbuildlink 2.2.
#

.if !defined(LIBGDA_BUILDLINK2_MK)
LIBGDA_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			libgda
BUILDLINK_DEPENDS.libgda?=		libgda>=0.12.1nb1
BUILDLINK_PKGSRCDIR.libgda?=		../../databases/libgda

EVAL_PREFIX+=	BUILDLINK_PREFIX.libgda=libgda
BUILDLINK_PREFIX.libgda_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.libgda+=	include/libgda-report/*.h
BUILDLINK_FILES.libgda+=	include/libgda/*.h
BUILDLINK_FILES.libgda+=	lib/libgda-2.*
BUILDLINK_FILES.libgda+=	lib/libgda-report-2.*
BUILDLINK_FILES.libgda+=	lib/libgda/providers/libgda-default.*
BUILDLINK_FILES.libgda+=	lib/libgdasql.*
BUILDLINK_FILES.libgda+=	lib/pkgconfig/libgda.pc

.include "../../textproc/libxml2/buildlink2.mk"
.include "../../textproc/libxslt/buildlink2.mk"
.include "../../lang/python22/buildlink2.mk"
.include "../../devel/glib2/buildlink2.mk"
.include "../../devel/popt/buildlink2.mk"

BUILDLINK_TARGETS+=	libgda-buildlink

libgda-buildlink: _BUILDLINK_USE

.endif	# LIBGDA_BUILDLINK2_MK
