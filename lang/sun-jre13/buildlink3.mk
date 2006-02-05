# $NetBSD: buildlink3.mk,v 1.3 2006/02/05 23:09:52 joerg Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
SUN_JRE13_BUILDLINK3_MK:=	${SUN_JRE13_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	sun-jre13
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nsun-jre13}
BUILDLINK_PACKAGES+=	sun-jre13

.if !empty(SUN_JRE13_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.sun-jre13+=		sun-jre13-[0-9]*
BUILDLINK_RECOMMENDED.sun-jre13?=		sun-jre13>=1.0.17nb1
BUILDLINK_PKGSRCDIR.sun-jre13?=		../../lang/sun-jre13
BUILDLINK_JAVA_PREFIX.sun-jre13=	${PREFIX}/java/sun-1.3
.endif	# SUN_JRE13_BUILDLINK3_MK

UNLIMIT_RESOURCES+=	datasize	# Must be at least 131203

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
