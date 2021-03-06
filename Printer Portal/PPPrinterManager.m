//
//  PPPrinterManager.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//
#import <AppKit/AppKit.h>

#import "PPPrinterManager.h"
#import "OCSubscriptionPriner.h"

#import <Objective-CUPS/OCManager.h>

static NSString *const subscriptionPrinterPredicateString = @"_pp-printer";

@implementation PPPrinterManager

- (void)changePrinterState:(NSButton *)sender {
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        /* The behavior is a little different a NSMenuItem vs. NSButton.
         * the menuItem's state property isn't automatically set when the
         * menu items is selected so set it now. */
        BOOL state = !sender.state;

        /* Setting the sender target to nil here
         * is to disable the menu item. */
         sender.target = nil;

        void (^completionHandler)(NSError *) = ^(NSError *error) {
            [self.errorHandler registerError:error];

            // Reset (enable) the target
            sender.target = self;

            if (!error) {
                // reset the sender state.
                sender.state = !sender.state;
            }
        };

        OCPrinter *printer = (OCPrinter *)[(NSMenuItem *)sender representedObject];

        if (state) {
            [[OCManager sharedManager] addPrinter:printer
                                            reply:^(NSError *error) {
                                                completionHandler(error);
                                            }];
        } else {
            [[OCManager sharedManager] removePrinter:printer.name
                                               reply:^(NSError *error) {
                                                   completionHandler(error);
                                               }];
        }
    }
}

- (void)manageSubscriptionList:(NSArray *)subscriptionList {
    NSSet *installedPrinters = [OCManager installedPrinters];
    NSPredicate *subscriptionPredicate;

    if (!subscriptionList) {
        subscriptionPredicate = [NSPredicate
            predicateWithFormat:@"%K ENDSWITH %@", NSStringFromSelector(@selector(location)),
                                subscriptionPrinterPredicateString];
        [[installedPrinters filteredSetUsingPredicate:subscriptionPredicate]
            enumerateObjectsUsingBlock:^(OCPrinter *printer, BOOL *stop) {
                [[OCManager sharedManager] removePrinter:printer.name];
            }];
    } else {
        for (OCSubscriptionPriner *printer in subscriptionList) {
            __block BOOL skip = NO;
            [installedPrinters
                enumerateObjectsUsingBlock:^(OCPrinter *installedPrinter, BOOL *stop) {
                    if ([installedPrinter.name isEqualToString:printer.name]) {
                        // Found a matching printer, mark stop.
                        skip = YES;
                        *stop = YES;
                    }
                }];
            if (skip == NO) {
                [[OCManager sharedManager] addPrinter:printer];
            }
        }
    }
}

@end
