//
//  AppDelegate.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPAppDelegate.h"
#import "PPStatusItemViewModel.h"
#import "PPPrinterManager.h"
#import "PPListManager.h"

#import <Objective-CUPS/OCPrinter.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PPAppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation PPAppDelegate {
    PPStatusItemViewModel *_statusItem;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    PPPrinterManager *printerManager = [[PPPrinterManager alloc] init];
    PPListManager *listManager = [[PPListManager alloc] init];

    _statusItem = [[PPStatusItemViewModel alloc] initWithPrinterManager:printerManager
                                                            listManager:listManager];

    [listManager.subscriptionListSignal subscribeNext:^(NSArray *list) {
        [printerManager manageSubscriptionList:list];
    }];

    [[PPErrorHandler sharedErrorHandler]
            .errorSignal subscribeNext:^(NSError *error) {
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
