# $NetBSD: buildlink3.mk,v 1.19 2009/08/26 19:56:40 sno Exp $

.include "../../mk/bsd.fast.prefs.mk"

BUILDLINK_TREE+=	mjpegtools

.if !defined(MJPEGTOOLS_BUILDLINK3_MK)
MJPEGTOOLS_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.mjpegtools+=		mjpegtools>=1.8.0
BUILDLINK_ABI_DEPENDS.mjpegtools?=	mjpegtools>=1.9.0nb1
BUILDLINK_PKGSRCDIR.mjpegtools?=	../../multimedia/mjpegtools

.include "../../audio/lame/buildlink3.mk"
.include "../../devel/SDL/buildlink3.mk"
.include "../../graphics/jpeg/buildlink3.mk"

pkgbase := mjpegtools
.include "../../mk/pkg-build-options.mk"

.if !empty(PKG_BUILD_OPTIONS.mjpegtools:Mdv)
.  include "../../multimedia/libdv/buildlink3.mk"
.endif
.endif # MJPEGTOOLS_BUILDLINK3_MK

BUILDLINK_TREE+=	-mjpegtools
