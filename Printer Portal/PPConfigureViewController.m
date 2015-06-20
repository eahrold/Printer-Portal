//
//  PPConfigureViewController.m
//  Printer Portal
//
//  Created by Eldon on 6/19/15.
//  Copyright (c) 2015 Eldon Ahrold. All rights reserved.
//

#import "PPConfigureViewController.h"
#import "PPDefaults.h"
#import "PPRequestManager.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PPConfigureViewController ()

@property (weak) IBOutlet NSTextField* serverURL_textField;
@property (weak) IBOutlet NSTextField* errorMessage_textField;

@property (weak) IBOutlet NSButton* serverSet_button;

@property(nonatomic, strong) RACSignal *urlValidSignal;

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

    if (_controllingPopover) {
        self.closeConfigWindow_button.target = _controllingPopover;
        self.closeConfigWindow_button.action = @selector(close);
    }

    RACCommand *serverCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [self testURLSignal];
    }];

    self.serverSet_button.rac_command = serverCommand;


    RAC(self.errorMessage_textField, stringValue, @"") = [serverCommand.errors map:^NSString *(NSError *error) {
        return error.localizedDescription;
    }];

    RAC(self.errorMessage_textField, textColor, [NSColor controlTextColor]) = [serverCommand.errors map:^NSColor *(NSError *error) {
        return error ? [NSColor redColor] : [NSColor blackColor];
    }];

    [serverCommand.executionSignals subscribeNext:^(RACSignal *signal) {
        [[signal  filter:^BOOL(id value) {
            //
            return YES;
        } ] subscribeNext:^(NSDictionary *dict) {
            //
            NSLog(@"got dict");
        } completed:^{
            NSLog(@"complete");
        }];
    } error:^(NSError *error) {
        NSLog(@"EXESig Error %@", error);
    }];


}

- (RACSignal *)testURLSignal {
    return  [[RACSignal startLazilyWithScheduler:[RACScheduler scheduler] block:^(id<RACSubscriber> subscriber) {

        [[PPRequestManager manager] GET:self.serverURL_textField.stringValue parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [subscriber sendNext:responseObject];
            [subscriber sendError:nil];
            [subscriber sendCompleted];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [subscriber sendError:error];
            [subscriber sendCompleted];
        }];
    }] deliverOnMainThread];
}

- (RACSignal *)urlValidSignal {
    if (!_urlValidSignal) {
        _urlValidSignal = RACObserve(self.serverURL_textField, stringValue);
    }
    return _urlValidSignal;
    
}
@end
