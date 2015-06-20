//
//  AppDelegate.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPAppDelegate.h"
#import "PPStatusItem.h"
#import "PPPrinterManager.h"
#import "PPListManager.h"

#import <Objective-CUPS/OCPrinter.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PPAppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation PPAppDelegate {
    PPStatusItem *_statusItem;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    PPPrinterManager *printerManager = [[PPPrinterManager alloc] init];
    PPListManager *listManager = [[PPListManager alloc] init];

    _statusItem = [[PPStatusItem alloc] initWithPrinterManager:printerManager];

    RAC(_statusItem, bonjourPrinterList) = listManager.bonjourListSignal;
    RAC(_statusItem, printerList) = listManager.printerListSignal;

    [listManager.subscriptionListSignal subscribeNext:^(NSArray *list) {
        [printerManager manageSubscriptionList:list];
    }];

    [[PPErrorHandler sharedErrorHandler].errorSignal subscribeNext:^(NSError *error) {
        if (error) {
            [NSApp presentError:error];
        }
    }];
    
}

- (void)applicationDidResignActive:(NSNotification *)notification {
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
