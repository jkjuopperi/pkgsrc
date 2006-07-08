# $NetBSD: buildlink3.mk,v 1.7 2006/07/08 23:10:41 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
UNIXODBC_BUILDLINK3_MK:=	${UNIXODBC_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	unixodbc
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nunixodbc}
BUILDLINK_PACKAGES+=	unixodbc
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}unixodbc

.if !empty(UNIXODBC_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.unixodbc+=	unixodbc>=2.0.11nb1
BUILDLINK_ABI_DEPENDS.unixodbc+=	unixodbc>=2.0.11nb3
BUILDLINK_PKGSRCDIR.unixodbc?=	../../databases/unixodbc
.endif	# UNIXODBC_BUILDLINK3_MK

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
