//
//  PPStatuItemViewModel.m
//  Printer Portal
//
//  Created by Eldon on 6/21/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPStatusItemViewModel.h"
#import "PPStatusItemView.h"
#import "PPPrinterManager.h"
#import "PPListManager.h"

@interface PPStatusItemViewModel ()
@property (copy, nonatomic, readwrite) NSArray *printerList;
@property (copy, nonatomic, readwrite) NSArray *bonjourPrinterList;
@end

@implementation PPStatusItemViewModel {
    PPStatusItemView *_view;
}

- (instancetype)initWithPrinterManager:(PPPrinterManager *)printerManager
                           listManager:(PPListManager *)listManager {
    NSParameterAssert(printerManager);
    NSParameterAssert(listManager);
    if (self = [super init]) {
        _printerManager = printerManager;
        _listManager = listManager;
        _view = [[PPStatusItemView alloc] initWithViewModel:self];

        RAC(self, printerList) = _listManager.printerListSignal;
        RAC(self, bonjourPrinterList) = _listManager.bonjourListSignal;
    }
    return self;
}

@end
