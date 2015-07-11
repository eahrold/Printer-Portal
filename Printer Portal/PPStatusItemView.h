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
@class PPStatusItemViewModel;

@interface PPStatusItemView : NSObject<NSMenuDelegate>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype) new NS_UNAVAILABLE;

- (instancetype)initWithViewModel:(PPStatusItemViewModel *)viewModel;

@end
