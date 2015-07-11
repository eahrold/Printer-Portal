//
//  PPStatusItem.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPStatusItemView.h"
#import "PPStatusItemViewModel.h"

#import "PPConfigureViewController.h"
#import "PPConfigureViewModel.h"

#import <Objective-CUPS/OCPrinter.h>

static const NSInteger PPMenuItemNotFound = -1;

@interface PPStatusItemView ()<NSPopoverDelegate>
@property (strong, nonatomic) PPStatusItemViewModel *viewModel;
@property (nonatomic) NSInteger primaryPrintersEndingIndex;
@end

typedef NS_OPTIONS(NSInteger, PPMenuTags) {
    kPPMenuSubMenuTag_bonjour = 100 << 1,
    kPPMenuSeperatorTag_primary = 100 << 10,
    kPPMenuSeperatorTag_bonjour = 100 << 11,
    kPPMenuSeperatorTag_quit = 100 << 12,
};

@implementation PPStatusItemView {
    NSStatusItem *_statusItem;
    NSButton *__button;
}

- (instancetype)init_ {
    if (self = [super init]) {
        _statusItem =
            [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

        _statusItem.image = [NSImage imageNamed:@"StatusBarIcon"];
        _statusItem.highlightMode = YES;

        // We've got to access a private property here to
        // present the popver against a view
        __button = [_statusItem valueForKey:@"_button"];

        _statusItem.menu = [[NSMenu alloc] init];
        _statusItem.menu.delegate = self;
    }
    return self;
}

- (instancetype)initWithViewModel:(PPStatusItemViewModel *)viewModel {
    NSParameterAssert(viewModel);
    if (self = [self init_]) {
        _viewModel = viewModel;

        NSMenuItem *configureItem = [[NSMenuItem alloc] init];
        configureItem.title = NSLocalizedString(@"Configure...", @"Status item menu title");
        configureItem.action = @selector(displayConfigurationView:);
        configureItem.target = self;

        NSMenuItem *checkForUpdatesItem = [[NSMenuItem alloc] init];
        checkForUpdatesItem.title =
            NSLocalizedString(@"Check for updates", @"Status item menu title");

        // Add first separator
        NSMenuItem *primarySeparator = [NSMenuItem separatorItem];
        primarySeparator.tag = kPPMenuSeperatorTag_primary;

        // Add second separator
        NSMenuItem *quitSeparator = [NSMenuItem separatorItem];
        quitSeparator.tag = kPPMenuSeperatorTag_quit;

        NSMenuItem *quitMenuItem = [[NSMenuItem alloc] init];
        quitMenuItem.title = NSLocalizedString(@"Quit", @"Status item menu title");
        quitMenuItem.target = [NSApplication sharedApplication];
        quitMenuItem.action = @selector(terminate:);

        [_statusItem.menu addItem:configureItem];
        [_statusItem.menu addItem:checkForUpdatesItem];
        [_statusItem.menu addItem:primarySeparator];

        [_statusItem.menu addItem:quitSeparator];
        [_statusItem.menu addItem:quitMenuItem];

        [self bindPrinterList];
        [self bindBonjourPrinterList];
    }
    return self;
}

#pragma mark - Printer Lists UI
- (void)bindPrinterList {
    RACSignal *printerListSignal = RACObserve(self.viewModel, printerList);
    @weakify(self);

    RAC(self, primaryPrintersEndingIndex) = [printerListSignal map:^NSNumber *(NSArray *list) {
        return
            @([_statusItem.menu indexOfItemWithTag:kPPMenuSeperatorTag_primary] + list.count + 1);
    }];

    [[printerListSignal subscribeOn:[RACScheduler mainThreadScheduler]]
        subscribeNext:^(NSArray *printerList) {
            @strongify(self);
            [self removePrimaryPrinters];

            NSInteger insertionPoint =
                [_statusItem.menu indexOfItemWithTag:kPPMenuSeperatorTag_primary] + 1;

            if (printerList.count) {
                for (OCPrinter *printer in printerList) {
                    NSMenuItem *item = [self baseMenuItemForPrinter:printer];

                    [_statusItem.menu insertItem:item atIndex:insertionPoint];
                    insertionPoint++;

                    // Add in the details
                    NSMenu *details = [[NSMenu alloc] init];
                    [details addItemWithTitle:printer.name action:nil keyEquivalent:@""];

                    [details addItemWithTitle:printer.host action:nil keyEquivalent:@""];

                    if (printer.description.length) {
                        [details addItemWithTitle:printer.description action:nil keyEquivalent:@""];
                    }
                    if (printer.location.length) {
                        [details addItemWithTitle:printer.location action:nil keyEquivalent:@""];
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
        }];
}

- (void)bindBonjourPrinterList {
    [[RACObserve(self.viewModel, bonjourPrinterList) subscribeOn:[RACScheduler mainThreadScheduler]]
        subscribeNext:^(NSArray *bonjourPrinterList) {
            // Setup bonjour printer list...
            NSMenuItem *bonjourMenu = [_statusItem.menu itemWithTag:kPPMenuSubMenuTag_bonjour];
            if (bonjourPrinterList == nil) {
                if (bonjourMenu) {
                    NSInteger index = [_statusItem.menu indexOfItem:bonjourMenu];
                    for (int i = 0; i < 2; i++) {
                        [_statusItem.menu removeItemAtIndex:index];
                    }
                }
                return;
            }

            if (!bonjourMenu) {
                bonjourMenu = [[NSMenuItem alloc] init];
                bonjourMenu.tag = kPPMenuSubMenuTag_bonjour;
                bonjourMenu.title =
                    NSLocalizedString(@"Bonjour Printers", @"Title of bonjour printer menu item");

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
        }];
}

#pragma mark - Config view
- (void)displayConfigurationView:(id)sender {
    NSPopover *popover = [[NSPopover alloc] init];

    PPConfigureViewModel *viewModel =
        [[PPConfigureViewModel alloc] initWithListManager:_viewModel.listManager];

    PPConfigureViewController *controller =
        [[PPConfigureViewController alloc] initWithViewModel:viewModel];

    controller.controllingPopover = popover;
    popover.contentViewController = controller;
    popover.delegate = self;

#ifndef DEBUG
    // TODO: uncomment next line
    popover.behavior = NSPopoverBehaviorTransient;
#endif

    [popover showRelativeToRect:__button.frame ofView:__button preferredEdge:NSMaxYEdge];
}

- (void)popoverDidClose:(NSNotification *)notification {
    __button.enabled = NO;
    __button.enabled = YES;
}

#pragma mark - Util
- (void)removePrimaryPrinters {
    NSInteger start;
    NSInteger stop;

    start = [_statusItem.menu indexOfItemWithTag:kPPMenuSeperatorTag_primary] + 1;
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

- (NSMenuItem *)baseMenuItemForPrinter:(OCPrinter *)printer {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    item.title = printer.description ?: printer.name;
    item.representedObject = printer;
    item.target = _viewModel.printerManager;
    item.action = @selector(changePrinterState:);
    item.state = printer.isInstalled;
    return item;
}

@end
