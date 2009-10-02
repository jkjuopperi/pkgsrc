# $NetBSD: options.mk,v 1.1.1.1 2009/10/02 19:09:29 markd Exp $
#

PKG_OPTIONS_VAR=	PKG_OPTIONS.ortp
PKG_SUPPORTED_OPTIONS=	inet6

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Minet6)
CONFIGURE_ARGS+=	--enable-ipv6
.endif
