//
//  TestViewController.m
//  Stream
//
//  Created by Static Ga on 14-9-18.
//  Copyright (c) 2014年 Static Ga. All rights reserved.
//

#import "TestViewController.h"
#import "SocketEngine.h"

@interface TestViewController ()

@property (nonatomic, strong) SocketEngine *engine;
@property (weak, nonatomic) IBOutlet UILabel *readLen;
@property (weak, nonatomic) IBOutlet UILabel *totalLen;

- (IBAction)connect:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)readData:(id)sender;

@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.engine = [[SocketEngine alloc] initWithHostAddress:@"towel.blinkenlights.nl" andPort:23];
    
    __weak typeof(self) weakSelf = self;
    [self.engine setReadProgressBlock:^(unsigned int bytesReading, NSUInteger totalBytesReading) {
        weakSelf.readLen.text = [NSString stringWithFormat:@"%d",bytesReading];
        weakSelf.totalLen.text = [NSString stringWithFormat:@"%d",totalBytesReading];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connect:(id)sender {
    [self.engine connect];
}

- (IBAction)send:(id)sender {
}

- (IBAction)readData:(id)sender {
}
@end
