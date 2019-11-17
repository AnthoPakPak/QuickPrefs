#import "Preferences.h"

@implementation QPPrefsListController

static void showAlert(NSString *myTitle, NSString *myMessage, UIViewController *presentingController) {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:myTitle message:myMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [presentingController presentViewController:alertController animated:YES completion:nil];
}

- (instancetype)init {
    self = [super init];

    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.49 green:0.498 blue:0.518 alpha:1];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];

    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    if ([self shouldShowNoticeForShuffle]) {
        showAlert(@"You're using shuffle tweak", @"I've noticed that you're using shuffle tweak. Don't worry, it's supported!\n\nTo make QuickPrefs work with it, you will have to set items names like this : \"Tweaks/QuickPrefs\". If you have changed the default name for Tweaks category, change accordingly.\n\nCool thing is that you can also create an item \"Tweaks\" that will allow you to directly reach your Tweaks section.", self);
    } else if ([self shouldShowNoticeForPreferenceOrganizer]) {
        showAlert(@"You're using PreferenceOrganizer2 tweak", @"I've noticed that you're using PreferenceOrganizer2 tweak. Don't worry, it's supported!\n\nTo make QuickPrefs work with it, you will have to set items names like this : \"Cydia/QuickPrefs\". If you have changed the default name for Cydia category, change accordingly.\n\nCool thing is that you can also create an item \"Cydia\" that will allow you to directly reach your Cydia section.", self);
    }
}

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Prefs" target:self] retain];
    }
    return _specifiers;
}

- (double)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return tableView.frame.size.width * (300.0f/800.0f); //image ratio
    } else {
        return [self tableView:tableView titleForHeaderInSection:section] ? 45 : 0;
    }
}

- (void)respring:(id)sender {
    [self.view endEditing:YES]; //ensure saving current UITextField value

    [HBRespringController respring];
}


#pragma mark - Notice alerts for shuffle & PreferencesOrganizer2

-(BOOL) shouldShowNoticeForShuffle {
    if (!pref_getBool(@"shuffleNoticeHasAlreadyBeShown") && [[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.creaturecoding.shuffle.list"]) {
        pref_setBoolForKey(YES, @"shuffleNoticeHasAlreadyBeShown");
        return YES;
    }
    return NO;
}

-(BOOL) shouldShowNoticeForPreferenceOrganizer {
    if (!pref_getBool(@"preferenceOrganizerNoticeHasAlreadyBeShown") && [[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/net.angelxwind.preferenceorganizer2.list"]) {
        pref_setBoolForKey(YES, @"preferenceOrganizerNoticeHasAlreadyBeShown");
        return YES;
    }
    return NO;
}

@end