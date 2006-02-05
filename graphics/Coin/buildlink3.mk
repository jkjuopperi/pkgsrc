# $NetBSD: buildlink3.mk,v 1.3 2006/02/05 23:09:26 joerg Exp $
#
# This Makefile fragment is included by packages that use Coin.
#
# This file was created automatically using createbuildlink-3.1.
#

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
COIN_BUILDLINK3_MK:=	${COIN_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	Coin
.endif

.if !empty(COIN_BUILDLINK3_MK:M+)
BUILDLINK_PACKAGES+=			Coin
BUILDLINK_DEPENDS.Coin+=		Coin>=2.2.1
BUILDLINK_RECOMMENDED.Coin?=		Coin>=2.4.4nb1
BUILDLINK_PKGSRCDIR.Coin?=		../../graphics/Coin

.include "../../graphics/simage/buildlink3.mk"
.include "../../graphics/freetype2/buildlink3.mk"
.include "../../graphics/glu/buildlink3.mk"
.include "../../mk/x11.buildlink3.mk"

.endif # COIN_BUILDLINK3_MK

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
