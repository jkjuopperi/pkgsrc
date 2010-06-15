# $NetBSD: options.mk,v 1.9 2010/06/15 20:05:48 joerg Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.nginx
PKG_SUPPORTED_OPTIONS=	ssl pcre dav flv sub gtools mail-proxy memcache \
			realip inet6 uwsgi
PKG_SUGGESTED_OPTIONS=	ssl pcre

PLIST_VARS+=		uwsgi

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Mssl)
.include "../../security/openssl/buildlink3.mk"
CONFIGURE_ARGS+=	--with-mail_ssl_module
CONFIGURE_ARGS+=	--with-http_ssl_module
.endif

.if !empty(PKG_OPTIONS:Mpcre)
.include "../../devel/pcre/buildlink3.mk"
.else
CONFIGURE_ARGS+=	--without-pcre
CONFIGURE_ARGS+=	--without-http_rewrite_module
.endif

.if !empty(PKG_OPTIONS:Mdav)
CONFIGURE_ARGS+=	--with-http_dav_module
.endif

.if !empty(PKG_OPTIONS:Mflv)
CONFIGURE_ARGS+=	--with-http_flv_module
.endif

.if !empty(PKG_OPTIONS:Msub)
CONFIGURE_ARGS+=	--with-http_sub_module
.endif

.if !empty(PKG_OPTIONS:Mgtools)
CONFIGURE_ARGS+=	--with-google_perftools_module
.endif

.if !empty(PKG_OPTIONS:Mmail-proxy)
CONFIGURE_ARGS+=	--with-mail
.endif

.if empty(PKG_OPTIONS:Mmemcache)
CONFIGURE_ARGS+=	--without-http_memcached_module
.endif

.if !empty(PKG_OPTIONS:Mrealip)
CONFIGURE_ARGS+=       --with-http_realip_module
.endif

.if !empty(PKG_OPTIONS:Minet6)
CONFIGURE_ARGS+=       --with-ipv6
.endif

.if !empty(PKG_OPTIONS:Muwsgi)
EGFILES+=		uwsgi_params
PLIST.uwsgi=		yes
.else
CONFIGURE_ARGS+=	--without-http_uwsgi_module
.endif
