# $NetBSD: buildlink3.mk,v 1.20 2011/07/21 13:06:02 obache Exp $

BUILDLINK_TREE+=	gnome-vfsmm

.if !defined(GNOME_VFSMM_BUILDLINK3_MK)
GNOME_VFSMM_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.gnome-vfsmm+=	gnome-vfsmm>=2.10.0
BUILDLINK_ABI_DEPENDS.gnome-vfsmm+=	gnome-vfsmm>=2.26.0nb6
BUILDLINK_PKGSRCDIR.gnome-vfsmm?=	../../sysutils/gnome-vfsmm

.include "../../devel/glibmm/buildlink3.mk"
.include "../../sysutils/gnome-vfs/buildlink3.mk"
.endif # GNOME_VFSMM_BUILDLINK3_MK

BUILDLINK_TREE+=	-gnome-vfsmm
