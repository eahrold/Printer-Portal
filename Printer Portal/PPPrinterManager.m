//
//  PPPrinterManager.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPPrinterManager.h"
#import <Objective-CUPS/OCManager.h>
#import <AppKit/AppKit.h>

@implementation PPPrinterManager

- (void)changePrinterState:(id)sender {
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        BOOL enabled = [sender isEnabled];

        void (^completionHandler)(NSError *) = ^(NSError *error) {
            [self.errorHandler registerError:error];
            if (error) {
                // reset the sender state.
                [sender setEnabled:!enabled];
            }
        };

        OCPrinter *printer =
            (OCPrinter *)[(NSMenuItem *)sender representedObject];
        if (enabled) {
            [[OCManager sharedManager]
                addPrinter:printer
                     reply:^(NSError *error) { completionHandler(error); }];
        } else {
            [[OCManager sharedManager]
                removePrinter:printer.name
                        reply:^(NSError *error) { completionHandler(error); }];
        }
    }
}

- (void)manageSubscriptionList:(NSArray *)subscriptionList {
    
}
@end
