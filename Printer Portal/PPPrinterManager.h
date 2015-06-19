//
//  PPPrinterManager.h
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPObject.h"
@interface PPPrinterManager : PPObject

- (void)changePrinterState:(id)sender;

- (void)manageSubscriptionList:(NSArray *)subscriptionList;

@end
