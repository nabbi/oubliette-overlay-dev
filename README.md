# Oubliette Development Gentoo Portage Overlay 
[![repoman](https://github.com/nabbi/oubliette-overlay-dev/actions/workflows/repoman.yml/badge.svg)](https://github.com/nabbi/oubliette-overlay-dev/actions/workflows/repoman.yml)
[![pkgcheck](https://github.com/nabbi/oubliette-overlay-dev/actions/workflows/pkgcheck.yml/badge.svg)](https://github.com/nabbi/oubliette-overlay-dev/actions/workflows/pkgcheck.yml)

This is my sandbox portage overlay for Gentoo Linux

Please consider using [oubliette-overlay](https://github.com/nabbi/oubliette-overlay) instead


To add the overlay:
```
sed -i "s/^#overlay_defs/overlay_defs/" /etc/layman/layman.cfg
wget https://raw.githubusercontent.com/nabbi/oubliette-overlay-dev/main/oubliette-dev.xml -O /etc/layman/overlays/oubliette-dev.xml
layman -S
layman -a oubliette-dev
```
