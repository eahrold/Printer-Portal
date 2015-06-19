//
//  PPListManager.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPListManager.h"
#import <AFNetworking/AFNetworking.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Objective-CUPS/OCPrinter.h>


@interface PPListManager ()
@property (copy, nonatomic) NSArray *printerList;
@property (copy, nonatomic) NSArray *bonjourPrinterList;
@property (copy, nonatomic) NSArray *subscriptionPrinterList;
@end

@implementation PPListManager
@synthesize printerListSignal = _printerListSignal;
@synthesize bonjourListSignal = _bonjourListSignal;

- (instancetype)init {
    if (self = [super init]) {
        [[NSAppleEventManager sharedAppleEventManager]
            setEventHandler:self
                andSelector:@selector(didReceiveInternetEvent:)
              forEventClass:kInternetEventClass
                 andEventID:kAEGetURL];

        [[AFNetworkReachabilityManager sharedManager]
            setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus
                                                   status) {
                [self networkStatusChanged:status];
            }];

        [[AFNetworkReachabilityManager sharedManager] startMonitoring];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        [[[defaults rac_channelTerminalForKey:@"ServerURL"] filter:^BOOL(id value) {
            // check that the url is valid
            return value ? YES : NO;
        }] subscribeNext:^(NSString *urlString) {
            [self reloadPrinterListForRequestType:kPPListRequestSelfService url:urlString];
        }];
    }

    return self;
}

- (RACSignal *)printerListSignal {
    if (!_printerListSignal) {
        _printerListSignal =
            [RACObserve(self, printerList) map:^id(NSDictionary *dict) {
                return [dict.rac_sequence map:^id(id value) {
                            return [[OCPrinter alloc] initWithDictionary:value];
                        }].array;
            }];
    }
    return _printerListSignal;
}

- (RACSignal *)bonjourListSignal {
    if (!_bonjourListSignal) {
        _bonjourListSignal =
            [RACObserve(self, bonjourPrinterList) map:^id(NSDictionary *dict) {
                return [dict.rac_sequence map:^id(id value) {
                            return [[OCPrinter alloc] initWithDictionary:value];
                        }].array;
            }];
    }
    return _bonjourListSignal;
}

- (void)reloadPrinterListForRequestType:(ListRequestType)type
                                    url:(NSString *)url {
    NSDictionary *parameters = nil;

    AFHTTPRequestOperationManager *manger =
        [AFHTTPRequestOperationManager manager];
    AFPropertyListResponseSerializer *legacySerializer =
        [AFPropertyListResponseSerializer serializer];

    legacySerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"text/html", @"application/xml", nil];

    manger.responseSerializer = legacySerializer;

    [manger GET:url
        parameters:parameters
        success:^(AFHTTPRequestOperation *operation,
                  NSDictionary *responseObject) {
            if (type & kPPListRequestSelfService) {
                self.printerList = responseObject[@"printerList"];
                self.bonjourPrinterList = responseObject[@"printerList"];
            } else if (type & kPPListRequestSubscription) {
                self.subscriptionPrinterList = responseObject[@"printerList"];
            }
        }
        failure:^(AFHTTPRequestOperation *operation,
                  NSError *error) { [self.errorHandler registerError:error]; }];
}

- (void)networkStatusChanged:(AFNetworkReachabilityStatus)status {
    if (status > AFNetworkReachabilityStatusNotReachable) {
        [self reloadPrinterListForRequestType:kPPListRequestSubscription
                                          url:@"http://192.168.1.108/printers/"
                                          @"subscribe/"];
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

    NSString *urlString =
        [[event paramDescriptorForKeyword:keyDirectObject].stringValue
            stringByReplacingOccurrencesOfString:@"printerinstaller"
                                      withString:@"http"];

    NSURL *url = [NSURL URLWithString:urlString];

    if (url) {
        NSLog(@"URL: %@", url.absoluteString);
    }
}
@end
