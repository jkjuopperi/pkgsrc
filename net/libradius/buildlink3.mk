# $NetBSD: buildlink3.mk,v 1.4 2004/11/11 11:57:47 grant Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBRADIUS_LINUX_BUILDLINK3_MK:=	${LIBRADIUS_LINUX_BUILDLINK3_MK}+

.include "../../mk/bsd.prefs.mk"

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libradius
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibradius}
BUILDLINK_PACKAGES+=	libradius

.if !empty(LIBRADIUS_LINUX_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libradius+=	libradius>=20040827
BUILDLINK_PKGSRCDIR.libradius?=	../../net/libradius
BUILDLINK_DEPMETHOD.libradius?=	build

.  if ${OPSYS} == "FreeBSD"
BUILDLINK_LDADD.libradius+=	-lmd
BUILDLINK_LDFLAGS.libradius?=	${BUILDLINK_LDADD.libradius}
.  endif
.endif	# LIBRADIUS_LINUX_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
