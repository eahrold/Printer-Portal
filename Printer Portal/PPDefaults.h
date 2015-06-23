//
//  PPDefaults.h
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kPPDefaultsKey_subscribe;
extern NSString *const kPPDefaultsKey_unsubscribe;

@interface PPDefaults : NSObject

@property (copy, nonatomic) NSString *ServerURL;
@property (copy, nonatomic) NSArray *CurrentPrinters;
@property (nonatomic) BOOL Subscribe;
@property (copy, nonatomic) NSString *SubscriptionHost;
@property (copy, nonatomic, readonly) NSString *SubscriptionURL;

@property (nonatomic) BOOL ShowBonjourPrinters;

@property (copy, readonly) NSUserDefaults *defaults;

@end
