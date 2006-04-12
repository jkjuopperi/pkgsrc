# $NetBSD: buildlink3.mk,v 1.5 2006/04/12 10:27:11 rillig Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
LIBNTLM_BUILDLINK3_MK:=	${LIBNTLM_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libntlm
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibntlm}
BUILDLINK_PACKAGES+=	libntlm

.if !empty(LIBNTLM_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.libntlm+=	libntlm>=0.3.2
BUILDLINK_ABI_DEPENDS.libntlm+=	libntlm>=0.3.6nb1
BUILDLINK_PKGSRCDIR.libntlm?=	../../devel/libntlm
.endif	# LIBNTLM_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
