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
};

@interface PPListManager : PPObject

@property (copy, nonatomic, readonly) NSString *serverURL;
@property (copy, nonatomic, readonly) RACSignal *printerListSignal;
@property (copy, nonatomic, readonly) RACSignal *bonjourListSignal;
@property (copy, nonatomic, readonly) RACSignal *subscriptionListSignal;

- (RACSignal *)configureServerURL_signal:(NSString *)url;

@property (nonatomic, readonly) BOOL subscriptionsEnabled;
- (RACSignal *)enableSubscription_signal;

@property (nonatomic, readonly) BOOL bonjourEnabled;
- (RACSignal *)enableBonjour_signal;

@end