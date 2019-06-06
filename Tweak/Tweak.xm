#import "Tweak.h"

#ifndef SIMULATOR
HBPreferences *preferences;
#endif

BOOL enabled;
NSString *item1;
NSString *item2;
NSString *item3;
NSString *item4;
BOOL quickPrefsItemsAboveStockItems;

NSMutableArray<NSString*> *itemsList;

%group QuickPrefs


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


%hook SBUIAppIconForceTouchControllerDataProvider

-(NSArray *)applicationShortcutItems {
    NSString *bundleId = [self applicationBundleIdentifier];
    if (![bundleId isEqualToString:@"com.apple.Preferences"]) return %orig;

    NSMutableArray *orig = [%orig mutableCopy];
    if (!orig) orig = [NSMutableArray new];

    DLog(@"itemsList %@", itemsList);

    for (NSString *itemName in itemsList) {
        SBSApplicationShortcutItem *item = [[%c(SBSApplicationShortcutItem) alloc] init];
        item.localizedTitle = itemName;
        item.bundleIdentifierToLaunch = bundleId;
        item.type = @"QuickPrefsItem";

        quickPrefsItemsAboveStockItems ? [orig addObject:item] : [orig insertObject:item atIndex:0];
    }

    return orig;
}

%end //hook SBUIAppIconForceTouchControllerDataProvider


%hook SBUIAppIconForceTouchController

-(void)appIconForceTouchShortcutViewController:(id)arg1 activateApplicationShortcutItem:(SBSApplicationShortcutItem *)item {
    if ([[item type] isEqualToString:@"QuickPrefsItem"]) {
        NSString *urlString = [NSString stringWithFormat:@"prefs:root=%@", item.localizedTitle];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        DLog(@"Should open %@", urlString);
        NSURL*url=[NSURL URLWithString:urlString];

        // if ([[UIApplication sharedApplication] canOpenURL:url]) { //unfortunately returns YES whatever the name is
            [[UIApplication sharedApplication] _openURL:url];
        // } else {
        //     showAlert(@"QuickPrefs cannot open this item. Please double check the name of the tweak and retry.");
        // }
    }

    %orig;
}

%end //hook SBUIAppIconForceTouchController


%hook SBUIAction

-(id)initWithTitle:(id)title subtitle:(id)arg2 image:(id)image badgeView:(id)arg4 handler:(/*^block*/id)arg5 {
    return %orig;
}

%end //hook SBUIAction

%end //end group QuickPrefs


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

        if (quickPrefsItemsAboveStockItems) itemsList = [[itemsList reverseObjectEnumerator] allObjects].mutableCopy;
    }

    DLog(@"new itemsList %@", itemsList);
}

%ctor {
    if (!tweakShouldLoad()) {
        DLog(@"QuickPrefs shouldn't run in this process");
        return;
    }

    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.anthopak.quickprefs"];
    [preferences registerBool:&enabled default:YES forKey:@"enabled"];
    [preferences registerObject:&item1 default:nil forKey:@"item1"];
    [preferences registerObject:&item2 default:nil forKey:@"item2"];
    [preferences registerObject:&item3 default:nil forKey:@"item3"];
    [preferences registerObject:&item4 default:nil forKey:@"item4"];
    [preferences registerBool:&quickPrefsItemsAboveStockItems default:NO forKey:@"quickPrefsItemsAboveStockItems"];

    reloadItemsList();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadItemsList, (CFStringRef)@"com.anthopak.quickprefs/ReloadPrefs", NULL, (CFNotificationSuspensionBehavior)kNilOptions);

    %init(QuickPrefs);
}
