# Oubliette Development Gentoo Portage Overlay 
[![repoman](https://github.com/nabbi/oubliette-overlay-dev/actions/workflows/repoman.yml/badge.svg)](https://github.com/nabbi/oubliette-overlay-dev/actions/workflows/repoman.yml)
[![pkgcheck](https://github.com/nabbi/oubliette-overlay-dev/actions/workflows/pkgcheck.yml/badge.svg)](https://github.com/nabbi/oubliette-overlay-dev/actions/workflows/pkgcheck.yml)

This is my development portage overlay for sandboxing Gentoo Linux ebuilds

Please consider using [oubliette-overlay](https://github.com/nabbi/oubliette-overlay) instead as packages found in dev are experimental


This repo is not in gentoo's overlay indexs.

To add the overlay for app-portage/layman:
```
sed -i "s/^#overlay_defs/overlay_defs/" /etc/layman/layman.cfg
wget https://raw.githubusercontent.com/nabbi/oubliette-overlay-dev/main/oubliette-dev.xml -O /etc/layman/overlays/oubliette-dev.xml
layman -S
layman -a oubliette-dev
```

To add the overlay similar to app-eselect/eselect-repository:
```
cat <<EOF >> /etc/portage/repos.conf/eselect-repo.conf

[oubliette-dev]
location = /var/db/repos/oubliette-dev
sync-type = git
sync-uri = https://github.com/nabbi/oubliette-overlay-dev
EOF
emaint sync -a
```
