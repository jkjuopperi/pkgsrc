# $NetBSD: buildlink3.mk,v 1.8 2006/04/12 10:27:02 rillig Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
TAGLIB_BUILDLINK3_MK:=	${TAGLIB_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	taglib
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ntaglib}
BUILDLINK_PACKAGES+=	taglib

.if !empty(TAGLIB_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.taglib+=	taglib>=1.0
BUILDLINK_ABI_DEPENDS.taglib+=	taglib>=1.3
BUILDLINK_PKGSRCDIR.taglib?=	../../audio/taglib
.endif	# TAGLIB_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
