//
//  PPStatusItem.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPStatusItem.h"
#import "PPPrinterManager.h"
#import "PPConfigureViewController.h"

#import <Objective-CUPS/OCPrinter.h>

static const NSInteger PPMenuItemNotFound = -1;

@interface PPStatusItem ()<NSPopoverDelegate>
@end

static NSRect statusBarRect(){
    float ImageViewWidth = 22;
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    return NSMakeRect(0, 0, ImageViewWidth, height);
}

typedef NS_OPTIONS(NSInteger, PPMenuTags) {
    kPPMenuSubMenuTag_bonjour = 100 << 1,
    kPPMenuSeperatorTag_primary = 100 << 10,
    kPPMenuSeperatorTag_bonjour = 100 << 11,
    kPPMenuSeperatorTag_quit = 100 << 12,
};

@implementation PPStatusItem {
    NSStatusItem *_statusItem;
    PPPrinterManager *_printerManager;
    NSImageView *_imageView;
    BOOL          _active;

}


- (instancetype)init_{

    if (self = [super initWithFrame:statusBarRect()]) {
        _imageView = [[NSImageView alloc] initWithFrame:self.frame];
        _imageView.image = [NSImage imageNamed:@"StatusBarIcon"];
        [self addSubview:_imageView];

        _statusItem = [[NSStatusBar systemStatusBar]
                       statusItemWithLength:NSVariableStatusItemLength];

        _statusItem.menu = [[NSMenu alloc] init];
        _statusItem.menu.delegate = self;
        _statusItem.image = _imageView.image;

        _statusItem.view = self;

        [self setActive:NO];

    }
    return self;
}

- (instancetype)initWithPrinterManager:(PPPrinterManager *)manager {
    NSParameterAssert(manager);
    if (self = [self init_]) {
        _printerManager = manager;

        NSMenuItem *configureItem = [[NSMenuItem alloc] init];
        configureItem.title =
            NSLocalizedString(@"Configure...", @"Menu item title");
        configureItem.action = @selector(displayConfigurationView:);
        configureItem.target = self;
        
        NSMenuItem *checkForUpdatesItem = [[NSMenuItem alloc] init];
        checkForUpdatesItem.title =
            NSLocalizedString(@"Check for updates", @"Menu item title");

        // Add first separator
        NSMenuItem *primarySeparator = [NSMenuItem separatorItem];
        primarySeparator.tag = kPPMenuSeperatorTag_primary;

        // Add second separator
        NSMenuItem *quitSeparator = [NSMenuItem separatorItem];
        quitSeparator.tag = kPPMenuSeperatorTag_quit;

        NSMenuItem *quitMenuItem = [[NSMenuItem alloc] init];
        quitMenuItem.title =
            NSLocalizedString(@"Quit", @"Menu item title");
        quitMenuItem.target = [NSApplication sharedApplication];
        quitMenuItem.action = @selector(terminate:);

        [_statusItem.menu addItem:configureItem];
        [_statusItem.menu addItem:checkForUpdatesItem];
        [_statusItem.menu addItem:primarySeparator];

        [_statusItem.menu addItem:quitSeparator];
        [_statusItem.menu addItem:quitMenuItem];
    }
    return self;
}

#pragma mark - NSView
- (NSMenu *)menuForEvent:(NSEvent *)theEvent {
    NSLog(@"%@", theEvent);
    return _statusItem.menu;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"%@", theEvent);

    [self setActive:YES];
    [_statusItem popUpStatusItemMenu:_statusItem.menu];

}
- (void)mouseUp:(NSEvent *)theEvent {
    [self setActive:NO];
}

- (void)setActive:(BOOL)active {
    _active = active;
    self.needsDisplay = YES;
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

#pragma mark - Menu delegate
- (void)menuDidClose:(NSMenu *)menu {
    [self setActive:NO];
}

- (void)menuWillOpen:(NSMenu *)menu {
    [self setActive:YES];
}

#pragma mark - Printer Lists UI
- (void)setPrinterList:(NSArray *)printerList {
    [self removePrimaryPrinters];

    _printerList = printerList;
    NSInteger insertionPoint =
        [_statusItem.menu indexOfItemWithTag:kPPMenuSeperatorTag_primary] + 1;

    if (printerList.count) {
        for (OCPrinter *printer in printerList) {
            NSMenuItem *item = [self baseMenuItemForPrinter:printer];
            [_statusItem.menu insertItem:item atIndex:insertionPoint];
            insertionPoint++;

            // Add in the details
            NSMenu *details = [[NSMenu alloc] init];
            [details addItemWithTitle:printer.name
                               action:nil
                        keyEquivalent:@""];
            [details addItemWithTitle:printer.host
                               action:nil
                        keyEquivalent:@""];

            if (printer.description.length) {
                [details addItemWithTitle:printer.description
                                   action:nil
                            keyEquivalent:@""];
            }
            if (printer.location.length) {
                [details addItemWithTitle:printer.location
                                   action:nil
                            keyEquivalent:@""];
            }

            [_statusItem.menu setSubmenu:details forItem:item];
        }
    } else {
        NSString *emptyListTitle = NSLocalizedString(
            @"No printers available", @"Menu item title when no items in list");

        [_statusItem.menu insertItemWithTitle:emptyListTitle
                                       action:nil
                                keyEquivalent:@""
                                      atIndex:insertionPoint];
    }
}

- (void)setBonjourPrinterList:(NSArray *)bonjourPrinterList {
    _bonjourPrinterList = bonjourPrinterList;

    // Setup bonjour printer list...
    NSMenuItem *bonjourMenu =
        [_statusItem.menu itemWithTag:kPPMenuSubMenuTag_bonjour];

    if (!bonjourMenu) {
        bonjourMenu = [[NSMenuItem alloc] init];
        bonjourMenu.tag = kPPMenuSubMenuTag_bonjour;
        bonjourMenu.title = @"Bonjour Priters";

        NSInteger insertion = [self primaryPrintersEndingIndex];
        [_statusItem.menu insertItem:bonjourMenu atIndex:insertion];

        NSMenuItem *bonjourSeparator = [NSMenuItem separatorItem];
        bonjourSeparator.tag = kPPMenuSeperatorTag_bonjour;

        [_statusItem.menu insertItem:bonjourSeparator atIndex:insertion++];
    }

    NSMenu *bonjourSubmenu = [[NSMenu alloc] init];
    for (OCPrinter *printer in bonjourPrinterList) {
        [bonjourSubmenu addItem:[self baseMenuItemForPrinter:printer]];
    }

    [_statusItem.menu setSubmenu:bonjourSubmenu forItem:bonjourMenu];
}


#pragma mark - Config view
- (void)displayConfigurationView:(id)sender {
    PPConfigureViewController *controller = [PPConfigureViewController new];
    NSPopover *popover = [[NSPopover alloc] init];
    popover.contentViewController = controller;
    popover.delegate = self;

    popover.behavior = NSPopoverBehaviorTransient;
    [popover showRelativeToRect:self.frame
                         ofView:self
                  preferredEdge:NSMaxYEdge];

    [self setActive:YES];
}

- (void)popoverDidClose:(NSNotification *)notification {
    [self setActive:NO];
}

#pragma mark - Util
- (void)removePrimaryPrinters {
    NSInteger start;
    NSInteger stop;

    start =[_statusItem.menu indexOfItemWithTag:kPPMenuSeperatorTag_primary] + 1;
    stop = [_statusItem.menu indexOfItemWithTag:kPPMenuSeperatorTag_bonjour];

    if (stop == PPMenuItemNotFound) {
        stop = [_statusItem.menu indexOfItemWithTag:kPPMenuSeperatorTag_quit];
    }

    /* Since we're removing items from the status menu
     * we we want to use the `start` index x number of times
     * not remove the item at index i */
    for (NSInteger i = start; i < stop; i++) {
        [_statusItem.menu removeItemAtIndex:start];
    }
}

- (NSInteger)primaryPrintersEndingIndex {
    return ([_statusItem.menu indexOfItemWithTag:kPPMenuSeperatorTag_primary] +
            _printerList.count + 1);
}

- (NSMenuItem *)baseMenuItemForPrinter:(OCPrinter *)printer {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    item.title = printer.description ?: printer.name;
    item.representedObject = printer;
    item.target = _printerManager;
    item.action = @selector(changePrinterState:);
    return item;
}


@end

@implementation NSWindow (canBecomeKeyWindow)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (BOOL)canBecomeKeyWindow
{
    if([self class]==NSClassFromString(@"NSStatusBarWindow")){
        return YES;
    }
    return NO;
}
#pragma clang diagnostic pop


@end
