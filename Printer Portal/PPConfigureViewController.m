//
//  PPConfigureViewController.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPConfigureViewController.h"
#import "PPListManager.h"
#import "PPConfigureViewModel.h"
#import "PPDefaults.h"

#import "NSTextField+AnimatedString.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PPConfigureViewController ()
@property (weak) IBOutlet NSTextField *serverURL_textField;
@property (weak) IBOutlet NSTextField *errorMessage_textField;
@property (weak) IBOutlet NSButton *serverSet_button;
@property (weak) IBOutlet NSButton *launchAtLogin_button;
@property (weak) IBOutlet NSButton *subscribe_button;
@property (weak) IBOutlet NSButton *showBonjourPrinters_button;

@property (strong) PPConfigureViewModel *viewModel;
@property (strong) PPListManager *listManager;

@end

@implementation PPConfigureViewController

- (instancetype)init_ {
    if (self = [super initWithNibName:[self className] bundle:nil]) {
        // Do setup
    }
    return self;
}

- (instancetype)initWithViewModel:(PPConfigureViewModel *)viewModel {
    if (self = [self init_]) {
        _viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)awakeFromNib {
    if (_viewModel) {
        // Set up error bindings.
        /* Skip 1 for the error signal since it always starts as nil */
        RACSignal *errorSignal = [RACObserve(_viewModel, uiError) skip:1];

        RAC(self.errorMessage_textField, stringValue, @"") =
            [errorSignal map:^NSString *(NSError *error) {
                return error.localizedDescription
                           ?: NSLocalizedString(@"Successfully updated printer list.",
                                                @"Config pannel message when a valid response was "
                                                @"received from the server");
            }];

        RAC(self.errorMessage_textField, fadeOut_string) = [errorSignal map:^id(NSError *error) {
            return @(error.code == 0);
        }];

        RAC(self.serverURL_textField, textColor) = [errorSignal map:^id(NSError *error) {
            return (error.code == 0) ? [NSColor controlTextColor] : [NSColor redColor];
        }];

        // Server Text field
        self.serverURL_textField.stringValue = [[PPDefaults new] ServerURL];
        RAC(_viewModel, serverURL) = self.serverURL_textField.rac_textSignal;
        @weakify(self);
        self.serverSet_button.rac_command =
            [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
                @strongify(self);
                return [self.viewModel configurePrinterListSignal];
            }];

        // Subscribe.
        RAC(self.subscribe_button, state) = RACObserve(self.viewModel, subscriptionEnabled);
        self.subscribe_button.rac_command =
            [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
                @strongify(self);
                [self.viewModel enableSubscription];
                return [RACSignal empty];
            }];

        // Bonjour.
        RAC(self.showBonjourPrinters_button, state) = RACObserve(self.viewModel, bonjourEnabled);
        self.showBonjourPrinters_button.rac_command =
            [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
                @strongify(self);
                [self.viewModel enableBonjourPrinters];
                return [RACSignal empty];
            }];

        // Launch At login.
        RAC(self.launchAtLogin_button, state) = RACObserve(self.viewModel, launchAtLoginEnabled);
        self.launchAtLogin_button.rac_command =
            [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
                @strongify(self);
                [self.viewModel launchAtLogin];
                return [RACSignal empty];
            }];

        if (_controllingPopover) {
            self.closeConfigWindow_button.target = _controllingPopover;
            self.closeConfigWindow_button.action = @selector(close);
        }
    }
}

@end
