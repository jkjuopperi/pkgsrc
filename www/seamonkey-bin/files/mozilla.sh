#!@SH@
# $NetBSD: mozilla.sh,v 1.1 2006/09/24 16:35:39 salo Exp $

LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:@PREFIX@/lib/@MOZILLA@@MOZ_EXTRA@-@MOZ_PLATFORM@"
export LD_LIBRARY_PATH

exec @PREFIX@/lib/@MOZILLA@@MOZ_EXTRA@-@MOZ_PLATFORM@/@MOZILLA@ "$@"
