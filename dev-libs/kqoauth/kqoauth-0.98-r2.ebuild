# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/kqoauth/kqoauth-0.98-r1.ebuild,v 1.2 2014/07/11 17:54:39 zlogene Exp $

EAPI=5

inherit qt4-r2 multibuild vcs-snapshot

DESCRIPTION="Library for Qt that implements the OAuth 1.0 authentication specification"
HOMEPAGE="https://github.com/kypeli/kQOAuth"
SRC_URI="https://github.com/kypeli/kQOAuth/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+qt4 qt5"

DEPEND="
	qt4? ( dev-qt/qtcore:4
		dev-qt/qtgui:4 )
	qt5? ( dev-qt/qtcore:5
		dev-qt/qtgui:5 )
"
RDEPEND="${DEPEND}"
REQUIRED_USE="|| ( qt4 qt5 )"

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
		# prevent tests from beeing built at src_compile
		sed -i -e '/SUBDIRS/s/ tests//' ${PN}.pro || die "sed on ${PN}.pro failed"
		# respect libdir
		sed -e 's:{INSTALL_PREFIX}/lib:[QT_INSTALL_LIBS]:g' -i src/src.pro || die "sed on src.pro failed"

		case "${MULTIBUILD_VARIANT}" in
			qt4-*)
				sed \
					-e "s/TARGET = kqoauth/TARGET = kqoauth-qt4/g" \
					-i src/src.pro || die
				qt4-r2_src_prepare
			;;
			qt5-*)
				sed \
					-e "s/TARGET = kqoauth/TARGET = kqoauth-qt5/g" \
					-i src/src.pro || die
			;;
		esac
	}

	multibuild_foreach_variant run_in_build_dir preparation
}

src_configure() {
	configuration() {
		case "${MULTIBUILD_VARIANT}" in
			qt4-*)
				qt4-r2_src_configure
			;;
			qt5-*)
				/usr/lib/qt5/bin/qmake
			;;
		esac

	}
	multibuild_parallel_foreach_variant run_in_build_dir configuration
}

src_compile() {
	compilation() {
		case "${MULTIBUILD_VARIANT}" in
			qt4-*)
				qt4-r2_src_compile
			;;
			qt5-*)
				emake
			;;
		esac

	}
	multibuild_foreach_variant run_in_build_dir compilation
}

src_install () {
	installation() {
		case "${MULTIBUILD_VARIANT}" in
			qt4-*)
				qt4-r2_src_install
			;;
			qt5-*)
				emake INSTALL_ROOT="${D}" install
			;;
		esac
	}

	multibuild_foreach_variant run_in_build_dir installation
}
