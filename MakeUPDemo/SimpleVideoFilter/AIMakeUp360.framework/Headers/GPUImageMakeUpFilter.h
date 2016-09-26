//
//  GPUImageMakeUpFilter.h
//  FilterShowcase
//
//  Created by tangyu on 16/7/23.
//  Copyright © 2016年 Cell Phone. All rights reserved.
//

#ifndef GPUImageMakeUpFilter_h
#define GPUImageMakeUpFilter_h

#import <GPUImagePicture.h>
#import <GPUImageFilterGroup.h>

@interface GPUImageMakeUpFilter : GPUImageFilterGroup

@property(readwrite, nonatomic) CGFloat softLevel;
@property(readwrite, nonatomic) CGFloat whiteLevel;
@property(readwrite, nonatomic) CGFloat eyeRatioLevel;

// 嫩肤程度，范围0-1
- (void)setSoftLevel:(CGFloat)newValue;
// 美白程度，范围0-1
- (void)setWhiteLevel:(CGFloat)newValue;
// 眼间距，当前帧中检测到人脸，双眼距离和被检测图像较短边的比值，用于优化嫩肤的效果，如果没有人脸检测，值一般可固定在0.35-0.7之间
- (void)setEyeRatioLevel:(CGFloat)newValue;
// 是否开启肤色检测（初始化后默认开启）
- (void)UseSkinDetect:(BOOL)newValue;
// 初始化带上滤镜图片，rfilter.png：美白加红润， nrfilter.png：美白无红润
- (id)initWithLookUpFilter:(NSString *)fileName;

@end


#endif /* GPUImageMakeUpFilter_h */
