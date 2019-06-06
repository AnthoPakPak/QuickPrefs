#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBRespringController.h>
#import <Cephei/HBPreferences.h>

#ifdef DEBUG
	#define DLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__);
#else
	#define DLog(...)
#endif

#define PLIST_FILE @"/var/mobile/Library/Preferences/com.anthopak.quickprefs.plist"



@interface QPPrefsListController : HBRootListController<UITextFieldDelegate>
// - (void)applySettings:(id)sender;
    - (void)respring:(id)sender;
@end