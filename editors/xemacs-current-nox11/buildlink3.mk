# $NetBSD: buildlink3.mk,v 1.2 2008/10/11 09:31:56 uebayasi Exp $
#

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
XEMACS_NOX11_BUILDLINK3_MK:=	${XEMACS_NOX11_BUILDLINK3_MK}+

.if ${BUILDLINK_DEPTH} == "+"
BUILDLINK_DEPENDS+=	xemacs-nox11
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxemacs-nox11}
BUILDLINK_PACKAGES+=	xemacs-nox11
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}xemacs-nox11

.if ${XEMACS_NOX11_BUILDLINK3_MK} == "+"
.include "../../editors/emacs/modules.mk"
BUILDLINK_API_DEPENDS.xemacs-nox11+=	${_EMACS_REQD}
BUILDLINK_PKGSRCDIR.xemacs-nox11?=	${_EMACS_PKGDIR}
.endif	# XEMACS_NOX11_BUILDLINK3_MK

BUILDLINK_CONTENTS_FILTER.xemacs-nox11=	${EGREP} '.*\.el$$|.*\.elc$$'

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
