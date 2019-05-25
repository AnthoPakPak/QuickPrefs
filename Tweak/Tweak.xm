#import "Tweak.h"

BOOL hasToOpenPrefs;
NSString *prefsNameToOpen;

static NSString *myObserver=@"easyopentweakprefs.observer";

%group EasyOpenTweakPrefs





%hook SBUIAppIconForceTouchControllerDataProvider

-(NSArray *)applicationShortcutItems {
    NSString *bundleId = [self applicationBundleIdentifier];
    if (![bundleId isEqualToString:@"com.apple.Preferences"]) return %orig;

    NSMutableArray *orig = [%orig mutableCopy];
    if (!orig) orig = [NSMutableArray new];

    NSArray<NSString*> *itemsList = @[@"VideoSwipes", @"Sleepizy", @"PanCake"];

    for (NSString *itemName in itemsList) {
        SBSApplicationShortcutItem *item = [[%c(SBSApplicationShortcutItem) alloc] init];
        item.localizedTitle = itemName;
        // item.bundleIdentifierToLaunch = bundleId;
        item.bundleIdentifierToLaunch = @"com.apple.mobilemail";
        item.type = @"OpenPrefsItem";
        [orig insertObject:item atIndex:0];
    }

    return orig;
}

%end

%hook SBUIAppIconForceTouchController
-(void)appIconForceTouchShortcutViewController:(id)arg1 activateApplicationShortcutItem:(SBSApplicationShortcutItem *)item {
    if ([[item type] isEqualToString:@"OpenPrefsItem"]) {
        // hasToOpenPrefs = YES;
        // prefsNameToOpen = item.localizedTitle;

        NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
        [plistDict setValue:@"YES" forKey:@"hasToOpenPrefs"];
        [plistDict setValue:item.localizedTitle forKey:@"prefsNameToOpen"];
        [plistDict writeToFile:PLIST_FILE atomically:NO];

        // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        //     NSString *urlString = [NSString stringWithFormat:@"prefs:root=%@", item.localizedTitle];
        //     DLog(@"Should open %@", urlString);
        //     NSURL*url=[NSURL URLWithString:urlString];
        //     [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        // });
    }

    %orig;
}

%end

%hook SBUIAction

-(id)initWithTitle:(id)title subtitle:(id)arg2 image:(id)image badgeView:(id)arg4 handler:(/*^block*/id)arg5 {
    // if ([title isEqualToString:@"UnSub"]) {
    //     image = [[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/UnSubPrefs.bundle/forcetouch.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    // }

    return %orig;
}

%end

%hook SpringBoard

static void deletePlistFile(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
    DLog(@"Receiving notif");

    NSError *error;
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:PLIST_FILE]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:PLIST_FILE error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
}

-(void)applicationDidFinishLaunching:(id)application {
    %orig;
    
    DLog(@"Registering notif");
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (void*)myObserver,
                                    deletePlistFile,
                                    CFSTR("easyopentweakprefs.deletePlistFile"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

-(void)dealloc {
    %orig;
    CFNotificationCenterRemoveObserver (CFNotificationCenterGetDarwinNotifyCenter(), (void*)myObserver, NULL, NULL);    
}

%end


%end //end group EasyOpenTweakPrefs


%group Mail

%hook UIViewController

BOOL observerAdded;

-(void) viewDidLoad {
    %orig;

    if (!observerAdded) {
        observerAdded = YES;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [self openPrefsIfNeeded];          
        });

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActiveNew) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

%new
-(void) becomeActiveNew {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        [self openPrefsIfNeeded];          
    });
}

%new
-(void) openPrefsIfNeeded {
    if (pref_getBool(@"hasToOpenPrefs")) {
        NSString *prefsNameToOpen = pref_getValue(@"prefsNameToOpen");

        DLog(@"hasToOpenPrefs %@", prefsNameToOpen);

        NSURL*url=[NSURL URLWithString:[NSString stringWithFormat:@"prefs:root=%@", prefsNameToOpen]];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];

        DLog(@"Sending notif");
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("easyopentweakprefs.deletePlistFile"), (void*)myObserver, NULL, true);
    }
}

%end //end hook UIViewController



%end //group Mail



%ctor {
    %init(EasyOpenTweakPrefs);

    NSString *appName = [[NSBundle mainBundle] bundleIdentifier];
    if ([appName isEqualToString:@"com.apple.mobilemail"]) { //the only way I found for a working openUrl with prefs:root
        %init(Mail);
    }
}
