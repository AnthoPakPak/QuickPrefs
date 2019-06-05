#import "Tweak.h"


%group QuickPrefs


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

%end //end group QuickPrefs


static BOOL tweakShouldLoad() {
    // https://www.reddit.com/r/jailbreak/comments/4yz5v5/questionremote_messages_not_enabling/d6rlh88/
    BOOL shouldLoad = NO;
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
    NSUInteger count = args.count;
    if (count != 0) {
        NSString *executablePath = args[0];
        if (executablePath) {
            NSString *processName = [executablePath lastPathComponent];
            DLog(@"Processname : %@", processName);
            // BOOL isApplication = [executablePath rangeOfString:@"/Application/"].location != NSNotFound || [executablePath rangeOfString:@"/Applications/"].location != NSNotFound;
            BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
            BOOL isFileProvider = [[processName lowercaseString] rangeOfString:@"fileprovider"].location != NSNotFound;
            BOOL skip = [processName isEqualToString:@"AdSheet"]
                        || [processName isEqualToString:@"CoreAuthUI"]
                        || [processName isEqualToString:@"InCallService"]
                        || [processName isEqualToString:@"MessagesNotificationViewService"]
                        || [processName isEqualToString:@"PassbookUIService"]
                        || [executablePath rangeOfString:@".appex/"].location != NSNotFound;
            if (!isFileProvider && isSpringBoard && !skip) {
                shouldLoad = YES;
            }
        }
    }

    return shouldLoad;
}

%ctor {
    if (!tweakShouldLoad()) {
        NSLog(@"QuickPrefs: shouldn't run in this process");
        return;
    }

    %init(QuickPrefs);
}
