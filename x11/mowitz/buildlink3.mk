# $NetBSD: buildlink3.mk,v 1.6 2006/07/08 22:39:46 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
MOWITZ_BUILDLINK3_MK:=	${MOWITZ_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	Mowitz
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NMowitz}
BUILDLINK_PACKAGES+=	Mowitz
BUILDLINK_ORDER+=	Mowitz

.if !empty(MOWITZ_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.Mowitz+=	Mowitz>=0.2.1
BUILDLINK_ABI_DEPENDS.Mowitz+=	Mowitz>=0.2.2nb2
BUILDLINK_PKGSRCDIR.Mowitz?=	../../x11/mowitz
.endif	# MOWITZ_BUILDLINK3_MK

.include "../../graphics/xpm/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
