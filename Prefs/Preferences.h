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
#define hb_prefs [[HBPreferences alloc] initWithIdentifier:@"com.anthopak.quickprefs"]
#define pref_setBoolForKey(bool, key) [hb_prefs setBool:bool forKey:key]
#define pref_getBool(key) [hb_prefs boolForKey:key]

@interface QPPrefsListController : HBRootListController<UITextFieldDelegate>
    - (void)respring:(id)sender;
@end