# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

MY_P="${PN}${PV}"

DESCRIPTION="Tcl Thread extension"
HOMEPAGE="http://www.tcl.tk/"
SRC_URI="https://downloads.sourceforge.net/project/tcl/Thread%20Extension/${PV}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~m68k ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86"
IUSE=""

DEPEND="dev-lang/tcl:0=[threads]"
RDEPEND="${DEPEND}"

S="${WORKDIR}"/${PN}${PV}

src_prepare() {
	default

	# Search for libs in libdir not just exec_prefix/lib
	sed -i -e 's:${exec_prefix}/lib:${libdir}:' \
		aclocal.m4 || die "sed failed"

	sed -i -e "s/relid'/relid/" tclconfig/tcl.m4 || die

	eautoreconf
}

src_configure() {
	econf --with-tclinclude="${EPREFIX}/usr/include" \
		--with-tcl="${EPREFIX}/usr/$(get_libdir)"
}
