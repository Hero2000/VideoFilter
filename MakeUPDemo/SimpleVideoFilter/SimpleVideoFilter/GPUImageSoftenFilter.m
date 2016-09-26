//
//  GPUImageSoftenFilter.m
//  InstaBeauty
//
//  Created by youdingkun on 16-01-07.
//  Copyright (c) 2016年 Fotoable Inc. All rights reserved.
//

#import "GPUImageSoftenFilter.h"
#import <SoftenEngine/SoftenEngine.h>


@implementation GPUImageSoftenFilter

@synthesize softenEngine = _softenEngine;


#pragma mark -
#pragma mark Initialization and teardown


- (id)init{
    
    if (!(self = [super init]))
    {
        return nil;
    }

    _softenEngine = [[SoftenEngine alloc] init];

    return self;
}


-(void)dealloc{
    _softenEngine = nil;
}

- (void) setSoftenLevel:(float)softenLevel{
    if (_softenEngine != nil) {
        [_softenEngine setSoftenLevel:softenLevel];
    }
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    [super setInputSize:newSize atIndex:textureIndex];
    [_softenEngine setInputSize:newSize atIndex:textureIndex];
}

- (void)forceProcessingAtSize:(CGSize)frameSize;
{
    [super forceProcessingAtSize:frameSize];
    [_softenEngine forceProcessingAtSize:frameSize];
}

- (void)forceProcessingAtSizeRespectingAspectRatio:(CGSize)frameSize;
{
    [super forceProcessingAtSizeRespectingAspectRatio:frameSize];
    [_softenEngine forceProcessingAtSizeRespectingAspectRatio:frameSize];
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    [super setupFilterForSize:filterFrameSize];
    [_softenEngine setupFilterForSize:filterFrameSize];
}

#pragma mark -
#pragma mark Managing targets

- (GPUImageFramebuffer *)framebufferForOutput;
{
    if (_softenEngine != nil) {
        return [_softenEngine framebufferForOutput];
    }
    else {
        return nil;
    }
}

- (void)removeOutputFramebuffer;
{
    if (_softenEngine != nil) {
        [_softenEngine removeOutputFramebuffer];
    }
}

#pragma mark -
#pragma mark Rendering

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (_softenEngine != nil) {
        [_softenEngine render:firstInputFramebuffer vertices:vertices textureCoordinates:textureCoordinates];
    }
}

@end

