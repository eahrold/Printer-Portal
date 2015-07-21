//
//  PPDefaults.h
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kPPDefaultsKeySubscribe;
extern NSString *const kPPDefaultsKeyUnsubscribe;

@interface PPDefaults : NSObject

// Server URL hosting the printer lists
@property (copy, nonatomic) NSString *ServerURL;

// Array of currently installed printers. Primairly used for persistance between launches.
@property (copy, nonatomic) NSArray *CurrentPrinters;

// The Host name of the host providing a subscription printer list
@property (copy, nonatomic) NSString *SubscriptionHost;

// readonly: SubscriptionHost appended by a "subscribe" path component
@property (copy, nonatomic, readonly) NSString *SubscriptionURL;

// Should the client track subscription printers?
@property (nonatomic) BOOL Subscribe;

// Should bonjour printers be displayed?
@property (nonatomic) BOOL ShowBonjourPrinters;

// The base defaults object
@property (copy, readonly) NSUserDefaults *defaults;

@end
