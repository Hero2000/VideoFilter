//
//  SoftenEngine.h
//  InstaBeauty
//
//  Created by youdingkun on 16-01-08.
//  Copyright (c) 2016年 Fotoable Inc. All rights reserved.
//

#import "GPUImageTwoPassTextureSamplingFilter.h"

@interface SoftenEngine : GPUImageTwoPassTextureSamplingFilter
{
}

-(void)setSoftenLevel:(float)softLevel;

- (void)render:(GPUImageFramebuffer *)srcBuf vertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;


@end
