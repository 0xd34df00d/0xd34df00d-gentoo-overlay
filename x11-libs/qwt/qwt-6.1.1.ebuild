# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qwt/qwt-6.1.0.ebuild,v 1.10 2014/01/06 09:41:31 ago Exp $

EAPI=5

inherit eutils multibuild qt4-r2

MY_P="${PN}-${PV/_/-}"

DESCRIPTION="2D plotting library for Qt4"
HOMEPAGE="http://qwt.sourceforge.net/"
SRC_URI="mirror://sourceforge/project/${PN}/${PN}/${PV/_/-}/${MY_P}.tar.bz2"

LICENSE="qwt mathml? ( LGPL-2.1 Nokia-Qt-LGPL-Exception-1.1 )"
KEYWORDS="~alpha amd64 hppa ~ia64 ppc ppc64 sparc x86 ~amd64-linux ~x86-linux ~x86-macos"
SLOT="6"
IUSE="doc examples mathml +qt4 qt5 static-libs svg"

DEPEND="
	!<x11-libs/qwt-5.2.3
	qt4? ( dev-qt/designer:4
		svg? ( dev-qt/qtsvg:4 ) )
	qt5? ( dev-qt/qtwidgets:5
		dev-qt/qtconcurrent:5
		dev-qt/designer:5
		svg? ( dev-qt/qtsvg:5 ) )
	doc? ( !<media-libs/coin-3.1.3[doc] )"
RDEPEND="${DEPEND}"

S="${WORKDIR}"/${MY_P}

DOCS="README"

src_prepare() {
	cat > qwtconfig.pri <<-EOF
		QWT_INSTALL_LIBS = "${EPREFIX}/usr/$(get_libdir)"
		QWT_INSTALL_HEADERS = "${EPREFIX}/usr/include/qwt6"
		QWT_INSTALL_DOCS = "${EPREFIX}/usr/share/doc/${PF}"
		QWT_CONFIG += QwtPlot QwtWidgets QwtDesigner
		VERSION = ${PV/_*}
		QWT_VERSION = ${PV/_*}
	EOF

	use mathml && echo "QWT_CONFIG += QwtMathML" >> qwtconfig.pri
	use svg && echo "QWT_CONFIG += QwtSvg" >> qwtconfig.pri

	cat > qwtbuild.pri <<-EOF
		QWT_CONFIG += qt warn_on thread release no_keywords
	EOF

	MULTIBUILD_VARIANTS=( )
	if use qt4; then
		use static-libs && MULTIBUILD_VARIANTS+=( qt4-static )
		MULTIBUILD_VARIANTS+=( qt4-shared )
	fi

	if use qt5; then
		use static-libs && MULTIBUILD_VARIANTS+=( qt5-static )
		MULTIBUILD_VARIANTS+=( qt5-shared )
	fi

	EPATCH_SOURCE="${FILESDIR}" EPATCH_SUFFIX="patch" EPATCH_FORCE="yes" epatch

	multibuild_copy_sources

	preparation() {
		if [[ ${MULTIBUILD_VARIANT} == *-shared ]]; then
			echo "QWT_CONFIG += QwtDll" >> qwtconfig.pri
		fi

		case "${MULTIBUILD_VARIANT}" in
			qt4-*)
				cat >> qwtconfig.pri <<-EOF
					QWT_INSTALL_PLUGINS   = "${EPREFIX}/usr/$(get_libdir)/qt4/plugins/designer"
					QWT_INSTALL_FEATURES  = "${EPREFIX}/usr/share/qt4/mkspecs/features"
				EOF
				sed \
					-e 's/target doc/target/' \
					-e "/^TARGET/s:(qwt):(qwt6-qt4):g" \
					-i src/src.pro || die

				sed \
					-e '/qwtAddLibrary/s:(qwt):(qwt6-qt4):g' \
					-i qwt.prf designer/designer.pro examples/examples.pri \
					textengines/mathml/qwtmathml.prf textengines/textengines.pri || die

				qt4-r2_src_prepare
			;;
			qt5-*)
				cat >> qwtconfig.pri <<-EOF
					QWT_INSTALL_PLUGINS   = "${EPREFIX}/usr/$(get_libdir)/qt5/plugins/designer"
					QWT_INSTALL_FEATURES  = "${EPREFIX}/usr/share/qt5/mkspecs/features"
				EOF
				sed \
					-e 's/target doc/target/' \
					-e "/^TARGET/s:(qwt):(qwt6-qt5):g" \
					-i src/src.pro || die

				sed \
					-e '/qwtAddLibrary/s:(qwt):(qwt6-qt5):g' \
					-i qwt.prf designer/designer.pro examples/examples.pri \
					textengines/mathml/qwtmathml.prf textengines/textengines.pri || die
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

src_test() {
	testing() {
		cd examples || die
		eqmake4 examples.pro
		emake
	}
#	multibuild_foreach_variant run_in_build_dir testing
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

	rm -f doc/man/*/{_,deprecated}* || die
	multibuild_foreach_variant run_in_build_dir installation

	use doc && dohtml -r doc/html/*

	if use examples; then
		# don't build examples - fix the qt files to build once installed
		cat > examples/examples.pri <<-EOF
			include( qwtconfig.pri )
			TEMPLATE     = app
			MOC_DIR      = moc
			INCLUDEPATH += "${EPREFIX}/usr/include/qwt6"
			DEPENDPATH  += "${EPREFIX}/usr/include/qwt6"
			LIBS        += -lqwt6
		EOF
		sed -i -e 's:../qwtconfig:qwtconfig:' examples/examples.pro || die
		cp *.pri examples/ || die
		insinto /usr/share/${PN}6
		doins -r examples
	fi
}
