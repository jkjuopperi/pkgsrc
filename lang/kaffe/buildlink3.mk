# $NetBSD: buildlink3.mk,v 1.4 2004/06/05 16:33:52 xtraeme Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
KAFFE_BUILDLINK3_MK:=	${KAFFE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	kaffe
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nkaffe}
BUILDLINK_PACKAGES+=	kaffe

.if !empty(KAFFE_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.kaffe+=	kaffe-[0-9]*
BUILDLINK_PKGSRCDIR.kaffe?=	../../lang/kaffe
BUILDLINK_JAVA_PREFIX.kaffe=	${PREFIX}/java/kaffe
.endif  # KAFFE_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
