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
{
    CGRect _scanLineFrame;
}
@property (weak, nonatomic) IBOutlet LJReadQRCodeView *readQRCodeView;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeScanLine;

@property (weak, nonatomic) IBOutlet UIImageView *border1;
@property (weak, nonatomic) IBOutlet UIImageView *border2;
@property (weak, nonatomic) IBOutlet UIImageView *border3;
@property (weak, nonatomic) IBOutlet UIImageView *border4;
@property (weak, nonatomic) IBOutlet UILabel *result;
@property (strong, nonatomic)NSTimer *time;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _scanLineFrame = self.QRCodeScanLine.frame;
    _time = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(moveScanLine) userInfo:nil repeats:YES];
}
- (void)moveScanLine {
    
    __weak typeof(self)wSelf = self;
    [UIView animateWithDuration:4 animations:^{
        [wSelf.QRCodeScanLine setFrame:CGRectMake(_scanLineFrame.origin.x, _scanLineFrame.origin.y+wSelf.readQRCodeView.bounds.size.height, _scanLineFrame.size.width, _scanLineFrame.size.height)];
    } completion:^(BOOL finished) {
        [wSelf.QRCodeScanLine setFrame:_scanLineFrame];
        [wSelf.time fire];
    }];
    
}
- (void)setBorderWithSetHidden:(BOOL)idHidden {
    [self.border1 setHidden:idHidden];
    [self.border2 setHidden:idHidden];
    [self.border3 setHidden:idHidden];
    [self.border4 setHidden:idHidden];
}
- (IBAction)scanning:(UIButton *)sender {
    [self.readQRCodeView setHidden:NO];
    [self setBorderWithSetHidden:NO];
    [_time fire];
    [self.readQRCodeView readQRCode];
    [self.readQRCodeView setDelegate:self];
}

- (void)readQRCodeView:(LJReadQRCodeView *)readQRCodeView result:(NSString *)result
{
    [readQRCodeView setHidden:YES];
    [self setBorderWithSetHidden:YES];
    if (_time) {
        [_time invalidate];
        _time = nil;
    }
    self.result.text = result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_time) {
        [_time invalidate];
        _time = nil;
    }
}
@end
