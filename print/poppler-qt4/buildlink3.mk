# $NetBSD: buildlink3.mk,v 1.8 2011/03/09 13:06:49 drochner Exp $

BUILDLINK_TREE+=	poppler-qt4

.if !defined(POPPLER_QT4_BUILDLINK3_MK)
POPPLER_QT4_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.poppler-qt4+=	poppler-qt4>=0.6.1
BUILDLINK_ABI_DEPENDS.poppler-qt4?=	poppler-qt4>=0.16.3
BUILDLINK_PKGSRCDIR.poppler-qt4?=	../../print/poppler-qt4

.include "../../print/poppler/buildlink3.mk"
.endif # POPPLER_QT4_BUILDLINK3_MK

BUILDLINK_TREE+=	-poppler-qt4
