//
//  PPListManager.h
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPObject.h"

typedef NS_OPTIONS(NSInteger, ListRequestType) {
    kPPListRequestSubscription = 1 << 0,
    kPPListRequestSelfService = 1 << 1,
    kPPListRequestBonjour = 1 << 2,
};

@interface PPListManager : PPObject

@property (copy, nonatomic, readonly) RACSignal *printerListSignal;
@property (copy, nonatomic, readonly) RACSignal *bonjourListSignal;
@property (copy, nonatomic, readonly) RACSignal *subscriptionListSignal;

@end
