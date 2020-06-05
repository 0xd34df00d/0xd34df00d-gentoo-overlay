# Copyright 2020 Georg Rudoy
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

SRC_URI="https://github.com/cisco/ChezScheme/releases/download/v${PV}/csv${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64"
S=${WORKDIR}/csv${PV}
SLOT="0"

DESCRIPTION="Chez Scheme"
HOMEPAGE="https://cisco.github.io/ChezScheme/"
LICENSE="Apache 2.0"

PATCHES=("${FILESDIR}"/chezscheme-9.5.2-tinfo.patch)

src_configure() {
	./configure \
		--64 \
		--machine=ta6le \
		--threads \
		--temproot=${D} \
		|| die "configure failed"
}
