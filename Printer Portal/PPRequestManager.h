//
//  PPRequestManager.h
//  Printer Portal
//
//  Created by Eldon on 6/20/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
@class RACSignal;

@interface PPRequestResponse : NSObject <NSSecureCoding>
- (instancetype)init NS_UNAVAILABLE;
@property (copy, nonatomic, readonly) NSArray *printerList;
@property (copy, nonatomic, readonly) NSString *subnet;
@property (copy, nonatomic, readonly) NSString *updateServer;
@end

@interface PPRequestManager : AFHTTPRequestOperationManager
+ (PPRequestManager *)manager;
- (RACSignal *)GET_rac:(NSString *)URLString parameters:(id)parameters;

@end
