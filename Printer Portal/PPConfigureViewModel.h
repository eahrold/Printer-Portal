//
//  PPConfigureViewModel.h
//  Printer Portal
//
//  Created by Eldon on 6/22/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSPopover;
@class PPListManager;
@class RACSignal;
@class PPConfigureViewController;

@interface PPConfigureViewModel : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype) new NS_UNAVAILABLE;

- (instancetype)initWithListManager:(PPListManager *)listManager;

@property (nonatomic, readonly) BOOL bonjourEnabled;
@property (nonatomic, readonly) BOOL subscriptionEnabled;
@property (nonatomic, readonly) BOOL launchAtLoginEnabled;

@property (nonatomic, readonly) BOOL serverURLIsValid;
@property (copy, nonatomic) NSString *serverURL;

/* Short error to present in the user interface */
@property (copy, nonatomic, readonly) NSError *uiError;

/* Actual error received during processing */
@property (copy, nonatomic, readonly) NSError *executionError;

/* Is a printer list in the process of getting modified */
@property (nonatomic, readonly) BOOL isProcessing;

@property (strong, readonly) PPConfigureViewController *controller;

/**
 *  Signal for monitoring changes in printer list.
 *
 *  @note Backing for view's setServer_button.rac_command
 *  @return Signal for monitoring changes in printer list.
 */
- (RACSignal *)configurePrinterListSignal;

- (void)enableSubscription;
- (void)enableBonjourPrinters;
- (void)launchAtLogin;

@end
