//
//  BNCSystemObserver.m
//  Branch-SDK
//
//  Created by Alex Austin on 6/5/14.
//  Copyright (c) 2014 Branch Metrics. All rights reserved.
//

#include <sys/utsname.h>
#import "BNCPreferenceHelper.h"
#import "BNCSystemObserver.h"
#import <UIKit/UIDevice.h>
#import <UIKit/UIScreen.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation BNCSystemObserver

+ (NSString *)getUniqueHardwareId:(BOOL *)isReal {
    NSString *uid = nil;
    *isReal = YES;
    
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        uid = [uuid UUIDString];
    }
    
    if (!uid && NSClassFromString(@"UIDevice")) {
        uid = [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    
    if (!uid) {
        uid = [[NSUUID UUID] UUIDString];
        *isReal = NO;
    }
    
    return uid;
}

+ (NSString *)getURIScheme {
    NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if (urlTypes) {
        for (NSDictionary *urlType in urlTypes) {
            NSArray *urlSchemes = [urlType objectForKey:@"CFBundleURLSchemes"];
            if (urlSchemes) {
                for (NSString *urlScheme in urlSchemes) {
                    if (![[urlScheme substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"fb"] &&
                        ![[urlScheme substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"db"] &&
                        ![[urlScheme substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"pin"]) {
                        return urlScheme;
                    }
                }
            }
        }
    }
    return nil;
}

+ (NSString *)getAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)getCarrier {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    return carrier.carrierName;
}

+ (NSString *)getBrand {
    return @"Apple";
}

+ (NSString *)getModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (BOOL)isSimulator {
    UIDevice *currentDevice = [UIDevice currentDevice];
    return [currentDevice.model rangeOfString:@"Simulator"].location != NSNotFound;
}

+ (NSString *)getDeviceName {
    if ([BNCSystemObserver isSimulator]) {
        struct utsname name;
        uname(&name);
        return [NSString stringWithFormat:@"%@ %s", [[UIDevice currentDevice] name], name.nodename];
    } else {
        return [[UIDevice currentDevice] name];
    }
}

+ (NSNumber *)getUpdateState {
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary* attrs = [manager attributesOfItemAtPath:bundleRoot error:nil];
    if ((int)([[attrs fileCreationDate] timeIntervalSince1970]/(60*60*24)) == (int)([[attrs fileModificationDate] timeIntervalSince1970]/(60*60*24))) {
        return nil;
    } else {
        return [NSNumber numberWithInt:1];
    }
}

+ (NSString *)getOS {
    return @"iOS";
}

+ (NSString *)getOSVersion {
    UIDevice *device = [UIDevice currentDevice];
    return [device systemVersion];
}

+ (NSNumber *)getScreenWidth {
    UIScreen *mainScreen = [UIScreen mainScreen];
    float scaleFactor = mainScreen.scale;
    CGFloat width = mainScreen.bounds.size.width * scaleFactor;
    return [NSNumber numberWithInteger:(NSInteger)width];
}

+ (NSNumber *)getScreenHeight {
    UIScreen *mainScreen = [UIScreen mainScreen];
    float scaleFactor = mainScreen.scale;
    CGFloat height = mainScreen.bounds.size.height * scaleFactor;
    return [NSNumber numberWithInteger:(NSInteger)height];
}

@end
