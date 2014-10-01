# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qtermwidget/qtermwidget-9999.ebuild,v 1.2 2014/09/13 16:36:24 kensington Exp $

EAPI=5

inherit cmake-utils git-r3 multibuild

DESCRIPTION="Qt terminal emulator widget"
HOMEPAGE="https://github.com/qterminal/qtermwidget"
EGIT_REPO_URI="https://github.com/qterminal/qtermwidget.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""
IUSE="debug qt4 qt5"

REQUIRED_USE="|| ( qt4 qt5 )"

DEPEND="
	qt4? (
		dev-qt/qtcore:4
		dev-qt/qtgui:4
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
	)"
RDEPEND="${DEPEND}"

src_prepare() {
	sed \
		-e 's/int scheme/const QString \&name/' \
		-i pyqt4/qtermwidget.sip || die

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
		cmake-utils_src_prepare
	}

	multibuild_foreach_variant run_in_build_dir preparation
}

src_configure() {
	preparation() {
		CMAKE_USE_DIR=${BUILD_DIR}
		case "${MULTIBUILD_VARIANT}" in
			qt4-*)
				local mycmakeargs=(
				)
				cmake-utils_src_configure
			;;
			qt5-*)
				local mycmakeargs=(
					$(cmake-utils_use_use qt5)
					-DBUILD_DESIGNER_PLUGIN=0
				)
				cmake-utils_src_configure
			;;
		esac
	}

	multibuild_foreach_variant run_in_build_dir preparation
}

src_compile() {
	compilation() {
		CMAKE_USE_DIR=${BUILD_DIR}
		cmake-utils_src_compile

	}
	multibuild_foreach_variant run_in_build_dir compilation
}

src_install() {
	installation() {
		CMAKE_USE_DIR=${BUILD_DIR}
		cmake-utils_src_install
	}
	multibuild_foreach_variant run_in_build_dir installation
}
