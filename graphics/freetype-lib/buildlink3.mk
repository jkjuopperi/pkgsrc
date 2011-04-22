# $NetBSD: buildlink3.mk,v 1.16 2011/04/22 13:42:06 obache Exp $

BUILDLINK_TREE+=	freetype

.if !defined(FREETYPE_BUILDLINK3_MK)
FREETYPE_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.freetype+=	freetype-lib>=1.3.1nb1
BUILDLINK_ABI_DEPENDS.freetype+=freetype-lib>=1.3.1nb2
BUILDLINK_ABI_DEPENDS.freetype?=	freetype-lib>=1.5nb1
BUILDLINK_PKGSRCDIR.freetype?=	../../graphics/freetype-lib

.include "../../devel/gettext-lib/buildlink3.mk"
.endif # FREETYPE_BUILDLINK3_MK

BUILDLINK_TREE+=	-freetype
