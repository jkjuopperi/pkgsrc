# $NetBSD: buildlink3.mk,v 1.9 2006/12/12 21:52:36 joerg Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
OCTAVE_BUILDLINK3_MK:=	${OCTAVE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	octave
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Noctave}
BUILDLINK_PACKAGES+=	octave
BUILDLINK_ORDER:=	${BUILDLINK_ORDER} ${BUILDLINK_DEPTH}octave

.if !empty(OCTAVE_BUILDLINK3_MK:M+)
BUILDLINK_API_DEPENDS.octave+=	octave>=2.1.69
BUILDLINK_ABI_DEPENDS.octave?=	octave>=2.1.72nb1
BUILDLINK_PKGSRCDIR.octave?=	../../math/octave
.endif	# OCTAVE_BUILDLINK3_MK

.include "../../mk/bsd.fast.prefs.mk"

.if !defined(PKG_OPTIONS.octave:) || !empty(PKG_OPTIONS.octave:Mhdf5)
.include "../../devel/hdf5/buildlink3.mk"
.endif

.include "../../audio/libsndfile/buildlink3.mk"
.include "../../devel/readline/buildlink3.mk"
.include "../../devel/ncurses/buildlink3.mk"
.include "../../math/blas/buildlink3.mk"
.include "../../math/fftw/buildlink3.mk"
.include "../../math/lapack/buildlink3.mk"

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH:S/+$//}
