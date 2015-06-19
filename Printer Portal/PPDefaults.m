//
//  PPDefaults.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPDefaults.h"

@implementation PPDefaults

- (instancetype)init {
    if (self = [super init]) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (BOOL)Subscribe {
    return [_defaults boolForKey:NSStringFromSelector(@selector(Subscribe))];
}

- (void)setSubscribe:(BOOL)Subscribe {
    [_defaults setValue:@(Subscribe) forKey:NSStringFromSelector(@selector(Subscribe))];
}

- (NSString *)ServerURL {
    return [_defaults stringForKey:NSStringFromSelector(@selector(ServerURL))];
}

- (void)setServerURL:(NSString *)ServerURL {
    [_defaults setValue:ServerURL forKey:NSStringFromSelector(@selector(ServerURL))];
}

@end
