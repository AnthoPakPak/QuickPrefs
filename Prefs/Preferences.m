#import "Preferences.h"

@implementation QPPrefsListController

- (instancetype)init {
    self = [super init];

    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];

    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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

@end