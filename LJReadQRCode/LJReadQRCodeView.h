//
//  LJReadQRCodeView.h
//  LJReadQRCode
//
//  Created by liujunjie on 15-6-3.
//  Copyright (c) 2015年 rj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LJReadQRCodeView;
@protocol LJReadQRCodeViewDelegate <NSObject>

- (void)readQRCodeView:(LJReadQRCodeView *)readQRCodeView result:(NSString *)result;

@end
@interface LJReadQRCodeView : UIView

- (void)readQRCode;
@property (weak,nonatomic)id<LJReadQRCodeViewDelegate>delegate;
@end
