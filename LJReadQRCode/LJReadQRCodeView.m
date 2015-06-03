//
//  LJReadQRCodeView.m
//  LJReadQRCode
//
//  Created by liujunjie on 15-6-3.
//  Copyright (c) 2015年 rj. All rights reserved.
//

#import "LJReadQRCodeView.h"
#import <AVFoundation/AVFoundation.h>
@interface LJReadQRCodeView ()<AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureVideoPreviewLayer *_preview;
    AVCaptureSession *_session;
}
@end
@implementation LJReadQRCodeView
- (void)readQRCode {
    // 1. 摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 2. 设置输入
    NSError *error = nil;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    // 2.1 判断是否有摄像头
    if (error) {
        NSLog(@"没有找到摄像头%@",error);
        return;
    }
    // 3. 设置输出（Metadata元数据）
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // 3.1 设置输出代理
    // 说明：使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 4. 拍照会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // 4.1 添加session的输入和输出
    [session addInput:input];
    [session addOutput:output];
    // 4.2 设置输出格式
    // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    //5. 设置预览图层（用来让用户能够看到扫描情况）
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    // 5.1 设置preview图层的属性
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    // 5.2 设置preview图层的大小
    [preview setFrame:self.bounds];
    // 5.3 将图层添加到视图的图层
    [self.layer insertSublayer:preview atIndex:0];
    _preview = preview;
    // 6. 启动会话
    [session startRunning];
    _session = session;
}
#pragma mark - 输出代理方法
// 此方法是在识别到QRCode，并且完成转换
// 如果QRCode的内容越大，转换需要的时间就越长
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    // 会频繁的扫描，调用代理方法
    // 1. 如果扫描完成，停止会话
    [_session stopRunning];
    // 2. 删除预览图层
    [_preview removeFromSuperlayer];
    // 3. 设置界面显示扫描结果
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        // 提示：如果需要对url或者名片等信息进行扫描，可以在此进行扩展！

        if ([_delegate respondsToSelector:@selector(readQRCodeView:result:)]) {
            
            [_delegate readQRCodeView:self result:obj.stringValue];
        }
    }
}
@end
