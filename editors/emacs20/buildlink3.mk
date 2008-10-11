# $NetBSD: buildlink3.mk,v 1.2 2008/10/11 09:31:56 uebayasi Exp $
#

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
APEL_BUILDLINK3_MK:=	${APEL_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	emacs
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nemacs}
BUILDLINK_PACKAGES+=	emacs
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}emacs

.if ${APEL_BUILDLINK3_MK} == "+"
.include "../../editors/emacs/modules.mk"
BUILDLINK_API_DEPENDS.emacs+=	${_EMACS_REQD}
BUILDLINK_PKGSRCDIR.emacs?=	${_EMACS_PKGDIR}
.endif	# APEL_BUILDLINK3_MK

BUILDLINK_CONTENTS_FILTER.emacs=	${EGREP} '.*\.el$$|.*\.elc$$'

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
