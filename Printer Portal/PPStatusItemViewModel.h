//
//  PPStatuItemViewModel.h
//  Printer Portal
//
//  Created by Eldon on 6/21/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PPPrinterManager, PPListManager;

@interface PPStatusItemViewModel : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPrinterManager:(PPPrinterManager *)printerManager
                           listManager:(PPListManager *)listManager;

@property (strong, nonatomic, readonly) PPPrinterManager *printerManager;
@property (strong, nonatomic, readonly) PPListManager *listManager;

@property (copy, nonatomic, readonly) NSArray *printerList;
@property (copy, nonatomic, readonly) NSArray *bonjourPrinterList;

@end
