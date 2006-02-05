# $NetBSD: buildlink3.mk,v 1.2 2006/02/05 23:08:44 joerg Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBCFG_BUILDLINK3_MK:=	${LIBCFG_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libcfg
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibcfg}
BUILDLINK_PACKAGES+=	libcfg

.if !empty(LIBCFG_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libcfg+=	libcfg+>=0.6.2nb1
BUILDLINK_RECOMMENDED.libcfg++=	libcfg+>=0.6.2nb3
BUILDLINK_PKGSRCDIR.libcfg?=	../../devel/libcfg+
.endif	# LIBCFG_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
