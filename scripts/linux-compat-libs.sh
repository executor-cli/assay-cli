# Sourced by mise ([env] _.source) for every task.
# The Swift 6.3.3 toolchain (SwiftPM, docc) and executor are built for Ubuntu 24.04
# and link libxml2.so.2 + ICU 74. Ubuntu 26.04 (ubuntu-latest since 2026-10) only
# ships libxml2.so.16 and has no 6.3.3 toolchain, so borrow the 24.04 libraries
# into a cache dir and expose them through LD_LIBRARY_PATH.

[ "$(uname -s)" = "Linux" ] || return 0
if ldconfig -p 2>/dev/null | grep 'libxml2\.so\.2 ' >/dev/null; then
    return 0
fi

case "$(uname -m)" in
    x86_64) _deb_arch=amd64 _deb_mirror=http://archive.ubuntu.com/ubuntu ;;
    aarch64) _deb_arch=arm64 _deb_mirror=http://ports.ubuntu.com/ubuntu-ports ;;
    *) echo "linux-compat-libs: unsupported arch $(uname -m)" >&2; return 1 ;;
esac

_lib_dir="${XDG_CACHE_HOME:-$HOME/.cache}/linux-compat-libs/${_deb_arch}"
if [ ! -e "${_lib_dir}/libxml2.so.2" ]; then
    _tmp=$(mktemp -d)
    for _pkg in libx/libxml2/libxml2_2.9.14+dfsg-1.3ubuntu3 i/icu/libicu74_74.2-1ubuntu3; do
        curl -fsSL -o "${_tmp}/pkg.deb" "${_deb_mirror}/pool/main/${_pkg}_${_deb_arch}.deb"
        dpkg-deb -x "${_tmp}/pkg.deb" "${_tmp}/root"
    done
    mkdir -p "${_lib_dir}"
    cp -a "${_tmp}"/root/usr/lib/*-linux-gnu/. "${_lib_dir}/"
    rm -rf "${_tmp}"
fi

case ":${LD_LIBRARY_PATH:-}:" in
    *":${_lib_dir}:"*) ;;
    *) export LD_LIBRARY_PATH="${_lib_dir}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" ;;
esac
unset _deb_arch _deb_mirror _lib_dir _tmp _pkg
