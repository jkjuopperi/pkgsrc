# $NetBSD: buildlink3.mk,v 1.22 2011/03/09 16:26:48 drochner Exp $

BUILDLINK_TREE+=	imlib

.if !defined(IMLIB_BUILDLINK3_MK)
IMLIB_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.imlib+=	imlib>=1.9.14nb5
BUILDLINK_ABI_DEPENDS.imlib+=	imlib>=1.9.15nb8
BUILDLINK_PKGSRCDIR.imlib?=	../../graphics/imlib

.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../mk/jpeg.buildlink3.mk"
.include "../../mk/giflib.buildlink3.mk"
.include "../../graphics/netpbm/buildlink3.mk"
.include "../../graphics/png/buildlink3.mk"
.include "../../graphics/tiff/buildlink3.mk"
.include "../../x11/xextproto/buildlink3.mk"
.endif # IMLIB_BUILDLINK3_MK

BUILDLINK_TREE+=	-imlib
