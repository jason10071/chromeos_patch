# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit toolchain-funcs

DESCRIPTION="sis consoletool"
HOMEPAGE="https://github.com/jason10071/sisConsoletool"
SRC_URI="https://github.com/jason10071/sisConsoletool/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_install() {
	dosbin Linux/bin/getFirmwareId
	dosbin Linux/bin/updateFW
}
