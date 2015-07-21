//
//  PPObject.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPObject.h"

@implementation PPObject

- (instancetype)init {
    if (self = [super init]) {
        _errorHandler = [PPErrorHandler sharedErrorHandler];
    }
    return self;
}
@end
