# $NetBSD: Makefile,v 1.5 2011/07/03 06:53:42 markd Exp $

PKGNAME=	gnuradio-trellis-${VERSION}
PKGREVISION=	1
COMMENT=	Trellis-based encoding and decoding algorithms for GNU Radio

PKG_DESTDIR_SUPPORT=	user-destdir

.include "../../meta-pkgs/gnuradio/Makefile.common"

CONFIGURE_ARGS+=--enable-gr-trellis
CONFIGURE_ARGS+=--with-gnuradio-core --with-omnithread --with-gruel
CONFIGURE_ENV+=XMLTO=no

PYTHON_PATCH_SCRIPTS+=	gr-trellis/doc/make_numbered_listing.py
PYTHON_PATCH_SCRIPTS+=	gr-trellis/doc/test_tcm.py
PYTHON_PATCH_SCRIPTS+=	gr-trellis/doc/test_viterbi_equalization1.py
PYTHON_PATCH_SCRIPTS+=	gr-trellis/src/python/qa_trellis.py
PYTHON_PATCH_SCRIPTS+=	gr-trellis/src/examples/*.py

.include "../../ham/gnuradio-core/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
