# $NetBSD: buildlink3.mk,v 1.18 2010/03/12 09:23:41 obache Exp $

BUILDLINK_TREE+=	fltk

.if !defined(FLTK_BUILDLINK3_MK)
FLTK_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.fltk+=	fltk>=1.1.5rc1
BUILDLINK_ABI_DEPENDS.fltk+=	fltk>=1.1.7nb1
BUILDLINK_PKGSRCDIR.fltk?=	../../x11/fltk
BUILDLINK_FILES.fltk+=		include/Fl/*

.include "../../graphics/MesaLib/buildlink3.mk"
.include "../../graphics/glu/buildlink3.mk"
.include "../../graphics/jpeg/buildlink3.mk"
.include "../../graphics/png/buildlink3.mk"
.include "../../mk/pthread.buildlink3.mk"
.include "../../x11/libXext/buildlink3.mk"
.endif # FLTK_BUILDLINK3_MK

BUILDLINK_TREE+=	-fltk
