# $NetBSD: buildlink2.mk,v 1.3 2003/03/31 17:44:21 jmmv Exp $

.if !defined(WXGTK_BUILDLINK2_MK)
WXGTK_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		wxGTK
BUILDLINK_DEPENDS.wxGTK?=	wxGTK>=2.4.0
BUILDLINK_PKGSRCDIR.wxGTK?=	../../x11/wxGTK

EVAL_PREFIX+=			BUILDLINK_PREFIX.wxGTK=wxGTK
BUILDLINK_PREFIX.wxGTK_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.wxGTK=		include/wx/*
BUILDLINK_FILES.wxGTK+=		include/wx/*/*
BUILDLINK_FILES.wxGTK+=		lib/wx/include/wx/gtk/*
BUILDLINK_FILES.wxGTK+=		lib/libwx_gtk.*

.include "../../graphics/jpeg/buildlink2.mk"
.include "../../graphics/png/buildlink2.mk"
.include "../../graphics/tiff/buildlink2.mk"
.include "../../x11/gtk/buildlink2.mk"

BUILDLINK_TARGETS+=	wxGTK-buildlink

wxGTK-buildlink: _BUILDLINK_USE

.endif	# WXGTK_BUILDLINK2_MK
