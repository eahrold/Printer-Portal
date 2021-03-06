//
//  PPDefaults.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPDefaults.h"

NSString *const kPPDefaultsKeySubscribe = @"subscribe";
NSString *const kPPDefaultsKeyUnsubscribe = @"unsubscribe";

@implementation PPDefaults

- (instancetype)init {
    if (self = [super init]) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

#pragma mark - Subscription
- (BOOL)Subscribe {
    return [_defaults boolForKey:NSStringFromSelector(@selector(Subscribe))];
}

- (void)setSubscribe:(BOOL)Subscribe {
    [_defaults setValue:@(Subscribe) forKey:NSStringFromSelector(@selector(Subscribe))];
}

- (void)setSubscriptionHost:(NSString *)SubscriptionHost {
    if ([@[ kPPDefaultsKeySubscribe, kPPDefaultsKeyUnsubscribe ] containsObject:SubscriptionHost.lastPathComponent]) {
        SubscriptionHost = SubscriptionHost.stringByDeletingLastPathComponent;
    }
    [_defaults setValue:SubscriptionHost forKey:NSStringFromSelector(@selector(SubscriptionHost))];
}

- (NSString *)SubscriptionHost {
    NSString *host = [_defaults valueForKey:NSStringFromSelector(@selector(SubscriptionHost))];
    if (host && [@[ kPPDefaultsKeySubscribe, kPPDefaultsKeyUnsubscribe ] containsObject:host.lastPathComponent]) {
        host = host.stringByDeletingLastPathComponent;
    }

    return host ?: [self.ServerURL.stringByDeletingLastPathComponent stringByAppendingPathComponent:kPPDefaultsKeySubscribe];
}

- (NSString *)SubscriptionURL {
    return [self.SubscriptionHost stringByAppendingPathComponent:kPPDefaultsKeySubscribe];
}

#pragma mark - Server url
- (NSString *)ServerURL {
    return [_defaults stringForKey:NSStringFromSelector(@selector(ServerURL))];
}

- (void)setServerURL:(NSString *)ServerURL {
    [_defaults setValue:ServerURL forKey:NSStringFromSelector(@selector(ServerURL))];
}

#pragma mark - Current / Previously installed printers...
- (NSArray *)CurrentPrinters {
    return [_defaults arrayForKey:NSStringFromSelector(@selector(CurrentPrinters))];
}

- (void)setCurrentPrinters:(NSArray *)CurrentPrinters {
    [_defaults setValue:CurrentPrinters forKey:NSStringFromSelector(@selector(CurrentPrinters))];
}

#pragma mark - Bonjour

- (BOOL)ShowBonjourPrinters {
    return [_defaults boolForKey:NSStringFromSelector(@selector(ShowBonjourPrinters))];
}

- (void)setShowBonjourPrinters:(BOOL)ShowBonjourPrinters {
    [_defaults setBool:ShowBonjourPrinters forKey:NSStringFromSelector(@selector(ShowBonjourPrinters))];
}
@end
