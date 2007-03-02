# $NetBSD: buildlink3.mk,v 1.1.1.1 2007/03/02 01:56:46 dmcmahill Exp $
#

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
CONFUSE_BUILDLINK3_MK:=	${CONFUSE_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	confuse
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nconfuse}
BUILDLINK_PACKAGES+=	confuse
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}confuse

.if ${CONFUSE_BUILDLINK3_MK} == "+"
BUILDLINK_API_DEPENDS.confuse+=	confuse>=2.5
BUILDLINK_PKGSRCDIR.confuse?=	../../devel/confuse.work
.endif	# CONFUSE_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
