//
//  PPConfigureViewModel.h
//  Printer Portal
//
//  Created by Eldon on 6/22/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSPopover;

@interface PPConfigureViewModel : NSObject

@property (assign, nonatomic) BOOL bonjourListEnabled;
@property (assign, nonatomic) BOOL subscriptionEnabled;
@property (assign, nonatomic) BOOL launchAtLoginEnabled;

@property (copy, nonatomic) NSString *serverURL;

@property (copy, nonatomic) NSString *errorMessage;

@property (weak) NSPopover *controllingPopover;
@end
