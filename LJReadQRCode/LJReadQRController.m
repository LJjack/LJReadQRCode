//
//  LJReadQRController.m
//  LJReadQRCode
//
//  Created by liujunjie on 15-6-3.
//  Copyright (c) 2015年 rj. All rights reserved.
//

#import "LJReadQRController.h"
#import "LJReadQRCodeView.h"

@interface LJReadQRController ()<LJReadQRCodeViewDelegate>

@property (weak, nonatomic) IBOutlet LJReadQRCodeView *readQRCodeView;

@property (weak, nonatomic) IBOutlet UIView *centerView;

@property (weak, nonatomic) IBOutlet UIImageView *scanLineImgView;

@property (weak, nonatomic) IBOutlet UILabel *result;

@end

@implementation LJReadQRController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.readQRCodeView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self moveScanLine];
    [self.readQRCodeView readQRCode];
}

- (void)moveScanLine {
    CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
    scanNetAnimation.keyPath = @"transform.translation.y";
    scanNetAnimation.byValue = @(300);
    scanNetAnimation.duration = 2.0;
    scanNetAnimation.repeatCount = MAXFLOAT;
    [self.scanLineImgView.layer addAnimation:scanNetAnimation forKey:nil];
    
}

- (void)readQRCodeView:(LJReadQRCodeView *)readQRCodeView result:(NSString *)result {
    [self.scanLineImgView.layer removeAllAnimations];
    
    self.result.text = result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
