# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit eutils desktop

SLOT="0"
PV_STRING="$(ver_cut 2-6)"
MY_PV="$(ver_cut 1-3)"
MY_PN="idea"
# Using the most recent Jetbrains Runtime binaries available at the time of writing
# As the exact bundled versions ( jre 11 build 159.30 and jre 8 build 1483.39 ) aren't
# available separately
JRE11_BASE="11_0_2"
JRE11_VER="164"
JRE_BASE="8u202"
JRE_VER="1483.37"

KEYWORDS="~amd64 ~x86"
SRC_URI="https://download.jetbrains.com/idea/${MY_PN}IC-${MY_PV}.tar.gz -> ${MY_PN}IC-${PV_STRING}_20200602.tar.gz"

DESCRIPTION="A complete toolset for web, mobile and enterprise development"
HOMEPAGE="https://www.jetbrains.com/idea"

LICENSE="Apache-2.0 BSD BSD-2 CC0-1.0 CC-BY-2.5 CDDL-1.1
	codehaus-classworlds CPL-1.0 EPL-1.0 EPL-2.0 GPL-2
	GPL-2 GPL-2-with-classpath-exception ISC
	JDOM LGPL-2.1 LGPL-2.1+ LGPL-3-with-linking-exception MIT
	MPL-1.0 MPL-1.1 OFL ZLIB"

IUSE=""

DEPEND="!dev-util/${PN}:14
	!dev-util/${PN}:15"
RDEPEND="${DEPEND}
	>=virtual/jdk-1.7:*
	dev-java/jansi-native
	dev-libs/libdbusmenu
	dev-util/lldb"
BDEPEND="dev-util/patchelf"
RESTRICT="splitdebug"
S="${WORKDIR}/${MY_PN}-IC-$(ver_cut 4-6)"

QA_PREBUILT="opt/${PN}-${MY_PV}/*"

src_prepare() {
	rm -vf ${S}/jbr/lib/libavplugin*
	rm -vf "${S}"/plugins/maven/lib/maven3/lib/jansi-native/*/libjansi*
	rm -vrf "${S}"/lib/pty4j-native/linux/ppc64le
	rm -vf "${S}"/bin/libdbm64*

	if [[ -d "${S}"/"${JRE_DIR}" ]]; then
		for file in "${PLUGIN_DIR}"/{libfxplugins.so,libjfxmedia.so}
		do
			if [[ -f "$file" ]]; then
			  patchelf --set-rpath '$ORIGIN' $file || die
			fi
		done
	fi

	sed -i \
		-e "\$a\\\\" \
		-e "\$a#-----------------------------------------------------------------------" \
		-e "\$a# Disable automatic updates as these are handled through Gentoo's" \
		-e "\$a# package manager. See bug #704494" \
		-e "\$a#-----------------------------------------------------------------------" \
		-e "\$aide.no.platform.update=Gentoo"  bin/idea.properties

	eapply_user
}

src_install() {
	local dir="/opt/${PN}-${MY_PV}"

	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}"/bin/{format.sh,idea.sh,inspect.sh,printenv.py,restart.py,fsnotifier{,64}}
	JRE_DIR=jbr
	JRE_BINARIES="jaotc java javac jdb jfr jhsdb jjs jrunscript keytool pack200 rmid rmiregistry serialver unpack200"
	for jrebin in $JRE_BINARIES; do
		fperms 755 "${dir}"/"${JRE_DIR}"/bin/"${jrebin}"
	done

	make_wrapper "${PN}" "${dir}/bin/${MY_PN}.sh"
	newicon "bin/${MY_PN}.png" "${PN}.png"
	make_desktop_entry "${PN}" "IntelliJ Idea Community" "${PN}" "Development;IDE;"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	mkdir -p "${D}/etc/sysctl.d/" || die
	echo "fs.inotify.max_user_watches = 524288" > "${D}/etc/sysctl.d/30-idea-inotify-watches.conf" || die
}
