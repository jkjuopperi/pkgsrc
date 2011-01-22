# $NetBSD: buildlink3.mk,v 1.1 2010/03/14 14:19:19 martin Exp $

BUILDLINK_TREE+=	mpg123

.if !defined(MPG123_BUILDLINK3_MK)
MPG123_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.mpg123+=	mpg123>=1.0.0
BUILDLINK_PKGSRCDIR.mpg123?=	../../audio/mpg123
.endif # MPG123_BUILDLINK3_MK

BUILDLINK_TREE+=	-mpg123