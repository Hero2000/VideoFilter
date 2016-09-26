//
//  GPUImageSlimFilter.h
//  AIMakeUp360
//
//  Created by tangyu on 16/8/6.
//  Copyright © 2016年 360ai. All rights reserved.
//

#ifndef GPUImageSlimFilter_h
#define GPUImageSlimFilter_h

#import <GPUImagePicture.h>
#import <GPUImageFilterGroup.h>

@interface GPUImageSlimFilter : GPUImageFilterGroup

@property(readwrite, nonatomic) float eyeLevel;
@property(readwrite, nonatomic) float faceLevel;

- (void)setEyeLevel:(float)newValue;
- (void)setFaceLevel:(float)newValue;
- (void)setPoints:(float *)points;

@end

#endif /* GPUImageSlimFilter_h */
