# $NetBSD: buildlink3.mk,v 1.2 2004/10/03 00:13:21 tv Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
METAKIT_LIB_BUILDLINK3_MK:=	${METAKIT_LIB_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	metakit-lib
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nmetakit-lib}
BUILDLINK_PACKAGES+=	metakit-lib

.if !empty(METAKIT_LIB_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.metakit-lib+=	metakit-lib>=2.4.8
BUILDLINK_RECOMMENDED.metakit-lib+=	metakit-lib>=2.4.9.3nb1
BUILDLINK_PKGSRCDIR.metakit-lib?=	../../databases/metakit-lib
.endif	# METAKIT_LIB_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
