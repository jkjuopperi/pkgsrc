# $NetBSD: buildlink3.mk,v 1.6 2006/02/05 23:08:08 joerg Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
FLAC_BUILDLINK3_MK:=	${FLAC_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	flac
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nflac}
BUILDLINK_PACKAGES+=	flac

.if !empty(FLAC_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.flac+=	flac>=1.1.0nb1
BUILDLINK_RECOMMENDED.flac+=	flac>=1.1.2nb1
BUILDLINK_PKGSRCDIR.flac?=	../../audio/flac
.endif	# FLAC_BUILDLINK3_MK

.include "../../multimedia/libogg/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
