# $NetBSD: buildlink3.mk,v 1.6 2006/07/08 23:10:56 jlam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
TCL_TCLX_BUILDLINK3_MK:=	${TCL_TCLX_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	tcl-tclX
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Ntcl-tclX}
BUILDLINK_PACKAGES+=	tcl-tclX
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}tcl-tclX

.if !empty(TCL_TCLX_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.tcl-tclX+=	tcl-tclX>=8.3.5
BUILDLINK_ABI_DEPENDS.tcl-tclX?=	tcl-tclX>=8.3.5nb3
BUILDLINK_PKGSRCDIR.tcl-tclX?=	../../lang/tcl-tclX
.endif	# TCL_TCLX_BUILDLINK3_MK

.include "../../lang/tcl/buildlink3.mk"

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH:S/+$//}
