# $NetBSD: buildlink3.mk,v 1.3 2006/01/08 14:00:12 tonio Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
TETEX_BIN_BUILDLINK3_MK:=	${TETEX_BIN_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	teTeX-bin
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NteTeX-bin}
BUILDLINK_PACKAGES+=	teTeX-bin

.if !empty(TETEX_BIN_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.teTeX-bin+=	teTeX-bin-1.[0-9]*
BUILDLINK_DEPMETHOD.teTeX-bin?=	build
BUILDLINK_PKGSRCDIR.teTeX-bin?=	../../print/teTeX1-bin
.endif	# TETEX_BIN_BUILDLINK3_MK

PKG_TEXMFPREFIX=	${PREFIX}/share/texmf
PKG_LOCALTEXMFPREFIX=	${PREFIX}/share/texmf

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
