# $NetBSD: buildlink2.mk,v 1.2 2002/09/22 09:52:35 jlam Exp $

.if !defined(LIBGNOME_BUILDLINK2_MK)
LIBGNOME_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		libgnome
BUILDLINK_DEPENDS.libgnome?=	libgnome>=2.0.4
BUILDLINK_PKGSRCDIR.libgnome?=	../../devel/libgnome

EVAL_PREFIX+=			BUILDLINK_PREFIX.libgnome=libgnome
BUILDLINK_PREFIX.libgnome_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.libgnome=	include/libgnome-2.0/libgnome/*
BUILDLINK_FILES.libgnome+=	lib/libgnome-2.*

.include "../../archivers/bzip2/buildlink2.mk"
.include "../../audio/esound/buildlink2.mk"
.include "../../devel/gettext-lib/buildlink2.mk"
.include "../../devel/glib2/buildlink2.mk"
.include "../../devel/GConf2/buildlink2.mk"
.include "../../devel/libbonobo/buildlink2.mk"
.include "../../devel/zlib/buildlink2.mk"
.include "../../sysutils/gnome-vfs2/buildlink2.mk"
.include "../../textproc/libxml2/buildlink2.mk"
.include "../../textproc/libxslt/buildlink2.mk"

BUILDLINK_TARGETS+=	libgnome-buildlink

libgnome-buildlink: _BUILDLINK_USE

.endif	# LIBGNOME_BUILDLINK2_MK
