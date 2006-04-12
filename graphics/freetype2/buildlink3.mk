# $NetBSD: buildlink3.mk,v 1.27 2006/04/12 10:27:17 rillig Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
FREETYPE2_BUILDLINK3_MK:=	${FREETYPE2_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	freetype2
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nfreetype2}
BUILDLINK_PACKAGES+=	freetype2

.if !empty(FREETYPE2_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.freetype2+=	freetype2>=2.1.8
BUILDLINK_ABI_DEPENDS.freetype2+=	freetype2>=2.1.10nb1
BUILDLINK_PKGSRCDIR.freetype2?=	../../graphics/freetype2
BUILDLINK_INCDIRS.freetype2?=	include/freetype2

FREETYPE_CONFIG?=	${BUILDLINK_PREFIX.freetype2}/bin/freetype-config
CONFIGURE_ENV+=		FREETYPE_CONFIG=${FREETYPE_CONFIG:Q}

.endif	# FREETYPE2_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
