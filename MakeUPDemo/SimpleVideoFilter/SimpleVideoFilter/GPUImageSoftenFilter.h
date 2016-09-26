//
//  GPUImageSoftenFilter.h
//  InstaBeauty
//
//  Created by youdingkun on 16-01-07.
//  Copyright (c) 2016年 Fotoable Inc. All rights reserved.
//

#import "GPUImageTwoPassTextureSamplingFilter.h"

@class SoftenEngine;


@interface GPUImageSoftenFilter : GPUImageTwoPassTextureSamplingFilter
{
    SoftenEngine *softenEngine;
}

- (void) setSoftenLevel:(float)softenLevel;

@property (readwrite, retain) SoftenEngine *softenEngine;

@end
