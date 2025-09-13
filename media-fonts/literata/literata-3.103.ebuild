EAPI=8

inherit font

GH_HASH="c8018e986708f2aed63c928b1e9026826da1553d"

DESCRIPTION="Literata fonts from Google Fonts"
HOMEPAGE="https://fonts.google.com/specimen/Literata"
SRC_URI="
	https://github.com/google/fonts/raw/$GH_HASH/ofl/literata/Literata%5Bopsz,wght%5D.ttf -> Literata-opsz-wght.ttf
	https://github.com/google/fonts/raw/$GH_HASH/ofl/literata/Literata-Italic%5Bopsz%2Cwght%5D.ttf -> Literata-Italic-opsz-wght.ttf
	"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}"

FONT_SUFFIX="ttf"
FONT_S="${DISTDIR}"
