# $NetBSD: buildlink3.mk,v 1.1.1.1 2011/02/06 08:32:06 jnemeth Exp $

BUILDLINK_TREE+=	spandsp

.if !defined(SPANDSP_BUILDLINK3_MK)
SPANDSP_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.spandsp+=	spandsp>=0.0.6pre18
BUILDLINK_PKGSRCDIR.spandsp?=	../../comms/spandsp

.include "../../graphics/tiff/buildlink3.mk"
.endif	# SPANDSP_BUILDLINK3_MK

BUILDLINK_TREE+=	-spandsp
