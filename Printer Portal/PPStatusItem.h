//
//  PPStatusItem.h
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PPObject.h"
@class PPPrinterManager;

@interface PPStatusItem : NSObject <NSMenuDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPrinterManager:(PPPrinterManager *)manager;

// Array of OCPrinters
@property (strong, nonatomic) NSArray *printerList;
@property (strong, nonatomic) NSArray *bonjourPrinterList;
@end
