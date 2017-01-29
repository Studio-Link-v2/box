#############################################################
#
# librem
#
#############################################################

LIBREM_VERSION = 0.4.7
LIBREM_SOURCE = rem-$(LIBREM_VERSION).tar.gz
LIBREM_SITE = http://www.creytiv.com/pub
LIBREM_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_LIBRE),y)
LIBREM_DEPENDENCIES += libre
endif

LIBREM_MAKE_ARGS = \
	LIBRE_MK="$(STAGING_DIR)/usr/share/re/re.mk" \
	LIBRE_INC="$(STAGING_DIR)/usr/include/re" \
	LIBRE_SO="$(STAGING_DIR)/usr/lib"

LIBREM_MAKE_ENV = \
	$(TARGET_CONFIGURE_OPTS) \
	SYSROOT=$(STAGING_DIR)/usr \
	LFLAGS="$(TARGET_LDFLAGS)"

define LIBREM_BUILD_CMDS
	$(LIBREM_MAKE_ENV) $(MAKE) $(LIBREM_MAKE_ARGS) -C $(@D) all
endef

define LIBREM_CLEAN_CMDS
	$(LIBREM_MAKE_ENV) $(MAKE) -C $(@D) clean
endef

define LIBREM_INSTALL_STAGING_CMDS
	$(LIBREM_MAKE_ENV) DESTDIR=$(STAGING_DIR) $(MAKE) $(LIBREM_MAKE_ARGS) -C $(@D) install
endef

define LIBREM_INSTALL_TARGET_CMDS
	$(INSTALL) -m 644 -D $(@D)/librem.so $(TARGET_DIR)/usr/lib/librem.so
endef

define LIBREM_UNINSTALL_STAGING_CMDS
	$(RM) -r $(STAGING_DIR)/usr/include/rem
	$(RM) $(STAGING_DIR)/usr/lib/librem.a
	$(RM) $(STAGING_DIR)/usr/lib/librem.so
endef

define LIBREM_UNINSTALL_TARGET_CMDS
	$(RM) $(TARGET_DIR)/usr/lib/librem.so
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
