//
//  PPConfigureViewModel.m
//  Printer Portal
//
//  Created by Eldon on 6/22/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPConfigureViewModel.h"
#import "PPListManager.h"
#import "PPConfigureViewController.h"

@interface PPConfigureViewModel ()
@property (nonatomic, readwrite) BOOL bonjourEnabled;
@property (nonatomic, readwrite) BOOL subscriptionEnabled;
@property (nonatomic, readwrite) BOOL launchAtLoginEnabled;
@property (nonatomic, readwrite) BOOL serverURLIsValid;
@property (nonatomic, readwrite) BOOL isProcessing;

@property (copy, nonatomic, readwrite) NSError *uiError;
@property (copy, nonatomic, readwrite) NSError *executionError;

@property (strong, nonatomic) PPListManager *listManager;

@end

@implementation PPConfigureViewModel

- (instancetype)initWithListManager:(PPListManager *)listManager {
    if (self = [super init]) {
        RAC(self, serverURLIsValid) = [RACObserve(self, serverURL) map:^id(id value) {
            BOOL valid = ([value rangeOfString:@"://"].location != NSNotFound) &&
                         ([value componentsSeparatedByString:@"."].count > 1);
            return @(valid);
        }];

        _listManager = listManager;

        RAC(self, bonjourEnabled) = RACObserve(listManager, bonjourEnabled);
        RAC(self, subscriptionEnabled) = RACObserve(listManager, subscriptionsEnabled);
    }
    return self;
}

- (void)launchAtLogin {
    NSLog(@"viewModel state = %d", self.launchAtLoginEnabled);
    // Nothing here yet...
}

- (void)enableSubscription {
    @weakify(self);
    [[self.listManager enableSubscription_signal] subscribeError:^(NSError *error) {
        @strongify(self);
        if (error) {
            self.uiError = PPErrorFromCode(kPPErrorCouldNotEnableSubscriptions);
        }
    }];
}

- (void)enableBonjourPrinters {
    @weakify(self);
    [[_listManager enableBonjour_signal] subscribeError:^(NSError *error) {
        @strongify(self);
        if (error) {
            self.uiError = PPErrorFromCode(kPPErrorCouldNotEnableBonjour);
        }
    }];
}

- (RACSignal *)configurePrinterListSignal {
    RACSignal *signal = [_listManager configureServerURL_signal:self.serverURL];
    self.isProcessing = YES;
    [signal subscribeError:^(NSError *error) {
        self.uiError = error;
    } completed:^{
        self.isProcessing = NO;
    }];

    return signal;
}

@end
