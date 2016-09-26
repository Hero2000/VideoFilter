//
//  GPUImageCatEarFilter.m
//  living
//
//  Created by f22 on 2/1/16.
//  Copyright © 2016 MJHF. All rights reserved.
//

#import "GPUImageCatEarFilter.h"

static NSString *const kCatEarShaderString = SHADER_STRING
(
    precision highp float;
	varying highp vec2 textureCoordinate;
	
	uniform sampler2D inputImageTexture;
	uniform sampler2D inputImageTexture2;
	uniform sampler2D inputImageTexture3;
	
    uniform vec2 mid0;
	uniform vec2 mid1;
	uniform vec2 mid2;
	uniform vec2 mid3;
	uniform vec2 mid4;
	uniform vec2 rot0;
	uniform vec2 rot1;
	uniform vec2 rot2;
	uniform vec2 rot3;
	uniform vec2 rot4;
    uniform vec2 size0;
    uniform vec2 size1;
    uniform vec2 size2;
    uniform vec2 size3;
    uniform vec2 size4;
    uniform vec2 bsize0;
    uniform vec2 bsize1;
    uniform vec2 bsize2;
    uniform vec2 bsize3;
    uniform vec2 bsize4;
	uniform vec2 anchor0;
	uniform vec2 anchor1;
	uniform vec2 anchor2;
	uniform vec2 anchor3;
	uniform vec2 anchor4;
	uniform vec2 banchor0;
	uniform vec2 banchor1;
	uniform vec2 banchor2;
	uniform vec2 banchor3;
	uniform vec2 banchor4;
//    uniform int hasTwoTex;
 	uniform int faceCount;
    uniform int frameCount;
 
    uniform int bsuit;
 
	vec4 blend(vec4 c1, vec4 c2)
	{
        vec4 c;
        c.r = c1.r + c2.r * c2.a * (1.0 - c1.a);
        c.g = c1.g + c2.g * c2.a * (1.0 - c1.a);
        c.b = c1.b + c2.b * c2.a * (1.0 - c1.a);
        c.a = c1.a + c2.a * (1.0 - c1.a);
        return c;
    }
 
	void main(){
        gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
        
        if (faceCount < 1 ) {
            return;
        }
        
        float sx=720.;
        float sy=1280.;
        
        vec2 localCoord=vec2((textureCoordinate.x-mid0.x)*sx,(textureCoordinate.y-mid0.y)*sy);
        localCoord=vec2(localCoord.x*rot0.y+localCoord.y*rot0.x,localCoord.y*rot0.y-localCoord.x*rot0.x);
        
        vec2 ulocalCoord=localCoord-anchor0;
        float localTexCoord_x = ulocalCoord.x/size0.x;
        if (bsuit == 1) {
            localTexCoord_x = 1.0-localTexCoord_x;
        }
        vec2 localTexCoord=vec2(localTexCoord_x,ulocalCoord.y/size0.y);
        vec4 c1 = vec4(0.0);
        if (localTexCoord.x > 0.0 && localTexCoord.y > 0.0 && localTexCoord.x < 1.0 && localTexCoord.y < 1.0)
            c1 = texture2D(inputImageTexture2, localTexCoord);
        
        gl_FragColor = blend(c1, gl_FragColor);
        
//        if(hasTwoTex==1)
//        {
//            vec2 blocalCoord=localCoord-banchor0;
//            localTexCoord=vec2(blocalCoord.x/bsize0.x,blocalCoord.y/bsize0.y);
//            c1 = vec4(0.0);
//            if (localTexCoord.x > 0.0 && localTexCoord.y > 0.0 && localTexCoord.x < 1.0 && localTexCoord.y < 1.0)
//                c1 = texture2D(inputImageTexture3, localTexCoord);
//            
//            gl_FragColor = blend(c1, gl_FragColor);
//        }
        
        if (faceCount>=2)
        {
            vec2 localCoord=vec2((textureCoordinate.x-mid1.x)*sx,(textureCoordinate.y-mid1.y)*sy);
            localCoord=vec2(localCoord.x*rot1.y+localCoord.y*rot1.x,localCoord.y*rot1.y-localCoord.x*rot1.x);
            
            vec2 ulocalCoord=localCoord-anchor1;
            vec2 localTexCoord=vec2(ulocalCoord.x/size1.x,ulocalCoord.y/size1.y);
            vec4 c1 = vec4(0.0);
            if (localTexCoord.x > 0.0 && localTexCoord.y > 0.0 && localTexCoord.x < 1.0 && localTexCoord.y < 1.0)
                c1 = texture2D(inputImageTexture2, localTexCoord);
            
            gl_FragColor = blend(c1, gl_FragColor);
            
//            if(hasTwoTex==1)
//            {
//                vec2 blocalCoord=localCoord-banchor1;
//                localTexCoord=vec2(blocalCoord.x/bsize1.x,blocalCoord.y/bsize1.y);
//                c1 = vec4(0.0);
//                if (localTexCoord.x > 0.0 && localTexCoord.y > 0.0 && localTexCoord.x < 1.0 && localTexCoord.y < 1.0)
//                    c1 = texture2D(inputImageTexture3, localTexCoord);
//                
//                gl_FragColor = blend(c1, gl_FragColor);
//            }
        }
        
        if (faceCount>=3)
        {
            vec2 localCoord=vec2((textureCoordinate.x-mid2.x)*sx,(textureCoordinate.y-mid2.y)*sy);
            localCoord=vec2(localCoord.x*rot2.y+localCoord.y*rot2.x,localCoord.y*rot2.y-localCoord.x*rot2.x);
            
            vec2 ulocalCoord=localCoord-anchor2;
            vec2 localTexCoord=vec2(ulocalCoord.x/size2.x,ulocalCoord.y/size2.y);
            vec4 c1 = vec4(0.0);
            if (localTexCoord.x > 0.0 && localTexCoord.y > 0.0 && localTexCoord.x < 1.0 && localTexCoord.y < 1.0)
                c1 = texture2D(inputImageTexture2, localTexCoord);
            
            gl_FragColor = blend(c1, gl_FragColor);
            
//            if(hasTwoTex==1)
//            {
//                vec2 blocalCoord=localCoord-banchor2;
//                localTexCoord=vec2(blocalCoord.x/bsize2.x,blocalCoord.y/bsize2.y);
//                c1 = vec4(0.0);
//                if (localTexCoord.x > 0.0 && localTexCoord.y > 0.0 && localTexCoord.x < 1.0 && localTexCoord.y < 1.0)
//                    c1 = texture2D(inputImageTexture3, localTexCoord);
//                
//                gl_FragColor = blend(c1, gl_FragColor);
//            }
        }
        
        if (faceCount>=4)
        {
            vec2 localCoord=vec2((textureCoordinate.x-mid3.x)*sx,(textureCoordinate.y-mid3.y)*sy);
            localCoord=vec2(localCoord.x*rot3.y+localCoord.y*rot3.x,localCoord.y*rot3.y-localCoord.x*rot3.x);
            
            vec2 ulocalCoord=localCoord-anchor3;
            vec2 localTexCoord=vec2(ulocalCoord.x/size3.x,ulocalCoord.y/size3.y);
            vec4 c1 = vec4(0.0);
            if (localTexCoord.x > 0.0 && localTexCoord.y > 0.0 && localTexCoord.x < 1.0 && localTexCoord.y < 1.0)
                c1 = texture2D(inputImageTexture2, localTexCoord);
            
            gl_FragColor = blend(c1, gl_FragColor);
            
//            if(hasTwoTex==1)
//            {
//                vec2 blocalCoord=localCoord-banchor3;
//                localTexCoord=vec2(blocalCoord.x/bsize3.x,blocalCoord.y/bsize3.y);
//                c1 = vec4(0.0);
//                if (localTexCoord.x > 0.0 && localTexCoord.y > 0.0 && localTexCoord.x < 1.0 && localTexCoord.y < 1.0)
//                    c1 = texture2D(inputImageTexture3, localTexCoord);
//                
//                gl_FragColor = blend(c1, gl_FragColor);
//            }
        }
        
        if (faceCount>=5)
        {
            vec2 localCoord=vec2((textureCoordinate.x-mid4.x)*sx,(textureCoordinate.y-mid4.y)*sy);
            localCoord=vec2(localCoord.x*rot4.y+localCoord.y*rot4.x,localCoord.y*rot4.y-localCoord.x*rot4.x);
            
            vec2 ulocalCoord=localCoord-anchor4;
            vec2 localTexCoord=vec2(ulocalCoord.x/size4.x,ulocalCoord.y/size4.y);
            vec4 c1 = vec4(0.0);
            if (localTexCoord.x > 0.0 && localTexCoord.y > 0.0 && localTexCoord.x < 1.0 && localTexCoord.y < 1.0)
                c1 = texture2D(inputImageTexture2, localTexCoord);
            
            gl_FragColor = blend(c1, gl_FragColor);
            
//            if(hasTwoTex==1)
//            {
//                vec2 blocalCoord=localCoord-banchor4;
//                localTexCoord=vec2(blocalCoord.x/bsize4.x,blocalCoord.y/bsize4.y);
//                c1 = vec4(0.0);
//                if (localTexCoord.x > 0.0 && localTexCoord.y > 0.0 && localTexCoord.x < 1.0 && localTexCoord.y < 1.0)
//                    c1 = texture2D(inputImageTexture3, localTexCoord);
//                
//                gl_FragColor = blend(c1, gl_FragColor);
//            }
        }
    }
);

@implementation GPUImageCatEarFilter
{
    GLint midUniform[MAX_FACE_COUNT];
    GLint rotUniform[MAX_FACE_COUNT];
    GLint sizeUniform[MAX_FACE_COUNT];
    GLint bsizeUniform[MAX_FACE_COUNT];
    GLint anchorUniform[MAX_FACE_COUNT];
    GLint banchorUniform[MAX_FACE_COUNT];
//    GLint hasTwoTexUniform;
    GLint faceCountUniform;
    GLint frameCountUniform;
    
    GLint bsuitUniform;
    
    CGPoint mrot[MAX_FACE_COUNT];
    
#define HISTORY_DEPTH 4
    CGPoint eyeaHis[HISTORY_DEPTH];
    CGPoint eyebHis[HISTORY_DEPTH];
}

- (id)initWithPrepareBlock:(prepare_block_t)prepareBlock
{
    if (!(self = [super initWithFragmentShaderFromString:kCatEarShaderString withPrepareBlock:prepareBlock]))
    {
        return nil;
    }
    
    for(int i=0;i<MAX_FACE_COUNT;i++)
    {
        midUniform[i]       = [filterProgram uniformIndex:[NSString stringWithFormat:@"mid%d",i]];
        rotUniform[i]       = [filterProgram uniformIndex:[NSString stringWithFormat:@"rot%d",i]];
        sizeUniform[i]      = [filterProgram uniformIndex:[NSString stringWithFormat:@"size%d",i]];
        bsizeUniform[i]     = [filterProgram uniformIndex:[NSString stringWithFormat:@"bsize%d",i]];
        anchorUniform[i]    = [filterProgram uniformIndex:[NSString stringWithFormat:@"anchor%d",i]];
        banchorUniform[i]   = [filterProgram uniformIndex:[NSString stringWithFormat:@"banchor%d",i]];
    }
//    hasTwoTexUniform  = [filterProgram uniformIndex:@"hasTwoTex"];
    faceCountUniform  = [filterProgram uniformIndex:@"faceCount"];
    frameCountUniform = [filterProgram uniformIndex:@"frameCount"];
    bsuitUniform = [filterProgram uniformIndex:@"bsuit"];
    
    return self;
}

-(CGPoint)smooth:(CGPoint)point withHistory:(CGPoint[])his
{
    CGPoint result;
    float weight[HISTORY_DEPTH]={0.04,0.08,0.16,0.32};
    float norm=0;
    for(int i=0;i<HISTORY_DEPTH;i++)
    {
        if(his[i].x!=0.0)
        {
            result.x+=weight[i]*his[i].x;
            result.y+=weight[i]*his[i].y;
            norm+=weight[i];
        }
    }
    
    float nw=1-norm;
    result.x+=point.x*nw;
    result.y+=point.y*nw;
    
    for(int i=0;i<HISTORY_DEPTH-1;i++)
    {
        his[i].x=his[i+1].x;
        his[i].y=his[i+1].y;
    }
    
    his[HISTORY_DEPTH-1].x=point.x;
    his[HISTORY_DEPTH-1].y=point.y;
    
    return result;
}

#pragma mark -
#pragma mark Accessors

#define SET_MID(x)  -(void)setMmid##x:(CGPoint)newValue;         \
{                                                                \
    _mmid##x = newValue;                                         \
    [self setPoint:_mmid##x                                      \
        forUniform:midUniform[x]                                 \
           program:filterProgram];                               \
}

#define SET_MSIZE(x) -(void)setMsize##x:(CGPoint)newValue;       \
{                                                                \
    _msize##x = newValue;                                        \
    [self setPoint:_msize##x                                     \
        forUniform:sizeUniform[x]                                \
           program:filterProgram];                               \
}

#define SET_MANCHOR(x) -(void)setManchor##x:(CGPoint)newValue;   \
{                                                                \
    _manchor##x = newValue;                                      \
    [self setPoint:_manchor##x                                   \
        forUniform:anchorUniform[x]                              \
           program:filterProgram];                               \
}

#define SET_MBSIZE(x) -(void)setMbsize##x:(CGPoint)newValue;     \
{                                                                \
    _mbsize##x = newValue;                                       \
    [self setPoint:_mbsize##x                                    \
        forUniform:bsizeUniform[x]                               \
           program:filterProgram];                               \
}

#define SET_MBANCHOR(x) -(void)setMbanchor##x:(CGPoint)newValue; \
{                                                                \
    _mbanchor##x = newValue;                                     \
    [self setPoint:_mbanchor##x                                  \
        forUniform:banchorUniform[x]                             \
           program:filterProgram];                               \
}

#define SET_MRADIUS(x) -(void)setMradius##x:(CGFloat)mradius##x  \
{                                                                \
    _mradius##x=mradius##x;                                      \
    mrot[x]=CGPointMake(sin(-_mradius##x),cos(-_mradius##x));    \
    [self setPoint:mrot[x]                                       \
        forUniform:rotUniform[x]                                 \
           program:filterProgram];                               \
}

#define SETTER(x) SET_MID(x);SET_MSIZE(x);SET_MANCHOR(x);SET_MBSIZE(x);SET_MBANCHOR(x);SET_MRADIUS(x);
SETTER(0);
SETTER(1);
SETTER(2);
SETTER(3);
SETTER(4);

-(void)setMfaceCount:(GLint)mfaceCount
{
    _mfaceCount=mfaceCount;
    [self setInteger:_mfaceCount
          forUniform:faceCountUniform
             program:filterProgram];
}

//-(void)setMhasTwoTex:(GLint)mhasTwoTex
//{
//    _mhasTwoTex=mhasTwoTex;
//    [self setInteger:_mhasTwoTex
//          forUniform:hasTwoTexUniform
//             program:filterProgram];
//}

- (void)setBSuit:(GLint)bSuit
{
    _bSuit = bSuit;
    [self setInteger:_bSuit forUniform:bsuitUniform program:filterProgram];
}

-(void)setMframeCount:(GLint)mframeCount
{
    _mframeCount=mframeCount;
    [self setInteger:_mframeCount
          forUniform:frameCountUniform
             program:filterProgram];
}

@end
