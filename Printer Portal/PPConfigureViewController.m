//
//  PPConfigureViewController.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPConfigureViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PPDefaults.h"

@interface PPConfigureViewController ()

@property (weak) IBOutlet NSTextField* serverURL_textField;
@property (weak) IBOutlet NSButton* serverSet_button;


@end

@implementation PPConfigureViewController

- (instancetype)init {
    if (self = [super initWithNibName:[self className] bundle:nil]) {
        // Do setup
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)awakeFromNib {
    PPDefaults *defaults = [PPDefaults new];
    self.serverURL_textField.stringValue = defaults.ServerURL;

    RACChannelTerminal *defaultsTerminal = [defaults.defaults rac_channelTerminalForKey:@"ServerURL"];
    @weakify(self);
    self.serverSet_button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
//        [defaultsTerminal sendNext:self.serverURL_textField.stringValue];
        defaults.ServerURL = self.serverURL_textField.stringValue;
        return [RACSignal empty];
    }];
}

@end
