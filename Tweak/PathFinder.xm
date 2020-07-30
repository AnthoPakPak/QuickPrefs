#import "Tweak.h"
#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>

#ifndef SIMULATOR
HBPreferences *pathFinderPreferences;
#endif

BOOL pathFinderEnabled;

UILongPressGestureRecognizer *longPressGestureRecognizer;

%group PathFinder

static void addGestureRecognizerToListVC(PSListController *listVC) {
    DLog(@"addGestureRecognizerToTable");

    UITableView *tableView = MSHookIvar<UITableView*>(listVC, "_table");
    if (![tableView.gestureRecognizers containsObject:longPressGestureRecognizer]) {
        longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:listVC action:@selector(quickPrefs_handleLongPress:)];
        longPressGestureRecognizer.minimumPressDuration = 0.3;
        [tableView addGestureRecognizer:longPressGestureRecognizer];
    }
}

static void handleGesture(UIGestureRecognizer *gestureRecognizer, PSListController *listVC) {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }

    UITableView *tableView = MSHookIvar<UITableView*>(listVC, "_table");

    CGPoint p = [gestureRecognizer locationInView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:p];

    PSTableCell *cell = (PSTableCell*) [tableView cellForRowAtIndexPath:indexPath];
    DLog(@"cell %@", cell);

    PSSpecifier *specifier = [cell specifier];
    NSString *specifierIdentifier = [specifier identifier];

    if (specifierIdentifier) {
        NSString *message = [NSString stringWithFormat:@"%@\n\nThis is the identifier of this page/subpage. Use it in QuickPrefs to access to this page. If this is a subpage, use it like this: PREVIOUS_PAGE_ID/%@", specifierIdentifier, specifierIdentifier];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"QuickPrefs Path Finder" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Copy ID" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = specifierIdentifier;
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        [listVC presentViewController:alertController animated:YES completion:nil];
    }
}

%hook PSListController

-(void) viewDidAppear:(BOOL)animated {
    %orig;
    
    if (pathFinderEnabled) {
        addGestureRecognizerToListVC(self);
    }
}

%new
-(void) quickPrefs_handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (pathFinderEnabled) {
        handleGesture(gestureRecognizer, self);
    }
}

%end //hook PSListController

%end //group PathFinder

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
        DLog(@"QuickPrefs PathFinder shouldn't run in this process");
        return;
    }

#ifndef SIMULATOR
    pathFinderPreferences = [[HBPreferences alloc] initWithIdentifier:@"com.anthopak.quickprefs"];
    [pathFinderPreferences registerBool:&pathFinderEnabled default:NO forKey:@"pathFinderEnabled"];
#endif

    %init(PathFinder);
}
