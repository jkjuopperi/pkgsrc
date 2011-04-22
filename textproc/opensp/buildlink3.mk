# $NetBSD: buildlink3.mk,v 1.13 2011/04/22 13:41:59 obache Exp $

BUILDLINK_TREE+=	opensp

.if !defined(OPENSP_BUILDLINK3_MK)
OPENSP_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.opensp+=	opensp>=1.5.1
BUILDLINK_ABI_DEPENDS.opensp+=	opensp>=1.5.2nb1
BUILDLINK_PKGSRCDIR.opensp?=	../../textproc/opensp

PTHREAD_OPTS+=          require

.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../mk/pthread.buildlink3.mk"
.endif # OPENSP_BUILDLINK3_MK

BUILDLINK_TREE+=	-opensp
