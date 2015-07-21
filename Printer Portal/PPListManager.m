//
//  PPListManager.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPListManager.h"
#import "PPRequestManager.h"
#import "PPBonjourBrowser.h"

#import "PPDefaults.h"

#import "OCSubscriptionPriner.h"

#import <Objective-CUPS/OCManager.h>

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PPListManager ()
@property (copy, nonatomic) NSString *serverURL;
@property (copy, nonatomic) NSArray *printerList;
@property (copy, nonatomic) NSArray *bonjourPrinterList;
@property (copy, nonatomic) NSArray *subscriptionPrinterList;

@property (copy, nonatomic) NSArray *installedPrinters;
@property (strong, nonatomic) PPBonjourBrowser *bonjourBrowser;

@property (nonatomic, readwrite) BOOL bonjourEnabled;

@end

@implementation PPListManager {
    PPDefaults *_defaults;
}
@synthesize printerListSignal = _printerListSignal;
@synthesize bonjourListSignal = _bonjourListSignal;
@synthesize subscriptionListSignal = _subscriptionListSignal;

- (instancetype)init {
    if (self = [super init]) {
        [[NSAppleEventManager sharedAppleEventManager]
            setEventHandler:self
                andSelector:@selector(didReceiveInternetEvent:)
              forEventClass:kInternetEventClass
                 andEventID:kAEGetURL];

        [[AFNetworkReachabilityManager sharedManager]
            setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                [self networkStatusChanged:status];
            }];

        [[AFNetworkReachabilityManager sharedManager] startMonitoring];

        _defaults = [[PPDefaults alloc] init];
        _bonjourBrowser = [[PPBonjourBrowser alloc] init];

        self.printerList = _defaults.CurrentPrinters;
        self.serverURL = _defaults.ServerURL;

        if (_defaults.ShowBonjourPrinters) {
            [_bonjourBrowser start];
        }

        RAC(_defaults, CurrentPrinters) = RACObserve(self, printerList);
        RAC(_defaults, ServerURL) = RACObserve(self, serverURL);
        RAC(_defaults, ShowBonjourPrinters) = RACObserve(self, bonjourEnabled);

        RAC(self, bonjourEnabled) = RACObserve(self.bonjourBrowser, isSearching);
        RAC(self, bonjourPrinterList) = RACObserve(self.bonjourBrowser, bonjourPrinters);

        RAC(self, subscriptionsEnabled, @(_defaults.Subscribe)) =
            [[RACObserve(self, subscriptionPrinterList) skip:1] map:^id(id value) {
                return [NSNumber numberWithBool:(value != nil)];
            }];
    }
    return self;
}

- (RACSignal *)subscriptionListSignal {
    if (!_subscriptionListSignal) {
        _subscriptionListSignal =
            [RACObserve(self, subscriptionPrinterList) map:^id(NSDictionary *dict) {
                return
                    [dict.rac_sequence map:^id(id value) {
                        return [[OCSubscriptionPriner alloc] initWithDictionary:value];
                    }].array;
            }];
    }
    return _subscriptionListSignal;
}

- (RACSignal *)printerListSignal {
    if (!_printerListSignal) {
        _printerListSignal = [RACObserve(self, printerList) map:^id(NSDictionary *dict) {
            return
                [dict.rac_sequence map:^id(id value) {
                    return [[OCPrinter alloc] initWithDictionary:value];
                }].array;
        }];
    }
    return _printerListSignal;
}

- (RACSignal *)bonjourListSignal {
    if (!_bonjourListSignal) {
        _bonjourListSignal = RACObserve(self, bonjourPrinterList);
    }
    return _bonjourListSignal;
}

- (void)networkStatusChanged:(AFNetworkReachabilityStatus)status {
    if (status > AFNetworkReachabilityStatusNotReachable) {
        [[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [self enableSubscription_signal];
        }] execute:self];
    } else {
        self.bonjourPrinterList = nil;
        self.subscriptionPrinterList = nil;
    }
}

- (void)didReceiveInternetEvent:(NSAppleEventDescriptor *)event {
    /* There are a few types of events we can respond to
     * 1) A new self service list getting selected.
     * 2) User subscribing
     * 3) User unsubscribing
     */

    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject]
                               .stringValue stringByReplacingOccurrencesOfString:@"printerportal"
                                                                      withString:@"http"];

    BOOL subscriptionEvent = NO;
    if ([urlString.lastPathComponent isEqualToString:kPPDefaultsKeySubscribe]) {
        _subscriptionsEnabled = NO;
        subscriptionEvent = YES;
    } else if ([urlString.lastPathComponent isEqualToString:kPPDefaultsKeyUnsubscribe]) {
        _subscriptionsEnabled = YES;
        subscriptionEvent = YES;
    }

    if (subscriptionEvent) {
        _defaults.SubscriptionHost = urlString;
        [[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [self enableSubscription_signal];
        }] execute:self];
    } else {
        [[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [self configureServerURL_signal:urlString];
        }] execute:self];
    }
}

- (RACSignal *)configureServerURL_signal:(NSString *)url {
    RACSignal *signal = [[PPRequestManager manager] GET_rac:url parameters:nil];

    [[signal filter:^BOOL(PPRequestResponse *response) {
        return (response.printerList != nil);
    }] subscribeNext:^(PPRequestResponse *response) {
        self.printerList = response.printerList;
        self.serverURL = url;
    }];

    return signal;
}

- (RACSignal *)enableSubscription_signal {
    RACSignal *signal = nil;
    // Toggle ON/OFF
    if (_subscriptionsEnabled) {
        signal = [RACSignal empty];
        self.subscriptionPrinterList = nil;
    } else {
        signal = [[PPRequestManager manager] GET_rac:_defaults.SubscriptionURL parameters:nil];

        [signal subscribeNext:^(PPRequestResponse *response) {
            self.subscriptionPrinterList = response.printerList;
        } error:^(NSError *error) {
            if (error) {
                self.subscriptionPrinterList = nil;
            }
        }];
    }
    return signal;
}

- (RACSignal *)enableBonjour_signal {
    if (_bonjourEnabled) {
        [self.bonjourBrowser stop];
    } else {
        [self.bonjourBrowser start];
    }
    return [RACSignal empty];
}
@end
