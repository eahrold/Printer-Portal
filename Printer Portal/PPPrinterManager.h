//
//  PPPrinterManager.h
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPObject.h"
@interface PPPrinterManager : PPObject

/**
 *  Add or remove a printer from the OSX Printer Dialog
 *
 *  @param sender NSButton or NSMenuItem who's state property is
 *         used to determine whether to add or remove the printer.
 *  @note if the sender is an NSMenuItem, the representedObject property should be
 *        set to the OCPrinter to add/remove
 */
- (void)changePrinterState:(id)sender;

/**
 *  Automatically add new and remove no longer approperiate printers for the current subnet.
 *
 *  @param subscriptionList Array of OCSubscriptionPriner objects for the current subnet.
 */
- (void)manageSubscriptionList:(NSArray *)subscriptionList;

@end
