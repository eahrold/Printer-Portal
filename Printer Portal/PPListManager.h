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

// Server URL
@property (copy, nonatomic, readonly) NSString *serverURL;

// Signal that sends changes to the array of OCPrinters of the current list printers
@property (copy, nonatomic, readonly) RACSignal *printerListSignal;

// Signal that sends changes to the array of OCBonjourPrinters of the current bonjour printers
@property (copy, nonatomic, readonly) RACSignal *bonjourListSignal;

// Signal that sends changes to the array of OCSubscriptionPrinters of the current subscription printers
@property (copy, nonatomic, readonly) RACSignal *subscriptionListSignal;

/**
 *  Get a RACSignal for a server at a given url
 *
 *  @param url Full url to host providing the server lists.
 *
 *  @return Signal used to provide the backing to a View-Model
 */
- (RACSignal *)configureServerURL_signal:(NSString *)url;

// Should subscriptions be enabled?
@property (nonatomic, readonly) BOOL subscriptionsEnabled;

// Signal for observing changes in the enabled state of subscription printer list.
- (RACSignal *)enableSubscription_signal;

// Should bonjour printers be enabled?
@property (nonatomic, readonly) BOOL bonjourEnabled;
// Signal for observing changes in the enabled state of bonjour printer list.
- (RACSignal *)enableBonjour_signal;

@end
