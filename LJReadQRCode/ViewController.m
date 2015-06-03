//
//  ViewController.m
//  LJReadQRCode
//
//  Created by liujunjie on 15-6-3.
//  Copyright (c) 2015年 rj. All rights reserved.
//

#import "ViewController.h"
#import "LJReadQRCodeView.h"
@interface ViewController ()<LJReadQRCodeViewDelegate>
@property (weak, nonatomic) IBOutlet LJReadQRCodeView *readQRCodeView;
@property (weak, nonatomic) IBOutlet UILabel *result;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)scanning:(UIButton *)sender {
    [self.readQRCodeView setHidden:NO];
    [self.readQRCodeView readQRCode];
    [self.readQRCodeView setDelegate:self];
}

- (void)readQRCodeView:(LJReadQRCodeView *)readQRCodeView result:(NSString *)result
{
    [readQRCodeView setHidden:YES];
    self.result.text = result;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
