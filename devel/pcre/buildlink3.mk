# $NetBSD: buildlink3.mk,v 1.5 2004/03/05 19:25:11 jlam Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
PCRE_BUILDLINK3_MK:=	${PCRE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pcre
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npcre}
BUILDLINK_PACKAGES+=	pcre

.if !empty(PCRE_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.pcre+=	pcre>=3.4nb1
BUILDLINK_PKGSRCDIR.pcre?=	../../devel/pcre
.endif	# PCRE_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
