# $NetBSD: buildlink3.mk,v 1.7 2004/03/08 20:29:43 minskim Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
TK_BUILDLINK3_MK:=	${TK_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	tk
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ntk}
BUILDLINK_PACKAGES+=	tk

.if !empty(TK_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.tk+=		tk>=8.4.5
BUILDLINK_PKGSRCDIR.tk?=	../../x11/tk

BUILDLINK_FILES.tk=	bin/wish*
#
# Make "-ltk" resolve into "-ltk84", so that we don't need to patch so
# many Makefiles.
#
BUILDLINK_TRANSFORM+=	l:tk:tk84

USE_X11=	yes
TKCONFIG_SH?=	${BUILDLINK_PREFIX.tk}/lib/tkConfig.sh

.include "../../lang/tcl/buildlink3.mk"

.endif	# TK_BUILDLINK3_MK

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
