# $NetBSD: buildlink2.mk,v 1.8 2004/03/10 07:41:16 martti Exp $
#
# This Makefile fragment is included by packages that use xfce4.
#
# This file was created automatically using createbuildlink-3.0.
#

.if !defined(XFCE4_BUILDLINK2_MK)
XFCE4_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			xfce4
BUILDLINK_DEPENDS.xfce4?=		xfce4>=4.0.4
BUILDLINK_PKGSRCDIR.xfce4?=		../../meta-pkgs/xfce4

EVAL_PREFIX+=	BUILDLINK_PREFIX.xfce4=xfce4
BUILDLINK_PREFIX.xfce4_DEFAULT=	${X11PREFIX}

.include "../../graphics/xfce4-iconbox/buildlink2.mk"
.include "../../print/xfce4-print/buildlink2.mk"
.include "../../sysutils/xfce4-fm/buildlink2.mk"
.include "../../wm/xfce4-wm/buildlink2.mk"
.include "../../x11/xfce4-desktop/buildlink2.mk"
.include "../../x11/xfce4-gtk2-engines/buildlink2.mk"
.include "../../x11/xfce4-utils/buildlink2.mk"
.include "../../x11/xfce4-panel/buildlink2.mk"
.include "../../audio/xfce4-mixer/buildlink2.mk"
.include "../../sysutils/xfce4-fm-icons/buildlink2.mk"
.include "../../sysutils/xfce4-systray/buildlink2.mk"
.include "../../wm/xfce4-wm-themes/buildlink2.mk"
.include "../../x11/xfce4-themes/buildlink2.mk"
.include "../../x11/xfce4-toys/buildlink2.mk"
.include "../../x11/xfce4-trigger-launcher/buildlink2.mk"
.include "../../devel/glib2/buildlink2.mk"

BUILDLINK_TARGETS+=	xfce4-buildlink

xfce4-buildlink: _BUILDLINK_USE

.endif	# XFCE4_BUILDLINK2_MK
