#!/bin/sh
#
# $NetBSD: wrapper.sh,v 1.1.2.3 2002/06/28 06:26:58 jlam Exp $

Xsed='@SED@ -e 1s/^X//'
sed_quote_subst='s/\([\\`\\"$\\\\]\)/\\\1/g'

pre_cache="@_BLNK_WRAP_PRE_CACHE@"
cache="@_BLNK_WRAP_CACHE@"
post_cache="@_BLNK_WRAP_POST_CACHE@"
logic="@_BLNK_WRAP_LOGIC@"
wrapperlog="@_BLNK_WRAP_LOG@"

cmd="@WRAPPEE@"
for arg; do
	cacheupdated=
	. $logic
	case "$cacheupdated" in
	yes) @CAT@ $pre_cache $cache $post_cache > $logic ;;
	esac
	args="$args $arg"
done
cmd="$cmd $args"

@_BLNK_WRAP_SANITIZE_PATH@

@ECHO@ $cmd >> $wrapperlog
eval exec $cmd
