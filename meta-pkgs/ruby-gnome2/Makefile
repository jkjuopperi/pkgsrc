# $NetBSD: Makefile,v 1.14 2011/02/11 13:50:07 obache Exp $
#

PKGNAME=	${RUBY_PKGPREFIX}-gnome2-${VERSION}
COMMENT=	Set of Ruby language bindings for GNOME2
CATEGORIES=	meta-pkgs gnome

DEPENDS+=	${RUBY_PKGPREFIX}-gnome2-atk>=${VERSION}:../../devel/ruby-gnome2-atk
DEPENDS+=	${RUBY_PKGPREFIX}-gnome2-gio>=${VERSION}:../../devel/ruby-gnome2-gio
DEPENDS+=	${RUBY_PKGPREFIX}-gnome2-glib>=${VERSION}:../../devel/ruby-gnome2-glib
DEPENDS+=	${RUBY_PKGPREFIX}-gnome2-pango>=${VERSION}:../../devel/ruby-gnome2-pango
DEPENDS+=	${RUBY_PKGPREFIX}-gnome2-gdkpixbuf>=${VERSION}:../../graphics/ruby-gnome2-gdkpixbuf
DEPENDS+=	${RUBY_PKGPREFIX}-gnome2-goocanvas>=${VERSION}:../../graphics/ruby-gnome2-goocanvas
DEPENDS+=	${RUBY_PKGPREFIX}-gnome2-rsvg>=${VERSION}:../../graphics/ruby-gnome2-rsvg
DEPENDS+=	${RUBY_PKGPREFIX}-gnome2-gstreamer>=${VERSION}:../../multimedia/ruby-gnome2-gstreamer
DEPENDS+=	${RUBY_PKGPREFIX}-gnome2-poppler>=${VERSION}:../../print/ruby-gnome2-poppler
DEPENDS+=	${RUBY_PKGPREFIX}-gnome2-gtkmozembed>=${VERSION}:../../www/ruby-gnome2-gtkmozembed
DEPENDS+=	${RUBY_PKGPREFIX}-gnome2-gtk>=${VERSION}:../../x11/ruby-gnome2-gtk
DEPENDS+=	${RUBY_PKGPREFIX}-gnome2-gtksourceview2>=${VERSION}:../../x11/ruby-gnome2-gtksourceview2
DEPENDS+=	${RUBY_PKGPREFIX}-gnome2-vte>=${VERSION}:../../x11/ruby-gnome2-vte

META_PACKAGE=	yes

.include "../../lang/ruby/rubyversion.mk"
.include "Makefile.common"
