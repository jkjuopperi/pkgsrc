# $NetBSD: buildlink3.mk,v 1.2 2006/02/05 23:10:30 joerg Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
PYLIBDNET_BUILDLINK3_MK:=	${PYLIBDNET_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	pylibdnet
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Npylibdnet}
BUILDLINK_PACKAGES+=	pylibdnet

.if !empty(PYLIBDNET_BUILDLINK3_MK:M+)

.include "../../lang/python/pyversion.mk"

BUILDLINK_DEPENDS.pylibdnet+=	${PYPKGPREFIX}-libdnet>=1.7
BUILDLINK_RECOMMENDED.pylibdnet?=	${PYPKGPREFIX}-libdnet>=1.10nb1
BUILDLINK_PKGSRCDIR.pylibdnet?=	../../net/py-libdnet
.endif	# PYLIBDNET_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
