# $NetBSD: buildlink3.mk,v 1.7 2011/01/13 13:36:31 wiz Exp $

BUILDLINK_TREE+=	gnome-mount

.if !defined(GNOME_MOUNT_BUILDLINK3_MK)
GNOME_MOUNT_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.gnome-mount+=	gnome-mount>=0.8nb1
BUILDLINK_ABI_DEPENDS.gnome-mount?=	gnome-mount>=0.8nb7
BUILDLINK_PKGSRCDIR.gnome-mount?=	../../sysutils/gnome-mount

#.include "../../security/gnome-keyring/buildlink3.mk"
#.include "../../sysutils/dbus-glib/buildlink3.mk"
#.include "../../sysutils/hal/buildlink3.mk"
#.include "../../sysutils/libnotify/buildlink3.mk"
#.include "../../sysutils/nautilus/buildlink3.mk"
#.include "../../x11/gtk2/buildlink3.mk"
.endif # GNOME_MOUNT_BUILDLINK3_MK

BUILDLINK_TREE+=	-gnome-mount
