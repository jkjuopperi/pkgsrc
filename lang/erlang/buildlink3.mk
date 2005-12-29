# $NetBSD: buildlink3.mk,v 1.1.2.2 2005/12/29 20:54:22 ghen Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
ERLANG_BUILDLINK3_MK:=		${ERLANG_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=		erlang
.endif

BUILDLINK_PACKAGES:=		${BUILDLINK_PACKAGES:Nerlang}
BUILDLINK_PACKAGES+=		erlang

.if !empty(ERLANG_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.erlang+=	erlang>=10.1
BUILDLINK_PKGSRCDIR.erlang?=	../../lang/erlang
.endif	# ERLANG_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
