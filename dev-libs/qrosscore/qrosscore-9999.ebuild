# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

EGIT_REPO_URI="git://github.com/0xd34df00d/Qross.git"

inherit cmake-utils multibuild git-r3

DESCRIPTION="KDE-free version of Kross (core libraries and Qt Script backend)"
HOMEPAGE="https://github.com/0xd34df00d/Qross"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug qt4 qt5"
REQUIRED_USE="|| ( qt4 qt5 )"

RDEPEND="
	qt4? (
		dev-qt/qtcore:4
		dev-qt/qtgui:4
		dev-qt/designer:4
		dev-qt/qtscript:4
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
		dev-qt/designer:5
		dev-qt/qtscript:5
	)
"
DEPEND="${RDEPEND}"

CMAKELISTSDIR="src/qross"

src_prepare() {
	MULTIBUILD_VARIANTS=( )
	if use qt4; then
		MULTIBUILD_VARIANTS+=( qt4-shared )
	fi

	if use qt5; then
		MULTIBUILD_VARIANTS+=( qt5-shared )
	fi

	multibuild_copy_sources

	preparation() {
		CMAKE_USE_DIR=${BUILD_DIR}/${CMAKELISTSDIR}
		cmake-utils_src_prepare
	}

	multibuild_foreach_variant run_in_build_dir preparation
}

src_configure() {
	configuration() {
		case "${MULTIBUILD_VARIANT}" in
			qt4-*)
				local mycmakeargs=(
					-DUSE_QT5=OFF
				)
			;;
			qt5-*)
				local mycmakeargs=(
					-DUSE_QT5=ON
				)
			;;
		esac
		CMAKE_USE_DIR=${BUILD_DIR}/${CMAKELISTSDIR}
		cmake-utils_src_configure

	}
	multibuild_parallel_foreach_variant run_in_build_dir configuration
}

src_compile() {
	compilation() {
		CMAKE_USE_DIR=${BUILD_DIR}/${CMAKELISTSDIR}
		cmake-utils_src_compile
	}
	multibuild_foreach_variant run_in_build_dir compilation
}

src_install () {
	installation() {
		CMAKE_USE_DIR=${BUILD_DIR}/${CMAKELISTSDIR}
		cmake-utils_src_install
	}

	multibuild_foreach_variant run_in_build_dir installation
}
