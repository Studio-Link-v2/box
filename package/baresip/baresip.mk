#############################################################
#
# BARESIP
#
#############################################################

BARESIP_VERSION = master
BARESIP_SITE = $(call github,Studio-Link-v2,baresip,$(BARESIP_VERSION))
BARESIP_DEPENDENCIES = sljack2 libre librem zlib

BARESIP_MAKE_ENV = \
	$(TARGET_CONFIGURE_OPTS) \
	SYSROOT=$(STAGING_DIR)/usr \
	LD="$(TARGET_CC)" \
	LFLAGS="$(TARGET_LDFLAGS)"

BARESIP_MAKE_ARGS = \
	LIBRE_MK="$(STAGING_DIR)/usr/share/re/re.mk" \
	LIBRE_INC="$(STAGING_DIR)/usr/include/re" \
	LIBRE_SO="$(STAGING_DIR)/usr/lib" \
	LIBREM_MK="$(STAGING_DIR)/usr/share/rem/rem.mk" \
	LIBREM_INC="$(STAGING_DIR)/usr/include/rem" \
	LIBREM_SO="$(STAGING_DIR)/usr/lib"

ifeq ($(BR2_PACKAGE_ALSA_LIB),y)
BARESIP_DEPENDENCIES += alsa-lib
endif

ifeq ($(BR2_PACKAGE_FFMPEG_SWSCALE),y)
BARESIP_DEPENDENCIES += ffmpeg
BARESIP_MAKE_ENV += \
	CFLAGS+=-DCODEC_TYPE_VIDEO=AVMEDIA_TYPE_VIDEO
endif

ifeq ($(BR2_PACKAGE_LIBSNDFILE),y)
BARESIP_DEPENDENCIES += libsndfile
endif

ifeq ($(BR2_PACKAGE_SPEEX),y)
BARESIP_DEPENDENCIES += speex
endif

ifeq ($(BR2_PACKAGE_UTIL_LINUX_LIBUUID),y)
BARESIP_DEPENDENCIES += util-linux
endif

ifeq ($(BR2_PACKAGE_XORG7),y)
BARESIP_DEPENDENCIES += xlib_libXext
endif

define BARESIP_CONFIGURE_CMDS
	git clone https://github.com/Studio-Link-v2/backend $(@D)/backend
	cp -a $(@D)/backend/webapp $(@D)/modules/
	cp -a $(@D)/backend/gpio $(@D)/modules/
	cp -a $(@D)/../flac-1.3.1/include/share $(STAGING_DIR)/usr/include/
endef

define BARESIP_BUILD_CMDS
	$(BARESIP_MAKE_ENV) $(MAKE) $(BARESIP_MAKE_ARGS) STATIC=1 \
		MODULES="opus stdio ice g711 turn stun uuid auloop alsa webapp gpio" \
		-C $(@D) all
endef

define BARESIP_CLEAN_CMDS
	$(BARESIP_MAKE_ENV) $(MAKE) $(BARESIP_MAKE_ARGS) -C $(@D) clean
endef

define BARESIP_INSTALL_TARGET_CMDS       
	$(BARESIP_MAKE_ENV) DESTDIR=$(TARGET_DIR) $(MAKE) $(BARESIP_MAKE_ARGS) -C $(@D) install
endef

define BARESIP_UNINSTALL_TARGET_CMDS
	$(RM) $(TARGET_DIR)/usr/bin/baresip
	$(RM) -r $(TARGET_DIR)/usr/lib/baresip
	$(RM) -r $(TARGET_DIR)/usr/share/baresip
endef


define BARESIP_INSTALL_INIT_SYSV
$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_SL_BOX_PATH)/package/baresip/S50baresip \
	$(TARGET_DIR)/etc/init.d/S50baresip
$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_SL_BOX_PATH)/package/baresip/S20jackd \
	        $(TARGET_DIR)/etc/init.d/S20jackd
endef


$(eval $(generic-package))
$(eval $(host-generic-package))
