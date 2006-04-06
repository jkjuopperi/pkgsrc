# $NetBSD: buildlink3.mk,v 1.5 2006/04/06 06:21:33 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBLZO_BUILDLINK3_MK:=	${LIBLZO_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	liblzo
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nliblzo}
BUILDLINK_PACKAGES+=	liblzo

.if !empty(LIBLZO_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.liblzo+=	liblzo>=1.08
BUILDLINK_PKGSRCDIR.liblzo?=	../../archivers/liblzo
BUILDLINK_ABI_DEPENDS.liblzo+=	liblzo>=1.08nb1
.endif	# LIBLZO_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
