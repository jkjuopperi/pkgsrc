# $NetBSD: buildlink3.mk,v 1.2 2009/03/20 19:25:30 joerg Exp $
#

BUILDLINK_TREE+=	json-glib

.if !defined(JSON_GLIB_BUILDLINK3_MK)
JSON_GLIB_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.json-glib+=	json-glib>=0.6.2
BUILDLINK_PKGSRCDIR.json-glib?=		../../textproc/json-glib

.include "../../devel/glib2/buildlink3.mk"
.endif # JSON_GLIB_BUILDLINK3_MK

BUILDLINK_TREE+=	-json-glib
