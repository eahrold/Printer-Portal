//
//  PPDefaults.h
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPDefaults : NSObject

@property (copy, nonatomic) NSString *ServerURL;
@property (copy, nonatomic) NSArray *CurrentPrinters;
@property (nonatomic) BOOL Subscribe;
@property (nonatomic) BOOL ShowBonjourPrinters;

@property (copy, readonly) NSUserDefaults *defaults;

@end
