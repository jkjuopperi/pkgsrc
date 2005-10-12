# $NetBSD: buildlink3.mk,v 1.2 2005/10/12 21:22:08 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GDOME2_BUILDLINK3_MK:=	${GDOME2_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gdome2
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngdome2}
BUILDLINK_PACKAGES+=	gdome2

.if !empty(GDOME2_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.gdome2+=	gdome2>=0.8.1nb1
BUILDLINK_PKGSRCDIR.gdome2?=	../../textproc/gdome2
.endif	# GDOME2_BUILDLINK3_MK

.include "../../devel/glib2/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
