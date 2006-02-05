# $NetBSD: buildlink3.mk,v 1.3 2006/02/05 23:10:54 joerg Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
GST_PLUGINS0.8_GNOMEVFS_BUILDLINK3_MK:=	${GST_PLUGINS0.8_GNOMEVFS_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gst-plugins0.8-gnomevfs
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngst-plugins0.8-gnomevfs}
BUILDLINK_PACKAGES+=	gst-plugins0.8-gnomevfs

.if !empty(GST_PLUGINS0.8_GNOMEVFS_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.gst-plugins0.8-gnomevfs+=	gst-plugins0.8-gnomevfs>=0.8.11
BUILDLINK_RECOMMENDED.gst-plugins0.8-gnomevfs?=	gst-plugins0.8-gnomevfs>=0.8.11nb2
BUILDLINK_PKGSRCDIR.gst-plugins0.8-gnomevfs?=	../../sysutils/gst-plugins0.8-gnomevfs
.endif	# GST_PLUGINS0.8_GNOMEVFS_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
