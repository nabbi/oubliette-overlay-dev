# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit perl-functions readme.gentoo-r1 cmake flag-o-matic systemd webapp

MY_PN="ZoneMinder"
MY_CRUD_V="0bd63fb464957080ead342db58ca9e01532cf1ef"
MY_CAKEPHP_V="ea90c0cd7f6e24333a90885e563b5d30b793db29"
MY_RTSP_V="eab32851421ffe54fec0229c3efc44c642bc8d46"

DESCRIPTION="full-featured, open source, state-of-the-art video surveillance software system"
HOMEPAGE="http://www.zoneminder.com/"

MY_PV_P=$(ver_cut 3-)
if [[ ${PV} == 9999 || ${MY_PV_P} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ZoneMinder/zoneminder"
	EGIT_BRANCH="release-1.36"
else
	SRC_URI="
		https://github.com/${MY_PN}/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz
		https://github.com/FriendsOfCake/crud/archive/${MY_CRUD_V}.tar.gz -> Crud-${MY_CRUD_V}.gh.tar.gz
		https://github.com/ZoneMinder/CakePHP-Enum-Behavior/archive/${MY_CAKEPHP_V}.tar.gz \
			-> CakePHP-Enum-Behavior-${MY_CAKEPHP_V}.gh.tar.gz
		https://github.com/ZoneMinder/RtspServer/archive/${MY_RTSP_V}.tar.gz -> RtspServer-${MY_RTSP_V}.gh.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-2"
IUSE="+apache2 curl encode gcrypt gnutls lighttpd nginx +mmap +ssl vlc"
SLOT="0"
REQUIRED_USE="
	|| ( ssl gnutls )
"

DEPEND="
apache2? (
	app-eselect/eselect-php[apache2]
	dev-lang/php:*[apache2,cgi,curl,gd,inifile,intl,pdo,mysql,mysqli,sockets,sysvipc]
	www-servers/apache
)
lighttpd? (
	www-servers/lighttpd
)
nginx? (
	www-servers/nginx
)
dev-lang/perl:=
dev-libs/libpcre
dev-perl/Archive-Zip
dev-perl/Class-Std-Fast
dev-perl/Data-Dump
dev-perl/Date-Manip
dev-perl/Data-UUID
dev-perl/DBD-mysql
dev-perl/DBI
dev-perl/IO-Socket-Multicast
dev-perl/SOAP-WSDL
dev-perl/Sys-CPU
dev-perl/Sys-MemInfo
dev-perl/URI-Encode
dev-perl/libwww-perl
dev-perl/Number-Bytes-Human
dev-perl/JSON-MaybeXS
dev-perl/Crypt-Eksblowfish
dev-perl/Data-Entropy
dev-perl/HTTP-Lite
dev-perl/MIME-Lite
dev-perl/MIME-tools
dev-perl/X10
dev-perl/DateTime
dev-perl/Device-SerialPort
dev-php/pecl-apcu:*
sys-auth/polkit
sys-libs/zlib
media-video/ffmpeg[x264,x265,jpeg2k]
encode? ( media-libs/libmp4v2 )
virtual/httpd-php:*
media-libs/openjpeg
virtual/perl-ExtUtils-MakeMaker
virtual/perl-Getopt-Long
virtual/perl-Sys-Syslog
virtual/perl-Time-HiRes
curl? ( net-misc/curl )
gcrypt? ( dev-libs/libgcrypt:0= )
gnutls? ( net-libs/gnutls )
mmap? ( dev-perl/Sys-Mmap )
ssl? ( dev-libs/openssl:0= )
vlc? ( media-video/vlc[live] )
"
RDEPEND="${DEPEND}"

need_httpd

MY_ZM_WEBDIR=/usr/share/zoneminder/www

src_prepare() {
	cmake_src_prepare

	rm "${WORKDIR}/${P}/conf.d/README" || die

	if [[ ${PV} == 9999 || ${MY_PV_P} == 9999 ]]; then
		return
	else
		rmdir "${S}/web/api/app/Plugin/Crud" || die
		mv "${WORKDIR}/crud-${MY_CRUD_V}" "${S}/web/api/app/Plugin/Crud" || die

		rmdir "${S}/web/api/app/Plugin/CakePHP-Enum-Behavior" || die
		mv "${WORKDIR}/CakePHP-Enum-Behavior-${MY_CAKEPHP_V}" "${S}/web/api/app/Plugin/CakePHP-Enum-Behavior" || die

		rmdir "${S}/dep/RtspServer" || die
		mv "${WORKDIR}/RtspServer-${MY_RTSP_V}" "${S}/dep/RtspServer" || die
	fi
}

src_configure() {
	use apache2 && local web="apache"
	use lighttpd && local web="lighttpd"
	use nginx && local web="nginx"

	append-cxxflags -D__STDC_CONSTANT_MACROS
	perl_set_version
	export TZ=UTC # bug 630470
	mycmakeargs=(
		-DZM_TMPDIR=/var/tmp/zm
		-DZM_SOCKDIR=/var/run/zm
		-DZM_PATH_ZMS="/zm/cgi-bin/nph-zms"
		-DZM_CONFIG_DIR="/etc/zm"
		-DZM_CONFIG_SUBDIR="/etc/zm/conf.d"
		-DZM_WEB_USER=${web}
		-DZM_WEB_GROUP=${web}
		-DZM_WEBDIR=${MY_ZM_WEBDIR}
		-DZM_NO_MMAP="$(usex mmap OFF ON)"
		-DZM_NO_X10=OFF
		-DZM_NO_CURL="$(usex curl OFF ON)"
		-DZM_NO_LIBVLC="$(usex vlc OFF ON)"
		-DCMAKE_DISABLE_FIND_PACKAGE_OpenSSL="$(usex ssl OFF ON)"
		-DHAVE_LIBGNUTLS="$(usex gnutls ON OFF)"
		-DHAVE_LIBGCRYPT="$(usex gcrypt ON OFF)"
	)

	cmake_src_configure

}

src_install() {
	use apache2 && local web="apache"
	use lighttpd && local web="lighttpd"
	use nginx && local web="nginx"

	cmake_src_install

	docompress -x /usr/share/man

	# the log directory
	keepdir /var/log/zm
	fowners ${web}:${web} /var/log/zm

	# the logrotate script
	insinto /etc/logrotate.d
	newins distros/ubuntu2004/zoneminder.logrotate zoneminder

	# now we duplicate the work of zmlinkcontent.sh
	keepdir /var/lib/zoneminder /var/lib/zoneminder/images /var/lib/zoneminder/events /var/lib/zoneminder/api_tmp
	fperms -R 0775 /var/lib/zoneminder
	fowners -R ${web}:${web} /var/lib/zoneminder
	dosym ../../../../../../var/lib/zoneminder/api_tmp ${MY_ZM_WEBDIR}/api/app/tmp

	# bug 523058
	keepdir ${MY_ZM_WEBDIR}/temp
	fowners -R ${web}:${web} ${MY_ZM_WEBDIR}/temp

	# the configuration file
	fperms 0640 /etc/zm/zm.conf
	fowners root:${web} /etc/zm/zm.conf

	# init scripts etc
	newinitd "${FILESDIR}"/init.d-r1 zoneminder
	newconfd "${FILESDIR}"/conf.d zoneminder

	# systemd unit file
	systemd_dounit "${FILESDIR}"/zoneminder.service

	if use apache2 ; then
		# apache2 conf file
		cp "${FILESDIR}"/10_zoneminder.conf "${T}"/10_zoneminder.conf || die
		sed -i "${T}"/10_zoneminder.conf -e "s:%ZM_WEBDIR%:${MY_HTDOCSDIR}:g" || die
		insinto /etc/apache2/vhosts.d
		newins "${T}"/10_zoneminder.conf 10_zoneminder.include

		dodoc "${T}"/10_zoneminder.conf
	fi

	dodoc CHANGELOG.md CONTRIBUTING.md README.md

	perl_delete_packlist

	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog

	if [[ -z "${REPLACING_VERSIONS}" ]]; then
			elog "Fresh installs of zoneminder require a few additional steps. Please read the README.gentoo"
	else
		local v
		for v in ${REPLACING_VERSIONS}; do
			if ver_test ${PV} -gt ${v}; then
				elog "You have upgraded zoneminder and may have to upgrade your database now using the 'zmupdate.pl' script."
			fi
		done
	fi

	# 2022-02-10 The original ebuild omitted ZM_CONFIG_* at build time
	# Check if user needs to migrate configs from /etc to /etc/zm
	local legacy="/etc/zm.conf /etc/conf.d/01-system-paths.conf /etc/conf.d/02-multiserver.conf /etc/conf.d/zmcustom.conf"
	local lf
	local lfwarn=0
	for lf in ${legacy}; do
		if [[ -f "${lf}" ]]; then
			ewarn "Found deprecated ZoneMinder config ${lf}"
			lfwarn=1
		fi
	done
	if [ ${lfwarn} -ne 0 ]; then
		ewarn ""
		ewarn "Gentoo's ebuild previously installed ZoneMinder's configurations directly into /etc"
		ewarn "This conflicts with OpenRC /etc/conf.d as ZoneMinder also has its own conf.d subdirectory"
		ewarn "Your newly compiled ZoneMinder now looks for configurations under /etc/zm"
		ewarn ""
		ewarn "    Please merge your local changes into /etc/zm/conf.d/99-local.conf"
		ewarn "    This includes any user created *.conf files for ZM within /etc/conf.d/"
		ewarn "    Then remove those old files to complete the migration."
		ewarn ""
		elog ""
		elog "Remember to set appropriate permisions on user created files (i.e. /etc/zm/conf.d/*.conf):"
		elog "    chmod 640 local.conf"
		elog "    chown root:web local.conf"
		elog ""
		ewarn ""
		ewarn "ZoneMinder will **NO LONGER FUNCTION UNTIL** these configuration items have been migrated!"
		ewarn "In particular, ensuring the database hostname and credentials are defined within the new locations."
		ewarn ""
	fi
}
