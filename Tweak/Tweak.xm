#import "Tweak.h"

#ifndef SIMULATOR
HBPreferences *preferences;
#endif

BOOL enabled;
NSString *item1;
NSString *item2;
NSString *item3;
NSString *item4;
NSString *item5;
NSString *item6;
NSString *item7;
NSString *item8;
BOOL quickPrefsItemsAboveStockItems;
BOOL removeStockItems;

NSMutableArray<NSString*> *itemsList;


// static UIViewController* topMostController() {
//     UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
//     while (topController.presentedViewController) {
//         topController = topController.presentedViewController;
//     }
    
//     return topController;
// }

// static void showAlert(NSString *myMessage) {
//     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:myMessage preferredStyle:UIAlertControllerStyleAlert];
//     [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
//     [topMostController() presentViewController:alertController animated:YES completion:nil];
// }

static void respring() {
    NSTask *t = [NSTask new];
    [t setLaunchPath:@"/usr/bin/killall"];
    [t setArguments:@[@"backboardd"]];
    [t launch];
}

static void safeMode() {
    NSTask *t = [NSTask new];
    [t setLaunchPath:@"/usr/bin/killall"];
    [t setArguments:@[@"-SEGV", @"SpringBoard"]];
    [t launch];
}

static void uicache() {
    NSTask *t = [NSTask new];
    [t setLaunchPath:@"/usr/bin/uicache"];
    [t launch];
}

static NSString* getPrefsUrlStringFromPathString(NSString* pathString) {
    NSArray *urlPathItems = [pathString componentsSeparatedByString:@"/"];

    NSString *urlString = [NSString stringWithFormat:@"prefs:root=%@", urlPathItems[0]];

    if (urlPathItems.count > 1) {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&path=%@", urlPathItems[1]]];

        if (urlPathItems.count > 2) {
            urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"/%@", urlPathItems[2]]];
        }
    }

    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];

    return urlString;
}

static NSArray<SBSApplicationShortcutItem*>* addItemsToStockItems(NSArray<SBSApplicationShortcutItem*>* stockItems) {
    NSMutableArray *stockAndCustomItems = removeStockItems ? @[].mutableCopy : [stockItems mutableCopy];
    if (!stockAndCustomItems) stockAndCustomItems = [NSMutableArray new];

    DLog(@"itemsList %@", itemsList);

    for (NSString *itemName in itemsList) {
        SBSApplicationShortcutItem *item = [[%c(SBSApplicationShortcutItem) alloc] init];
        item.localizedTitle = itemName;
        item.bundleIdentifierToLaunch = @"com.apple.Preferences";
        item.type = @"QuickPrefsItem";

        quickPrefsItemsAboveStockItems ? [stockAndCustomItems addObject:item] : [stockAndCustomItems insertObject:item atIndex:0];
    }
    return stockAndCustomItems;
}

static void activateQuickPrefsAction(SBSApplicationShortcutItem* item) {
    if ([item.localizedTitle.lowercaseString isEqualToString:@"respring"]) {
        respring();
    } else if ([item.localizedTitle.lowercaseString isEqualToString:@"safe mode"]) {
        safeMode();
    } else if ([item.localizedTitle.lowercaseString isEqualToString:@"uicache"]) {
        uicache();
    } else { //open pref pane
        NSString *urlString = getPrefsUrlStringFromPathString(item.localizedTitle);
        DLog(@"Should open %@", urlString);

        NSURL*url = [NSURL URLWithString:urlString];

        // if ([[UIApplication sharedApplication] canOpenURL:url]) { //unfortunately returns YES whatever the name is
            [[UIApplication sharedApplication] _openURL:url];
        // } else {
        //     showAlert(@"QuickPrefs cannot open this item. Please double check the name of the tweak and retry.");
        // }
    }
}

static NSString* getReadableTitleFromPathString(NSString *pathString) {
    NSString *title = pathString;

    //handle strings containing path
    if ([title containsString:@"/"]) {
        NSArray *urlPathItems = [title componentsSeparatedByString:@"/"];
        title = urlPathItems[urlPathItems.count - 1];
    }

    //handle strings like BATTERY_USAGE
    if ([title containsString:@"_"]) {
        title = [title stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    }

    BOOL isAllUppercase = [title rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]].location == NSNotFound;
    if (isAllUppercase) {
        title = [title capitalizedString];
    }

    return title;
}


%group iOS11_12

%hook SBUIAppIconForceTouchControllerDataProvider

-(NSArray *)applicationShortcutItems {
    NSString *bundleId = [self applicationBundleIdentifier];
    if (![bundleId isEqualToString:@"com.apple.Preferences"]) return %orig;

    NSArray<SBSApplicationShortcutItem*> *stockAndCustomItems = addItemsToStockItems(%orig);
    return stockAndCustomItems;
}

%end //hook SBUIAppIconForceTouchControllerDataProvider


%hook SBUIAppIconForceTouchController

-(void)appIconForceTouchShortcutViewController:(id)arg1 activateApplicationShortcutItem:(SBSApplicationShortcutItem *)item {
    if ([[item type] isEqualToString:@"QuickPrefsItem"]) {
        activateQuickPrefsAction(item);
    }

    %orig;
}

%end //hook SBUIAppIconForceTouchController


%hook SBUIAction

-(id)initWithTitle:(id)title subtitle:(id)arg2 image:(id)image badgeView:(id)arg4 handler:(/*^block*/id)arg5 {
    title = getReadableTitleFromPathString(title);

    return %orig;
}

%end //hook SBUIAction

%end //end group iOS11_12


%group iOS13_up

%hook SBIconView

-(NSArray *)applicationShortcutItems {
    NSString *bundleId;
    if ([self respondsToSelector:@selector(applicationBundleIdentifier)]) {
        bundleId = [self applicationBundleIdentifier]; //iOS 13.1.3 (limneos)
    } else if ([self respondsToSelector:@selector(applicationBundleIdentifierForShortcuts)]) {
        bundleId = [self applicationBundleIdentifierForShortcuts]; //iOS 13.2.2 (my test iPhone)
    }
    if (![bundleId isEqualToString:@"com.apple.Preferences"]) return %orig;

    NSArray<SBSApplicationShortcutItem*> *stockAndCustomItems = addItemsToStockItems(%orig);
    return stockAndCustomItems;
}

+(void)activateShortcut:(SBSApplicationShortcutItem*)item withBundleIdentifier:(id)arg2 forIconView:(id)arg3 {
    DLog(@"activateShortcut %@ | %@ | %@", item, arg2, arg3);
    if ([[item type] isEqualToString:@"QuickPrefsItem"]) {
        activateQuickPrefsAction(item);
    }

    %orig;
}

%end //hook SBIconView


%hook _UIContextMenuActionView

-(id)initWithTitle:(id)title subtitle:(id)arg2 image:(id)arg3 {
    title = getReadableTitleFromPathString(title);

    return %orig;
}

%end //hook SBUIAction

%end //end group iOS13_up


static BOOL tweakShouldLoad() {
    // https://www.reddit.com/r/jailbreak/comments/4yz5v5/questionremote_messages_not_enabling/d6rlh88/
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
    NSUInteger count = args.count;
    if (count != 0) {
        NSString *executablePath = args[0];
        if (executablePath) {
            NSString *processName = [executablePath lastPathComponent];
            DLog(@"Processname : %@", processName);
            return [processName isEqualToString:@"SpringBoard"];
        }
    }

    return NO;
}

static void addItemToItemsListIfNotNil(NSString *itemName) {
    NSString *trimmedItemName = [itemName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([trimmedItemName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        [itemsList addObject:trimmedItemName];
    }
}

static void reloadItemsList() {
    DLog(@"reloadItemsList");
    itemsList = @[].mutableCopy;
    if (enabled) {
        addItemToItemsListIfNotNil(item1);
        addItemToItemsListIfNotNil(item2);
        addItemToItemsListIfNotNil(item3);
        addItemToItemsListIfNotNil(item4);
        addItemToItemsListIfNotNil(item5);
        addItemToItemsListIfNotNil(item6);
        addItemToItemsListIfNotNil(item7);
        addItemToItemsListIfNotNil(item8);

        if (quickPrefsItemsAboveStockItems) itemsList = [[itemsList reverseObjectEnumerator] allObjects].mutableCopy;
    }

    DLog(@"new itemsList %@", itemsList);
}

%ctor {
    if (!tweakShouldLoad()) {
        DLog(@"QuickPrefs shouldn't run in this process");
        return;
    }

#ifndef SIMULATOR
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.anthopak.quickprefs"];
    [preferences registerBool:&enabled default:YES forKey:@"enabled"];
    [preferences registerObject:&item1 default:nil forKey:@"item1"];
    [preferences registerObject:&item2 default:nil forKey:@"item2"];
    [preferences registerObject:&item3 default:nil forKey:@"item3"];
    [preferences registerObject:&item4 default:nil forKey:@"item4"];
    [preferences registerObject:&item5 default:nil forKey:@"item5"];
    [preferences registerObject:&item6 default:nil forKey:@"item6"];
    [preferences registerObject:&item7 default:nil forKey:@"item7"];
    [preferences registerObject:&item8 default:nil forKey:@"item8"];
    [preferences registerBool:&quickPrefsItemsAboveStockItems default:NO forKey:@"quickPrefsItemsAboveStockItems"];
    [preferences registerBool:&removeStockItems default:NO forKey:@"removeStockItems"];

    reloadItemsList();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadItemsList, (CFStringRef)@"com.anthopak.quickprefs/ReloadPrefs", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
#else
    enabled = YES;
    item1 = @"Test";
    reloadItemsList();
#endif

    if (IS_IOS13_AND_UP) {
        %init(iOS13_up);
    } else {
        %init(iOS11_12);
    }
}
