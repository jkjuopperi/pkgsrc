# $NetBSD: buildlink3.mk,v 1.1.1.1 2004/09/30 22:29:31 wulf Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
CPPUNIT_BUILDLINK3_MK:=	${CPPUNIT_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	cppunit
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ncppunit}
BUILDLINK_PACKAGES+=	cppunit

.if !empty(CPPUNIT_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.cppunit+=	cppunit>=1.10.2
BUILDLINK_PKGSRCDIR.cppunit?=	../../devel/cppunit
BUILDLINK_CPPFLAGS.cppunit+=	-I${BUILDLINK_PREFIX.cppunit}/include/cppunit
.endif	# CPPUNIT_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
