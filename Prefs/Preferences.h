#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBRespringController.h>
#import <Cephei/HBPreferences.h>
#import "rootless.h"

#ifdef DEBUG
	#define DLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__);
#else
	#define DLog(...)
#endif

#define PLIST_FILE ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.anthopak.quickprefs.plist")
#define hb_prefs [[HBPreferences alloc] initWithIdentifier:@"com.anthopak.quickprefs"]
#define pref_setBoolForKey(bool, key) [hb_prefs setBool:bool forKey:key]
#define pref_getBool(key) [hb_prefs boolForKey:key]

@interface QPPrefsListController : HBRootListController<UITextFieldDelegate>

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) UIBarButtonItem *respringButton;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIImageView *headerImageView;

- (void)respring:(id)sender;

@end