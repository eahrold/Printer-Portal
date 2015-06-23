//
//  PPErrorHandler.h
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

typedef NS_ENUM(NSInteger, PPErrorCode) {
    kPPErrorSuccess = 0,
    kPPErrorCouldNotAddLoginItem,
    kPPErrorCouldNotInstallHelper,
    kPPErrorServerURLInvalid,
};

NSError *PPErrorFromCode(PPErrorCode code);

@interface PPErrorHandler : NSObject
+ (instancetype)sharedErrorHandler;

@property (copy, nonatomic, readonly) RACSignal *errorSignal;
@property (copy, nonatomic, readonly) NSError *currentError;


- (void)registerError:(NSError *)error;
- (void)registerErrorWithCode:(PPErrorCode)code;


@end
