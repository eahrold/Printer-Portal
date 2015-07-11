//
//  PPErrorHandler.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPErrorHandler.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

static NSDictionary *userInfoForCode(PPErrorCode code) {
    static dispatch_once_t onceToken;
    static NSDictionary *dict;
    dispatch_once(&onceToken, ^{
        dict = @{
            @(kPPErrorSuccess) : @{
                NSLocalizedDescriptionKey : NSLocalizedString(@"Success!", nil),
                NSLocalizedRecoverySuggestionErrorKey : @""
            },
            @(kPPErrorCouldNotAddLoginItem) : @{
                NSLocalizedDescriptionKey : NSLocalizedString(@"Could not add login item.", nil),
                NSLocalizedRecoverySuggestionErrorKey :
                    NSLocalizedString(@"There was a problem adding the login item.", nil)
            },
            @(kPPErrorCouldNotInstallHelper) : @{
                NSLocalizedDescriptionKey :
                    NSLocalizedString(@"The helper tool could not be installed.", nil),
                NSLocalizedRecoverySuggestionErrorKey :
                    NSLocalizedString(@"We cannot continue, quitting..", nil)
            },
            @(kPPErrorServerURLInvalid) : @{
                NSLocalizedDescriptionKey :
                    NSLocalizedString(@"The specified url is not valid", nil),
                NSLocalizedRecoverySuggestionErrorKey :
                    NSLocalizedString(@"Please verify the url is correct.", nil)
            },
            @(kPPErrorCouldNotEnableBonjour) : @{
                NSLocalizedDescriptionKey :
                    NSLocalizedString(@"There was a problem enabling bonjour.", nil),
                NSLocalizedRecoverySuggestionErrorKey : @""
            },
            @(kPPErrorCouldNotEnableSubscriptions) : @{
                NSLocalizedDescriptionKey :
                    NSLocalizedString(@"The was a problem subscribing at the given address.", nil),
                NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(
                    @"Unable to find a subscription list at the give address, please contact the "
                    @"System Administrator for more information",
                    nil)
            },
        };
    });

    return dict[@(code)] ?: @{};
}

NSError *PPErrorFromCode(PPErrorCode code) {
    return [NSError errorWithDomain:[[NSProcessInfo processInfo] processName]
                               code:code
                           userInfo:userInfoForCode(code)];
}

@interface PPErrorHandler ()
@property (copy, nonatomic) NSError *currentError;
@end

@implementation PPErrorHandler

+ (instancetype)sharedErrorHandler {
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
    self.currentError = [NSError errorWithDomain:[[NSProcessInfo processInfo] processName]
                                            code:code
                                        userInfo:userInfoForCode(code)];
}
@end
