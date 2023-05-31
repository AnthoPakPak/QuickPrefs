#import "Tweak.h"
#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>

#ifndef SIMULATOR
HBPreferences *settingsPreferences;
#endif

@interface PSUIPrefsListController : PSListController
@property (nonatomic, strong, readwrite) UISearchController *spotlightSearchController;
@end

@interface PSURLManager
@property (nonatomic, strong, readwrite) PSUIPrefsListController *topLevelController;
+ (id)sharedManager;
@end

@interface UIScrollView (Private)
- (BOOL)_scrollToTopIfPossible:(BOOL)arg;
@end

%group Settings

%hook PreferencesAppController
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    BOOL result = %orig;

    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"quickPrefs.settingsAppDidFinishLaunching" object:nil userInfo:nil];

    return result;
}
%end //hook PreferencesAppController

%end //group Settings

void scrollToTop() {
    UITableView *tableView = MSHookIvar<UITableView*>([[%c(PSURLManager) sharedManager] topLevelController], "_table");
    [tableView _scrollToTopIfPossible:NO];
}

void goHome() {
    if ([[[%c(PSURLManager) sharedManager] topLevelController].spotlightSearchController.searchBar isFirstResponder]) {
        [[[%c(PSURLManager) sharedManager] topLevelController].spotlightSearchController.searchBar resignFirstResponder];
        [[[%c(PSURLManager) sharedManager] topLevelController].spotlightSearchController dismissViewControllerAnimated:NO completion:nil];
    }
    [[[%c(PSURLManager) sharedManager] topLevelController].navigationController popToRootViewControllerAnimated:NO];
    scrollToTop();
}

void search() {
    goHome();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        [[[%c(PSURLManager) sharedManager] topLevelController].spotlightSearchController.searchBar becomeFirstResponder];
        [[UIApplication sharedApplication] sendAction:@selector(selectAll:) to:nil from:nil forEvent:nil]; //when using this action, intention is to start a new search, so select all text
    });
}

void setupActionsListeners() {
    [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"quickPrefs.goGome" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        goHome();
    }];

    [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"quickPrefs.search" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        search();
    }];
}

static BOOL tweakShouldLoad() {
    // https://www.reddit.com/r/jailbreak/comments/4yz5v5/questionremote_messages_not_enabling/d6rlh88/
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
    NSUInteger count = args.count;
    if (count != 0) {
        NSString *executablePath = args[0];
        if (executablePath) {
            NSString *processName = [executablePath lastPathComponent];
            DLog(@"Processname : %@", processName);
            return [processName isEqualToString:@"Preferences"];
        }
    }

    return NO;
}

%ctor {
    if (!tweakShouldLoad()) {
        DLog(@"QuickPrefs Settings shouldn't run in this process");
        return;
    }

#ifndef SIMULATOR
    settingsPreferences = [[HBPreferences alloc] initWithIdentifier:@"com.anthopak.quickprefs"];
    // [settingsPreferences registerBool:&pathFinderEnabled default:NO forKey:@"pathFinderEnabled"];
#endif

    %init(Settings);

    setupActionsListeners();
}
