//
//  PPConfigureViewController.h
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RACSignal;
@interface PPConfigureViewController : NSViewController

@property (copy, nonatomic, readonly) RACSignal *subscribeEnabledSignal;
@property (copy, nonatomic, readonly) RACSignal *serverURLSignal;
@property (copy, nonatomic, readonly) RACSignal *enableBonjourEnabledSignal;
@property (copy, nonatomic, readonly) RACSignal *launchAtLoginEnabledSignal;


@end
