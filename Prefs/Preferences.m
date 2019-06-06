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

    // NSArray<UITextField*>* allTextFields = [self findAllTextFieldsInView:[self view]];
    // DLog(@"allTextFields %@", allTextFields);
    // for (UITextField *textField in allTextFields) {
    //     if (textField.isFirstResponder) {
    //         DLog(@"isFirstResponder");
    //         textField.delegate = self;
    //     }
    // }

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


#pragma mark - Cephei not saving textfield content workaround attempt (just kept for the record)

// Boolean savePreferencesDictionary(CFStringRef appID, CFDictionaryRef dict) {
// 	CFPreferencesSetMultiple(dict, nil, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
// 	return CFPreferencesSynchronize(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
// }

// - (void)textFieldDidEndEditing:(UITextField *)textField {
//     DLog(@"textFieldDidEndEditing");

//     [textField resignFirstResponder];
// }

// - (void)applySettings:(id)sender {
//     DLog(@"applySettings");

//     // [self.view endEditing:YES];
//     [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
//     NSArray<UITextField*>* allTextFields = [self findAllTextFieldsInView:[self view]];
//     DLog(@"allTextFields %@", allTextFields);
    



//     NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_FILE];

//     for (int i = 0; i < 4; i++) {
//         UITextField *textField = allTextFields[i];
//         [settings setObject:textField.text forKey:[NSString stringWithFormat:@"item%d", i+1]];
//     }
//     [settings writeToFile:PLIST_FILE atomically:NO];


//     BOOL b = (BOOL)savePreferencesDictionary((CFStringRef)@"com.anthopak.quickprefs", (CFDictionaryRef)settings);

//     DLog(@"saved ? %d", b);
//     DLog(@"settings ? %@", settings);

//     CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.anthopak.quickprefs/ReloadPrefs", NULL, (CFDictionaryRef)settings, true);
// }

// -(NSArray*)findAllTextFieldsInView:(UIView*)view{
//     NSMutableArray* textfieldarray = [[[NSMutableArray alloc] init] autorelease];
//     for(id x in [view subviews]){
//         if([x isKindOfClass:[UITextField class]])
//             [textfieldarray addObject:x];

//         if([x respondsToSelector:@selector(subviews)]){
//             // if it has subviews, loop through those, too
//             [textfieldarray addObjectsFromArray:[self findAllTextFieldsInView:x]];
//         }
//     }
//     return textfieldarray;
// }
@end