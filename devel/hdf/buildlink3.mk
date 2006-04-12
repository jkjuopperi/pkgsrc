# $NetBSD: buildlink3.mk,v 1.4 2006/04/12 10:27:09 rillig Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
HDF_BUILDLINK3_MK:=	${HDF_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	hdf
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nhdf}
BUILDLINK_PACKAGES+=	hdf

.if !empty(HDF_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.hdf+=	hdf>=4.1r5
BUILDLINK_ABI_DEPENDS.hdf?=	hdf>=4.2r1nb1
BUILDLINK_PKGSRCDIR.hdf?=	../../devel/hdf
.endif	# HDF_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
