//
//  PPConfigureViewController.h
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RACSignal, PPListManager;
@interface PPConfigureViewController : NSViewController

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithListManager:(PPListManager *)manager;

@property (weak) IBOutlet NSButton *closeConfigWindow_button;
@property (weak) NSPopover *controllingPopover;

@end
