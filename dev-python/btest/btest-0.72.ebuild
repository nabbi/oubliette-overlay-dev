# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_10 )
inherit distutils-r1

DESCRIPTION="BTest is a powerful framework for writing system tests."
HOMEPAGE="
	https://pypi.org/project/btest/
"
SRC_URI="https://github.com/zeek/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=""
BDEPEND="
	dev-python/sphinx
	dev-util/perf
"

distutils_enable_tests pytest
