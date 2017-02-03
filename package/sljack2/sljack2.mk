################################################################################
#
# jack2
#
################################################################################

SLJACK2_VERSION = v1.9.10
SLJACK2_SITE = $(call github,jackaudio,jack2,$(SLJACK2_VERSION))
SLJACK2_LICENSE = GPLv2+ (jack server), LGPLv2.1+ (jack library)
SLJACK2_DEPENDENCIES = libsamplerate libsndfile alsa-lib host-python
SLJACK2_INSTALL_STAGING = YES

define SLJACK2_CONFIGURE_CMDS
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS)	\
		$(HOST_DIR)/usr/bin/python2 ./waf configure \
		--prefix=/usr			\
		--alsa				\
	)
endef

define SLJACK2_BUILD_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/python2 ./waf build -j $(PARALLEL_JOBS))
endef

define SLJACK2_INSTALL_TARGET_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/python2 ./waf --destdir=$(TARGET_DIR) \
		install)
endef

define SLJACK2_INSTALL_STAGING_CMDS
	(cd $(@D); $(HOST_DIR)/usr/bin/python2 ./waf --destdir=$(STAGING_DIR) \
		install)
endef

$(eval $(generic-package))
