#import <Foundation/Foundation.h>
#import "NSTask.h"
#ifndef SIMULATOR
#import <Cephei/HBPreferences.h>
#endif

#ifdef DEBUG
	#define DLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__);
#else
	#define DLog(...)
#endif

@interface SBSApplicationShortcutItem : NSObject <NSCopying>

@property (nonatomic,copy) NSString * type;
@property (nonatomic,copy) NSString * localizedTitle;
@property (nonatomic,copy) NSString * localizedSubtitle;
@property (nonatomic,copy) NSString * bundleIdentifierToLaunch;

@end


@interface SBUIAppIconForceTouchControllerDataProvider : NSObject

-(NSString *)applicationBundleIdentifier;

@end 


@interface UIApplication (Custom)

-(BOOL)_openURL:(id)arg1 ;

@end