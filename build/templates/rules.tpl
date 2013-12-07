#!/usr/bin/make -f

DEB_HOST_GNU_TYPE  ?= $(shell dpkg-architecture -qDEB_HOST_GNU_TYPE)
DEB_BUILD_GNU_TYPE ?= $(shell dpkg-architecture -qDEB_BUILD_GNU_TYPE)

clean:
	dh_testdir
	dh_testroot
	debian/clean.sh

config.status:
	dh_testdir
	debian/configure.sh

build: build-stamp
build-stamp: config.status
	dh_testdir
	debian/make.sh
	touch build-stamp

install: build
	dh_testdir
	dh_testroot
	dh_prep
	dh_installdirs
	debian/install.sh

binary-indep: build install

binary-arch: build install
	dh_testdir
	dh_testroot
	dh_installman
	dh_install --sourcedir=<%= $buildroot %>
	dh_link
	dh_strip
	dh_compress
	dh_fixperms
	dh_makeshlibs
	dh_installdeb
	dh_shlibdeps
	dh_gencontrol
	dh_md5sums
	dh_builddeb

binary: binary-indep binary-arch
.PHONY: build clean binary-indep binary-arch binary install configure
