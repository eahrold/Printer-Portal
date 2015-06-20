//
//  PPStatusItemView.h
//  Printer Portal
//
//  Created by Eldon on 6/20/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PPStatusItemView : NSView  <NSMenuDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithStatusMenu:(NSStatusItem *)statusItem menu:(NSMenu *)menu;

- (void)setActive:(BOOL)active;

@end
