# $NetBSD: buildlink3.mk,v 1.5 2004/03/05 19:25:10 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GLIB2_BUILDLINK3_MK:=	${GLIB2_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	glib2
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nglib2}
BUILDLINK_PACKAGES+=	glib2

.if !empty(GLIB2_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.glib2+=	glib2>=2.2.2nb1
BUILDLINK_PKGSRCDIR.glib2?=	../../devel/glib2

.include "../../converters/libiconv/buildlink3.mk"
.include "../../devel/gettext-lib/buildlink3.mk"

.include "../../mk/pthread.buildlink3.mk"

.endif	# GLIB2_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
