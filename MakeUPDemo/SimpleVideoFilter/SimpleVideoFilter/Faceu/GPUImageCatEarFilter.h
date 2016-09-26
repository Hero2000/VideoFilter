//
//  GPUImageCatEarFilter.h
//  living
//
//  Created by f22 on 2/1/16.
//  Copyright © 2016 MJHF. All rights reserved.
//

#import "IFImageFilter.h"

@interface GPUImageCatEarFilter : IFImageFilter
- (id)initWithPrepareBlock:(prepare_block_t)prepareBlock;
@property (nonatomic, assign) CGPoint mmid0;
@property (nonatomic, assign) CGPoint mmid1;
@property (nonatomic, assign) CGPoint mmid2;
@property (nonatomic, assign) CGPoint mmid3;
@property (nonatomic, assign) CGPoint mmid4;
@property (nonatomic, assign) CGPoint msize0;
@property (nonatomic, assign) CGPoint msize1;
@property (nonatomic, assign) CGPoint msize2;
@property (nonatomic, assign) CGPoint msize3;
@property (nonatomic, assign) CGPoint msize4;
@property (nonatomic, assign) CGPoint mbsize0;
@property (nonatomic, assign) CGPoint mbsize1;
@property (nonatomic, assign) CGPoint mbsize2;
@property (nonatomic, assign) CGPoint mbsize3;
@property (nonatomic, assign) CGPoint mbsize4;
@property (nonatomic, assign) CGPoint manchor0;
@property (nonatomic, assign) CGPoint manchor1;
@property (nonatomic, assign) CGPoint manchor2;
@property (nonatomic, assign) CGPoint manchor3;
@property (nonatomic, assign) CGPoint manchor4;
@property (nonatomic, assign) CGFloat mradius0;
@property (nonatomic, assign) CGFloat mradius1;
@property (nonatomic, assign) CGFloat mradius2;
@property (nonatomic, assign) CGFloat mradius3;
@property (nonatomic, assign) CGFloat mradius4;
@property (nonatomic, assign) CGPoint mbanchor0;
@property (nonatomic, assign) CGPoint mbanchor1;
@property (nonatomic, assign) CGPoint mbanchor2;
@property (nonatomic, assign) CGPoint mbanchor3;
@property (nonatomic, assign) CGPoint mbanchor4;
@property (nonatomic, assign) GLint mframeCount;
@property (nonatomic, assign) GLint mfaceCount;

@property (nonatomic, assign) GLint bSuit;

@end

#define MAX_FACE_COUNT 5
