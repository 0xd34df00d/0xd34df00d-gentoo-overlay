# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

SCM=""
if [ "${PV%9999}" != "${PV}" ] ; then # Live ebuild
	SCM=git-r3
	EGIT_BRANCH=master
	EGIT_REPO_URI="https://github.com/01org/cmrt"
fi

AUTOTOOLS_AUTORECONF="yes"
inherit autotools-multilib ${SCM}

DESCRIPTION="HW video decode support for Intel integrated graphics"
HOMEPAGE="https://github.com/01org/cmrt"
if [ "${PV%9999}" != "${PV}" ] ; then # Live ebuild
	SRC_URI=""
else
	SRC_URI="${HOMEPAGE}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/cmrt-${PV}"
fi

LICENSE="MIT"
SLOT="0"
if [ "${PV%9999}" = "${PV}" ] ; then
	KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
else
	KEYWORDS=""
fi
IUSE=""

RDEPEND=">=x11-libs/libva-2.0.0:=[drm,${MULTILIB_USEDEP}]
	>=x11-libs/libdrm-2.4.52[video_cards_intel,${MULTILIB_USEDEP}]"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS=( AUTHORS NEWS README )
AUTOTOOLS_PRUNE_LIBTOOL_FILES="all"

src_prepare() {
	sed -e 's/intel-gen4asm/\0diSaBlEd/g' -i configure.ac || die
	autotools-multilib_src_prepare
}

multilib_src_configure() {
	autotools-utils_src_configure
}
