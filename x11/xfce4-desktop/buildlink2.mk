# $NetBSD: buildlink2.mk,v 1.8 2004/03/10 07:41:16 martti Exp $
#
# This Makefile fragment is included by packages that use xfce4-desktop.
#
# This file was created automatically using createbuildlink 2.7.
#

.if !defined(XFCE4_DESKTOP_BUILDLINK2_MK)
XFCE4_DESKTOP_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			xfce4-desktop
BUILDLINK_DEPENDS.xfce4-desktop?=		xfce4-desktop>=4.0.4
BUILDLINK_PKGSRCDIR.xfce4-desktop?=		../../x11/xfce4-desktop

EVAL_PREFIX+=	BUILDLINK_PREFIX.xfce4-desktop=xfce4-desktop
BUILDLINK_PREFIX.xfce4-desktop_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.xfce4-desktop+=	lib/xfce4/mcs-plugins/backdrop_settings.*
BUILDLINK_FILES.xfce4-desktop+=	lib/xfce4/mcs-plugins/workspaces_settings.*

.include "../../textproc/libxml2/buildlink2.mk"
.include "../../x11/xfce4-mcs-plugins/buildlink2.mk"
.include "../../x11/startup-notification/buildlink2.mk"
.include "../../devel/glib2/buildlink2.mk"

BUILDLINK_TARGETS+=	xfce4-desktop-buildlink

xfce4-desktop-buildlink: _BUILDLINK_USE

.endif	# XFCE4_DESKTOP_BUILDLINK2_MK
