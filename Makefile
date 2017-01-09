# STI-IT's very own Genode builds
#
# 

.PHONY: build-linux build-thinkpad prep-genode prep-linux prep-thinkpad realclean

# Run the Genode stack on Linux, for rapid development

# Possible values for BUILD_TYPE are the same as the first argument to
# tool/create_builddir, and can be seen with the following command:
# ls tool/builddir/etc/
build-linux: prep-linux
	@ [ -d $@ ] || $(MAKE) _$@ BUILD_TYPE=linux_x86
	make -C $@ run/demo 

# A hardware-targeted build that works (i.e., creates an ISO that boots)
# We'd like moar, see below
build-thinkpadOLD: prep-thinkpad
	@ [ -d $@ ] || $(MAKE) _$@ BUILD_TYPE=hw_x86_64
	make -C $@ run/demo

# WORK IN PROGRESS
# Objective is to run NOVA + VirtualBox on a ThinkPad T460s for the "day-to-day" use case
# (including wifi drivers)
build-thinkpad: prep-thinkpad
	@ [ -d $@ ] || $(MAKE) _$@ BUILD_TYPE=nova_x86_64
	make -C $@ run/demo GENODE_DIR=$(shell pwd)/genode

# https://genode.org/download/repository
prep-genode:
	@ [ -d genode ] || git clone git://github.com/genodelabs/genode.git

prep-linux: prep-genode _prepare_port-dde_linux _prepare_port-libc

# https://genode.org/documentation/release-notes/14.02#VirtualBox_on_top_of_the_NOVA_microhypervisor has obsolete instructions
# https://genode.org/documentation/platforms/nova aka repos/base-nova/doc/nova.txt seems more up-to-date
prep-thinkpad: _prepare_port-virtualbox _prepare_port-nova _prepare_port-x86emu

# Generic "private" rules invoked by one of the build-XXX entry points above
_build-%:
	genode/tool/create_builddir $(BUILD_TYPE) BUILD_DIR=build-$*
	@ rm -f build-$*/etc/build.conf
	$(MAKE) build-$*/etc/build.conf

_prepare_port-%:
	@ [ -d genode/contrib/$*-* ] || genode/tool/ports/prepare_port $*


build-%/etc/build.conf: build.conf.%
	cp $< $@

clean-%:
	rm -rf build-$*

realclean:
	rm -rf contrib/*
