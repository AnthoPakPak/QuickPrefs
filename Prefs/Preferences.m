#import "Preferences.h"

#define prefPath ROOT_PATH_NS_VAR(([NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.anthopak.quickprefs.plist"]))
#define prefsTintColor [UIColor colorWithRed:0.49 green:0.498 blue:0.518 alpha:1]

static NSInteger headerPaddingTopBottom = 40;
static NSInteger headerPaddingLeftRight = 10;

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
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
        appearanceSettings.tintColor = prefsTintColor;
        self.hb_appearanceSettings = appearanceSettings;

        [self setupNavigationTitleView];
        [self setupNavigationRespringButton];
    }

    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];

    [self setupHeaderView];

    if ([self shouldShowNoticeForShuffle]) {
        showAlert(@"You're using shuffle tweak", @"I've noticed that you're using shuffle tweak. Don't worry, it's supported!\n\nTo make QuickPrefs work with it, you will have to set items names like this : \"Tweaks/QuickPrefs\". If you have changed the default name for Tweaks category, change accordingly.\n\nCool thing is that you can also create an item \"Tweaks\" that will allow you to directly reach your Tweaks section.", self);
    } else if ([self shouldShowNoticeForPreferenceOrganizer]) {
        showAlert(@"You're using PreferenceOrganizer2 tweak", @"I've noticed that you're using PreferenceOrganizer2 tweak. Don't worry, it's supported!\n\nTo make QuickPrefs work with it, you will have to set items names like this : \"Cydia/QuickPrefs\". If you have changed the default name for Cydia category, change accordingly.\n\nCool thing is that you can also create an item \"Cydia\" that will allow you to directly reach your Cydia section.", self);
    }

    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGRect frame = self.table.bounds;
    frame.origin.y = -frame.size.height;

    self.navigationController.navigationController.navigationBar.prefersLargeTitles = NO;
}

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Prefs" target:self] retain];
    }
    return _specifiers;
}

- (void)respring:(id)sender {
    [HBRespringController respring];
}


#pragma mark - Header style
//Courtesy of Nepeta (Axon)

-(void) setupNavigationTitleView {
    self.navigationItem.titleView = [UIView new];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.text = @"QuickPrefs";
    // self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.navigationItem.titleView addSubview:self.titleLabel];

    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView.image = [UIImage imageWithContentsOfFile:ROOT_PATH_NS(@"/Library/PreferenceBundles/QuickPrefsPrefs.bundle/icon@2x.png")];    
    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconView.alpha = 0.0;
    [self.navigationItem.titleView addSubview:self.iconView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
        [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor constant:7],
        [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
        [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
        [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor constant:-7],
    ]];
}

-(void) setupNavigationRespringButton {
    self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" 
                                style:UIBarButtonItemStylePlain
                                target:self 
                                action:@selector(respring:)];
    // self.respringButton.tintColor = [UIColor whiteColor];
//    self.navigationItem.rightBarButtonItem = self.respringButton;
}

-(void) setupHeaderView {
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImageView.image = [UIImage imageWithContentsOfFile:ROOT_PATH_NS(@"/Library/PreferenceBundles/QuickPrefsPrefs.bundle/header.png")];
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.headerView addSubview:self.headerImageView];
    [NSLayoutConstraint activateConstraints:@[
        [self.headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor constant:headerPaddingTopBottom],
        [self.headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor constant:headerPaddingLeftRight],
        [self.headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:-headerPaddingLeftRight],
        [self.headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:-headerPaddingTopBottom],
    ]];

    self.table.tableHeaderView = self.headerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;

    if (offsetY > 70) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }
    
    if (offsetY > -headerPaddingTopBottom/2) offsetY = -headerPaddingTopBottom/2; //have incidence on "padding bottom" under image while scrolling down
    self.headerImageView.frame = CGRectMake(headerPaddingLeftRight, offsetY + 64 + headerPaddingTopBottom, self.headerView.frame.size.width - headerPaddingLeftRight*2, 200 - offsetY - 64 - headerPaddingTopBottom*2);
}

- (double)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 6) {
        return 0;
    } else if (section == 5) { //my other tweaks
        return 60;
    } else {
        return [self tableView:tableView titleForHeaderInSection:section] ? 45 : 0;
    }
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];
    
    NSMutableDictionary *preferences = [NSMutableDictionary dictionaryWithContentsOfFile:prefPath];

    NSString *key = [specifier propertyForKey:@"key"];

    if ([key isEqualToString:@"enabled"]) {
        self.navigationItem.rightBarButtonItem = self.respringButton;
    }

    [preferences setObject:value forKey:key];
    [preferences writeToFile:prefPath atomically:YES];
    CFStringRef post = (CFStringRef)CFBridgingRetain(specifier.properties[@"PostNotification"]);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), post, NULL, NULL, YES);
}


#pragma mark - Notice alerts for shuffle & PreferencesOrganizer2

-(BOOL) shouldShowNoticeForShuffle {
    if (!pref_getBool(@"shuffleNoticeHasAlreadyBeShown") && [[NSFileManager defaultManager] fileExistsAtPath:ROOT_PATH_NS(@"/var/lib/dpkg/info/com.creaturecoding.shuffle.list")]) {
        pref_setBoolForKey(YES, @"shuffleNoticeHasAlreadyBeShown");
        return YES;
    }
    return NO;
}

-(BOOL) shouldShowNoticeForPreferenceOrganizer {
    if (!pref_getBool(@"preferenceOrganizerNoticeHasAlreadyBeShown") && [[NSFileManager defaultManager] fileExistsAtPath:ROOT_PATH_NS(@"/var/lib/dpkg/info/net.angelxwind.preferenceorganizer2.list")]) {
        pref_setBoolForKey(YES, @"preferenceOrganizerNoticeHasAlreadyBeShown");
        return YES;
    }
    return NO;
}

@end