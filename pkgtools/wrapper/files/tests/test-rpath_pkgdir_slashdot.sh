# $NetBSD: test-rpath_pkgdir_slashdot.sh,v 1.1.2.1 2008/07/13 20:10:37 schmonz Exp $
#

atf_test_case rpath_pkgdir_slashdot
rpath_pkgdir_slashdot_head() {
    atf_set 'descr' 'XXX autoconverted from rpath-pkgdir-slashdot.mk'
}
rpath_pkgdir_slashdot_body() {
    input="${COMPILER_RPATH_FLAG}${LOCALBASE}/lib/."
    case "${_USE_RPATH}" in
    [yY][eE][sS])
        echo "${COMPILER_RPATH_FLAG}${LOCALBASE}/lib" > expout
        ;;
    *)
        echo > expout
        ;;
    esac
    atf_check 'echowrapper ${input}' 0 expout ignore
}

atf_init_test_cases() {
    atf_add_test_case rpath_pkgdir_slashdot
}
