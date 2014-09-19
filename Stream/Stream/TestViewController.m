//
//  TestViewController.m
//  Stream
//
//  Created by Static Ga on 14-9-18.
//  Copyright (c) 2014年 Static Ga. All rights reserved.
//

#import "TestViewController.h"
#import "SocketEngine.h"

#define kTestHost @"towel.blinkenlights.nl"
#define kTestPort 23

@interface TestViewController ()

@property (nonatomic, strong) SocketEngine *engine;
@property (weak, nonatomic) IBOutlet UILabel *readLen;
@property (weak, nonatomic) IBOutlet UILabel *totalLen;

- (IBAction)connect:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)readData:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *testImageView;

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
    self.engine = [[SocketEngine alloc] initWithHostAddress:kTestHost andPort:kTestPort];
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
    NSURL *url = [NSURL URLWithString:@"http://f.hiphotos.baidu.com/image/w%3D230/sign=9bfd80e39352982205333ec0e7cb7b3b/b17eca8065380cd74cfd1ec9a244ad3459828137.jpg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data) {
        NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/temp"];
        [data writeToFile:path atomically:YES];
        
        [self.engine sendNetworkPacket:data];
    }
}
@end
