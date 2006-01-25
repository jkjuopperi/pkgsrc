# $NetBSD: buildlink3.mk,v 1.7 2006/01/25 08:09:12 xtraeme Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
MJPEGTOOLS_BUILDLINK3_MK:=	${MJPEGTOOLS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	mjpegtools
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nmjpegtools}
BUILDLINK_PACKAGES+=	mjpegtools

.if !empty(MJPEGTOOLS_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.mjpegtools+=		mjpegtools>=1.6.8
BUILDLINK_PKGSRCDIR.mjpegtools?=	../../multimedia/mjpegtools
.endif	# MJPEGTOOLS_BUILDLINK3_MK

.include "../../audio/lame/buildlink3.mk"
.include "../../devel/SDL/buildlink3.mk"
.include "../../graphics/jpeg/buildlink3.mk"

.if !defined(PKG_BUILD_OPTIONS.mjpegtools)
PKG_BUILD_OPTIONS.mjpegtools!=			\
	cd ${BUILDLINK_PKGSRCDIR.apr} &&	\
	${MAKE} show-var ${MAKEFLAGS} VARNAME=PKG_OPTIONS
MAKEFLAGS+=	PKG_BUILD_OPTIONS.mjpegtools=	\
			${PKG_BUILD_OPTIONS.mjpegtools:Q}
.endif
MAKEVARS+=      PKG_BUILD_OPTIONS.mjpegtools

.if !empty(PKG_BUILD_OPTIONS.mjpegtools:Mdv)
.  include "../../multimedia/libdv/buildlink3.mk"
.endif

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
