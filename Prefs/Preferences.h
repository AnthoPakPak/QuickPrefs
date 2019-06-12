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
#define pref_getValue(key) [[NSDictionary dictionaryWithContentsOfFile:PLIST_FILE] valueForKey:key]
#define pref_getBool(key) [pref_getValue(key) boolValue]
#define pref_setValueForKey(value, key) [@{key:value} writeToFile:PLIST_FILE atomically:YES]

@interface QPPrefsListController : HBRootListController<UITextFieldDelegate>
    - (void)respring:(id)sender;
@end