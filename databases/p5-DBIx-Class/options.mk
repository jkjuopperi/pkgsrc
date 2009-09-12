# $NetBSD: options.mk,v 1.3 2009/09/12 19:30:16 sno Exp $

PKG_OPTIONS_VAR=	PKG_OPTIONS.p5-DBIx-Class
PKG_SUPPORTED_OPTIONS=	sql-translator
PKG_SUGGESTED_OPTIONS=	sql-translator

.include "../../mk/bsd.options.mk"

.if !empty(PKG_OPTIONS:Msql-translator)
DEPENDS+=	p5-SQL-Translator>=0.11002:../../databases/p5-SQL-Translator
.endif
