//
//  PPStatusItemView.m
//  Printer Portal
//
//  Created by Eldon on 6/20/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPStatusItemView.h"
#import "PPStatusItem.h"

    static NSRect statusBarRect(){
        float ImageViewWidth = 22;
        CGFloat height = [NSStatusBar systemStatusBar].thickness;
        return NSMakeRect(0, 0, ImageViewWidth, height);
    }

    @implementation PPStatusItemView {
        NSStatusItem *_statusItem;
        NSMenu *_menu;

        BOOL _active;
    }

    - (instancetype)initWithStatusMenu:(NSStatusItem *)statusItem menu:(NSMenu *)menu {
        if (self = [super initWithFrame:statusBarRect()]) {
            _statusItem = statusItem;
            _menu = menu;
            _menu.delegate = self;

            NSImageView *imageView = [[NSImageView alloc] initWithFrame:self.frame];
            imageView.image = [NSImage imageNamed:@"StatusBarIcon"];
            [self addSubview:imageView];
        }
        return self;
    }

    - (void)drawRect:(NSRect)dirtyRect
    {
        if (_active) {
            [[NSColor selectedMenuItemColor] setFill];
            NSRectFill(dirtyRect);
        } else {
            [[NSColor clearColor] setFill];
            NSRectFill(dirtyRect);
        }
    }

    - (void)mouseDown:(NSEvent *)theEvent
    {
        [self setActive:YES];
        NSLog(@"is active %d \n%@", _active , theEvent);
        [_statusItem popUpStatusItemMenu:_menu];
    }

    - (void)setActive:(BOOL)active
    {
        _active = active;
        [self setNeedsDisplay:YES];
    }

    - (void)menuDidClose:(NSMenu *)menu {
        [self setActive:NO];
    }



@end
