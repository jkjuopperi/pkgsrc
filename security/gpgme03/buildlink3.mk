# $NetBSD: buildlink3.mk,v 1.6 2006/04/06 06:22:39 reed Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
GPGME03_BUILDLINK3_MK:=	${GPGME03_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	gpgme03
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ngpgme03}
BUILDLINK_PACKAGES+=	gpgme03

.if !empty(GPGME03_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.gpgme03+=	gpgme03>=0.3.16
BUILDLINK_ABI_DEPENDS.gpgme03+=	gpgme03>=0.3.16nb2
BUILDLINK_PKGSRCDIR.gpgme03?=	../../security/gpgme03

BUILDLINK_FILES.gpgme03+=	bin/gpgme03-config
BUILDLINK_TRANSFORM.gpgme03+=	-e 's|/gpgme03-config|/gpgme-config|g'
BUILDLINK_TRANSFORM.gpgme03+=	-e 's|/gpgme03.h|/gpgme.h|g'
BUILDLINK_TRANSFORM+=		l:gpgme:gpgme03
.endif	# GPGME03_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
