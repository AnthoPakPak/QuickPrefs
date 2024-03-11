#export THEOS=/var/theos
export THEOS_DEVICE_IP=192.168.3.5
# export THEOS_DEVICE_PORT=22

#Rootful (uncomment following lines)
# PREFIX="/Users/antho/Documents/Programmation/iOSTweaks/Xcode11Toolchain/XcodeDefault.xctoolchain/usr/bin/"

#Rootless (uncomment following lines)
PREFIX="/Users/antho/Documents/Programmation/iOSTweaks/Xcode14Toolchain/XcodeDefault.xctoolchain/usr/bin/"
export THEOS_PACKAGE_SCHEME=rootless

# FINALPACKAGE=1
# export SIMULATOR=1
# USB=1

INSTALL_TARGET_PROCESSES = SpringBoard

ifeq ($(USB),1)
	export THEOS_DEVICE_IP=localhost
	export THEOS_DEVICE_PORT=2222
endif


include $(THEOS)/makefiles/common.mk

ifeq ($(FINALPACKAGE),1)
	SUBPROJECTS += Tweak Prefs
else ifeq ($(SIMULATOR),1)
	SUBPROJECTS = Tweak
else
	SUBPROJECTS += Tweak
	SUBPROJECTS += Prefs
endif

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
ifeq ($(RESPRING),1)
	# install.exec "killall SpringBoard"
	# install.exec "killall Preferences"
endif
	/Applications/OSDisplay.app/Contents/MacOS/OSDisplay -m 'Install success' -i 'tick' -d '1'