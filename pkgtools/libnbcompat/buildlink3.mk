# $NetBSD: buildlink3.mk,v 1.12 2004/09/11 19:05:16 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBNBCOMPAT_BUILDLINK3_MK:=	${LIBNBCOMPAT_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libnbcompat
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibnbcompat}
BUILDLINK_PACKAGES+=	libnbcompat

.if !empty(LIBNBCOMPAT_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libnbcompat+=		libnbcompat>=20040911
BUILDLINK_PKGSRCDIR.libnbcompat?=	../../pkgtools/libnbcompat
BUILDLINK_DEPMETHOD.libnbcompat?=	build
BUILDLINK_LDADD.libnbcompat=		-lnbcompat

.if defined(GNU_CONFIGURE)
LIBS+=	${BUILDLINK_LDADD.libnbcompat}
.endif

.endif  # LIBNBCOMPAT_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
