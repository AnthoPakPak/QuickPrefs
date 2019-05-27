#export THEOS=/var/theos
# export THEOS_DEVICE_IP=192.168.0.20 THEOS_DEVICE_PORT=22
#export THEOS_DEVICE_IP=172.20.10.1 THEOS_DEVICE_PORT=22
export THEOS_DEVICE_IP=192.168.1.133 THEOS_DEVICE_PORT=22

#FINALPACKAGE=1
include $(THEOS)/makefiles/common.mk

SUBPROJECTS += Tweak

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
ifeq ($(RESPRING),1)
	install.exec "killall SpringBoard"
	
	# install.exec "killall MobileSafari"
	# install.exec "open com.apple.mobilesafari"

	# install.exec "killall Facebook"
	# install.exec "open com.facebook.Facebook"

	#install.exec "killall YouTube"
	#install.exec "open com.google.ios.youtube"

endif
	/Applications/OSDisplay.app/Contents/MacOS/OSDisplay -m 'Install success' -i 'tick' -d '1'