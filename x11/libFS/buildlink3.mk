# $NetBSD: buildlink3.mk,v 1.2 2006/11/03 17:24:25 joerg Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBFS_BUILDLINK3_MK:=	${LIBFS_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	libFS
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NlibFS}
BUILDLINK_PACKAGES+=	libFS
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}libFS

.if ${LIBFS_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.libFS+=	libFS>=1.0.0
BUILDLINK_PKGSRCDIR.libFS?=	../../x11/libFS
.endif	# LIBFS_BUILDLINK3_MK

.include "../../x11/fontsproto/buildlink3.mk"
.include "../../x11/xproto/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
