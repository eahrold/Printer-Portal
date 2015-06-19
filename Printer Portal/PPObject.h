//
//  PPObject.h
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPErrorHandler.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PPObject : NSObject
@property (strong) PPErrorHandler *errorHandler;
@end
