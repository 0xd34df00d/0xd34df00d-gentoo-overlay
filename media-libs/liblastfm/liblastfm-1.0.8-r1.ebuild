# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/liblastfm/liblastfm-1.0.8.ebuild,v 1.4 2013/12/10 19:53:06 ago Exp $

EAPI=5

QT_MINIMAL="4.8.0"
inherit cmake-utils multibuild

DESCRIPTION="A Qt C++ library for the Last.fm webservices"
HOMEPAGE="https://github.com/lastfm/liblastfm"
SRC_URI="https://github.com/lastfm/liblastfm/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ppc ~ppc64 x86 ~amd64-linux ~x86-linux"
IUSE="fingerprint test +qt4 qt5"
REQUIRED_USE="^^ ( qt4 qt5 )"

COMMON_DEPEND="
	qt4? (
		dev-qt/qtcore:4
		dev-qt/qtdbus:4
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtdbus:5
		dev-qt/qtnetwork:5
		dev-qt/qtxml:5
	)
	fingerprint? (
		media-libs/libsamplerate
		sci-libs/fftw:3.0
		qt4? ( dev-qt/qtsql:4 )
		qt5? ( dev-qt/qtsql:5 )
	)
"
DEPEND="${COMMON_DEPEND}
	test? (
		qt4? ( dev-qt/qttest:4 )
		qt5? ( dev-qt/qttest:5 )
	)
"
RDEPEND="${COMMON_DEPEND}
	!<media-libs/lastfmlib-0.4.0
"
REQUIRED_USE="|| ( qt4 qt5 )"

# 1 of 2 is failing, last checked version 1.0.7
RESTRICT="test"

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
		CMAKE_USE_DIR=${BUILD_DIR}
		case "${MULTIBUILD_VARIANT}" in
			qt4-*)
				sed -e "90,100s/\<lastfm\>/lastfm-qt4/g" -i src/CMakeLists.txt || die
			;;
			qt5-*)
				sed -e "90,100s/\<lastfm\>/lastfm-qt5/g" -i src/CMakeLists.txt || die
			;;
		esac
		cmake-utils_src_prepare
	}

	multibuild_foreach_variant run_in_build_dir preparation
}

src_configure() {
	configuration() {
		case "${MULTIBUILD_VARIANT}" in
			qt4-*)
				local mycmakeargs=(
					-DBUILD_DEMOS=OFF
					-DBUILD_WITH_QT4=ON
					$(cmake-utils_use_build fingerprint)
					$(cmake-utils_use_build test TESTS)
				)

				CMAKE_USE_DIR=${BUILD_DIR}
				cmake-utils_src_configure
			;;
			qt5-*)
				local mycmakeargs=(
					-DBUILD_DEMOS=OFF
					-DBUILD_WITH_QT4=OFF
					$(cmake-utils_use_build fingerprint)
					$(cmake-utils_use_build test TESTS)
				)

				CMAKE_USE_DIR=${BUILD_DIR}
				cmake-utils_src_configure
			;;
		esac

	}
	multibuild_parallel_foreach_variant run_in_build_dir configuration
}

src_compile() {
	compilation() {
		CMAKE_USE_DIR=${BUILD_DIR}
		cmake-utils_src_compile
	}
	multibuild_foreach_variant run_in_build_dir compilation
}

src_install () {
	installation() {
		CMAKE_USE_DIR=${BUILD_DIR}
		cmake-utils_src_install
	}

	multibuild_foreach_variant run_in_build_dir installation
}
