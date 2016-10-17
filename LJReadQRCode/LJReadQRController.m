//
//  LJReadQRController.m
//  LJReadQRCode
//
//  Created by liujunjie on 15-6-3.
//  Copyright (c) 2015年 rj. All rights reserved.
//

#import "LJReadQRController.h"

#import <AVFoundation/AVFoundation.h>

@interface LJReadQRController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (strong, nonatomic) AVCaptureSession *session;

@property (weak, nonatomic) IBOutlet UIView *qrView;

@property (weak, nonatomic) IBOutlet UIImageView *scanLineImgView;

@property (weak, nonatomic) IBOutlet UILabel *result;

@end

@implementation LJReadQRController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self moveScanLine];
    [self readQRCode];
}

- (void)moveScanLine {
    CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
    scanNetAnimation.keyPath = @"transform.translation.y";
    scanNetAnimation.byValue = @(300);
    scanNetAnimation.duration = 2.0;
    scanNetAnimation.repeatCount = MAXFLOAT;
    [self.scanLineImgView.layer addAnimation:scanNetAnimation forKey:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)readQRCode {
    // 1. 摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 2. 设置输入
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    // 2.1 判断是否有摄像头
    if (error) {
        NSLog(@"没有找到摄像头%@",error);
        return;
    }
    // 3. 设置输出（Metadata元数据）
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    CGSize size = self.qrView.bounds.size;
    CGRect cropRect = CGRectMake((size.width - 300) * 0.5, (size.height - 300 - self.qrView.frame.origin.y) * 0.5, 300, 300);
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = size.width * 1920./1080.;
        CGFloat fixPadding = (fixHeight - size.height)*0.5;
        output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                           cropRect.origin.x/size.width,
                                           cropRect.size.height/fixHeight,
                                           cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                           (cropRect.origin.x + fixPadding)/fixWidth,
                                           cropRect.size.height/size.height,
                                           cropRect.size.width/fixWidth);
    }
    // 3.1 设置输出代理
    // 说明：使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 4. 拍照会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    //4.1高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    // 4.2 添加session的输入和输出
    [session addInput:input];
    [session addOutput:output];
    // 4.3 设置输出格式,扫码支持的编码格式(如下设置条形码和二维码兼容)
    // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
    //5. 设置预览图层（用来让用户能够看到扫描情况）
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    // 5.1 设置preview图层的属性
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    // 5.2 设置preview图层的大小
    [previewLayer setFrame:self.qrView.bounds];
    // 5.3 将图层添加到视图的图层
    [self.qrView.layer insertSublayer:previewLayer atIndex:0];
    _previewLayer = previewLayer;
    //5.4 加中空蒙版
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.fillColor = [UIColor colorWithWhite:0.0 alpha:0.7].CGColor;
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.qrView.bounds);
    CGPathAddRect(path, NULL, cropRect);
    shapeLayer.path = path;
    CGPathRelease(path);
    [self.qrView.layer addSublayer:shapeLayer];
    
    // 6. 启动会话
    [session startRunning];
    _session = session;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

// 此方法是在识别到QRCode，并且完成转换
// 如果QRCode的内容越大，转换需要的时间就越长
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 会频繁的扫描，调用代理方法
    // 1. 如果扫描完成，停止会话
    [_session stopRunning];
    // 2. 删除预览图层
    [_previewLayer removeFromSuperlayer];
    // 3. 设置界面显示扫描结果
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        // 提示：如果需要对url或者名片等信息进行扫描，可以在此进行扩展！
        // 停止线动画
        [self.scanLineImgView.layer removeAllAnimations];
        // 结果
        self.result.text = obj.stringValue;
        
    }
}

@end
