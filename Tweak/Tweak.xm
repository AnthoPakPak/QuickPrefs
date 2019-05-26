#import "Tweak.h"


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
        item.bundleIdentifierToLaunch = bundleId;
        item.type = @"OpenPrefsItem";
        [orig insertObject:item atIndex:0];
    }

    return orig;
}

%end //hook SBUIAppIconForceTouchControllerDataProvider

%hook SBUIAppIconForceTouchController

-(void)appIconForceTouchShortcutViewController:(id)arg1 activateApplicationShortcutItem:(SBSApplicationShortcutItem *)item {
    if ([[item type] isEqualToString:@"OpenPrefsItem"]) {
        NSString *urlString = [NSString stringWithFormat:@"prefs:root=%@", item.localizedTitle];
        DLog(@"Should open %@", urlString);
        NSURL*url=[NSURL URLWithString:urlString];

        [[UIApplication sharedApplication] _openURL:url];
    }

    %orig;
}

%end //hook SBUIAppIconForceTouchController


%hook SBUIAction

-(id)initWithTitle:(id)title subtitle:(id)arg2 image:(id)image badgeView:(id)arg4 handler:(/*^block*/id)arg5 {
    // if ([title isEqualToString:@"TweakName"]) {
    //     image = [[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/Tweak.bundle/forcetouch.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    // }

    return %orig;
}

%end //hook SBUIAction

%end //end group EasyOpenTweakPrefs


%ctor {
    %init(EasyOpenTweakPrefs);
}
