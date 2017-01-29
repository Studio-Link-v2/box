#############################################################
#
# libre
#
#############################################################

LIBRE_VERSION = 0.5.0
LIBRE_SOURCE = re-$(LIBRE_VERSION).tar.gz
LIBRE_SITE = http://www.creytiv.com/pub
LIBRE_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_OPENSSL),y)
LIBRE_DEPENDENCIES += openssl
endif
ifeq ($(BR2_PACKAGE_ZLIB),y)
LIBRE_DEPENDENCIES += zlib
endif

LIBRE_MAKE_ENV = \
	$(TARGET_CONFIGURE_OPTS) \
	SYSROOT=$(STAGING_DIR)/usr \
	LFLAGS="$(TARGET_LDFLAGS)"

define LIBRE_BUILD_CMDS
	$(LIBRE_MAKE_ENV) $(MAKE) -C $(@D) all
endef

define LIBRE_CLEAN_CMDS
	$(LIBRE_MAKE_ENV) $(MAKE) -C $(@D) clean
endef

define LIBRE_INSTALL_STAGING_CMDS
	$(LIBRE_MAKE_ENV) DESTDIR=$(STAGING_DIR) $(MAKE) -C $(@D) install
endef

define LIBRE_INSTALL_TARGET_CMDS
	$(INSTALL) -m 644 -D $(@D)/libre.so $(TARGET_DIR)/usr/lib/libre.so
endef

define LIBRE_UNINSTALL_STAGING_CMDS
	$(RM) -r $(STAGING_DIR)/usr/include/re
	$(RM) $(STAGING_DIR)/usr/lib/libre.a
	$(RM) $(STAGING_DIR)/usr/lib/libre.so
endef

define LIBRE_UNINSTALL_TARGET_CMDS
	$(RM) $(TARGET_DIR)/usr/lib/libre.so
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
