//
//  PPErrorHandler.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPErrorHandler.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

static NSString *const messageKey = @"message";
static NSString *const detailsKey = @"details";

static NSDictionary* userInfoForCode(PPErrorCode code){
    static dispatch_once_t onceToken;
    static NSDictionary *dict;
    dispatch_once(&onceToken, ^{
    dict = @{
             @(kPPErrorSuccess):
                 @{ messageKey : NSLocalizedString(@"Success!", nil),
                    detailsKey : NSLocalizedString(@"All's well", nil)},
             @(kPPErrorCouldNotAddLoginItem):
                 @{ messageKey : NSLocalizedString(@"Could not add login item", nil),
                    detailsKey : NSLocalizedString(@"There was a problem adding the login item", nil)},
             @(kPPErrorCouldNotInstallHelper):
                 @{ messageKey : NSLocalizedString(@"The helper tool could not be installed", nil),
                    detailsKey : NSLocalizedString(@"We cannot continue, quitting.", nil)},
             @(kPPErrorServerURLInvalid):
                 @{messageKey : NSLocalizedString(@"The specified url is not valid", nil),
                   detailsKey : NSLocalizedString(@"Please verify the url is correct", nil)},
             };
    });

    return dict[@(code)] ?: @{};
}

NSError *PPErrorFromCode(PPErrorCode code) {
    return [NSError errorWithDomain:[[NSProcessInfo processInfo] processName]
                               code:code userInfo:userInfoForCode(code)];
}


@interface PPErrorHandler()
@property (copy, nonatomic) NSError *currentError;
@end

@implementation PPErrorHandler

+ (instancetype)sharedErrorHandler
{
    static dispatch_once_t onceToken;
    __strong static id _sharedObject = nil;

    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });

    return _sharedObject;
}

- (instancetype)init {
    if (self = [super init]) {
        _errorSignal = RACObserve(self, currentError);
    }
    return self;
}

- (void)registerError:(NSError *)error {
    self.currentError = error;
}

- (void)registerErrorWithCode:(PPErrorCode)code {
    self.currentError = [NSError errorWithDomain:[[NSProcessInfo processInfo] processName] code:code userInfo:userInfoForCode(code)];
}
@end
