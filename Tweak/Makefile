
#ARCHS = arm64 arm64e

#TARGET = simulator:clang:latest:7.0
#ARCHS = x86_64 i386

GO_EASY_ON_ME = 1;

ifeq ($(SIMULATOR),1)
ARCHS = x86_64
TARGET = simulator:clang:latest:7.0
else
ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.0
endif


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = EasyOpenTweakPrefs
$(TWEAK_NAME)_FILES = Tweak.xm


ifeq ($(SIMULATOR),1)
ADDITIONAL_OBJCFLAGS = -fobjc-arc -DSIMULATOR=1
else
ADDITIONAL_OBJCFLAGS = -fobjc-arc
endif



include $(THEOS_MAKE_PATH)/tweak.mk


after-all::
	/Applications/OSDisplay.app/Contents/MacOS/OSDisplay -m 'Build success' -i 'tick' -d '1'
ifeq ($(SIMULATOR),1)
	rm /opt/simject/$(TWEAK_NAME).dylib
	cp ~/Documents/Programmation/iOSTweaks/tweaks/EasyOpenTweakPrefs/.theos/obj/iphone_simulator/debug/$(TWEAK_NAME).dylib /opt/simject/
	~/Documents/Programmation/iOSTweaks/simject/bin/respring_simulator
endif
