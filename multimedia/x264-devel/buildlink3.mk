# $NetBSD: buildlink3.mk,v 1.3 2006/04/12 10:27:28 rillig Exp $

BUILDLINK_DEPMETHOD.x264-devel?=	build
BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
X264_DEVEL_BUILDLINK3_MK:=	${X264_DEVEL_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	x264-devel
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nx264-devel}
BUILDLINK_PACKAGES+=	x264-devel

.if !empty(X264_DEVEL_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.x264-devel+=	x264-devel>=20060127
BUILDLINK_PKGSRCDIR.x264-devel?=	../../multimedia/x264-devel
.endif	# X264_DEVEL_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
