#import <Foundation/Foundation.h>


#ifdef DEBUG
	#define DLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__);
#else
	#define DLog(...)
#endif

#define PLIST_FILE @"/var/mobile/Library/Preferences/com.anthopak.easyopentweaksprefs.plist"
#define pref_getValue(key) [[NSDictionary dictionaryWithContentsOfFile:PLIST_FILE] valueForKey:key]
#define pref_getBool(key) [pref_getValue(key) boolValue]

@interface SBSApplicationShortcutItem : NSObject <NSCopying>

@property (nonatomic,copy) NSString * type;
@property (nonatomic,copy) NSString * localizedTitle;
@property (nonatomic,copy) NSString * localizedSubtitle;
@property (nonatomic,copy) NSString * bundleIdentifierToLaunch;

@end

@interface SBUIAppIconForceTouchControllerDataProvider : NSObject

-(NSString *)applicationBundleIdentifier;

@end 


@interface UIViewController (Custom)
-(void) becomeActiveNew;
-(void) openPrefsIfNeeded;
@end

@interface SpringBoard
-(void) deletePlistFile;
@end