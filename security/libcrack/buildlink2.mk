# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/05/11 02:09:23 jlam Exp $
#
# This Makefile fragment is included by packages that use libcrack.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.libcrack to the dependency pattern
#     for the version of libcrack desired.
# (2) Include this Makefile fragment in the package Makefile.

.if !defined(LIBCRACK_BUILDLINK2_MK)
LIBCRACK_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.buildlink2.mk"

BUILDLINK_DEPENDS.libcrack?=	libcrack>=2.7
DEPENDS+=	${BUILDLINK_DEPENDS.libcrack}:../../security/libcrack

BUILDLINK_PREFIX.libcrack=	${LOCALBASE}
BUILDLINK_FILES.libcrack=	include/cracklib/*
BUILDLINK_FILES.libcrack+=	lib/libcrack.*

BUILDLINK_TARGETS+=	libcrack-buildlink

libcrack-buildlink: _BUILDLINK_USE

.endif	# LIBCRACK_BUILDLINK2_MK
