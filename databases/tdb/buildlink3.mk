# $NetBSD: buildlink3.mk,v 1.6 2006/04/12 10:27:05 rillig Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
TDB_BUILDLINK3_MK:=	${TDB_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	tdb
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ntdb}
BUILDLINK_PACKAGES+=	tdb

.if !empty(TDB_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.tdb+=		tdb>=1.0.6
BUILDLINK_ABI_DEPENDS.tdb+=	tdb>=1.0.6nb2
BUILDLINK_PKGSRCDIR.tdb?=	../../databases/tdb
.endif	# TDB_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
