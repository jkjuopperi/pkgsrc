# $NetBSD: buildlink3.mk,v 1.6 2004/03/18 09:12:10 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GLIB_BUILDLINK3_MK:=	${GLIB_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	glib
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nglib}
BUILDLINK_PACKAGES+=	glib

.if !empty(GLIB_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.glib+=	glib>=1.2.10nb5
BUILDLINK_PKGSRCDIR.glib?=	../../devel/glib
.endif	# GLIB_BUILDLINK3_MK

PTHREAD_OPTS+=	require

.include "../../mk/pthread.buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
