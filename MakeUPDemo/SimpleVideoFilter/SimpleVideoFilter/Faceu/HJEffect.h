//
//  HJEffect.h
//  living
//
//  Created by Tide on 16/2/17.
//  Copyright © 2016年 MJHF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class IFImageFilter;


@interface HJEffectImage : NSObject

@property (nonatomic, assign) NSInteger face_Type;  //类型0:萌颜 1:需要表情 2:变脸

//－－－－－－－－－－－－－－－萌颜－－－－－－－－－－－－－－－
@property (nonatomic, assign) GLint mframeCount;
@property (nonatomic, assign) GLint mfaceCount;

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSMutableArray *imageNames;

@property (nonatomic, assign) CGFloat anchor_offset_x;
@property (nonatomic, assign) CGFloat anchor_offset_y;

//默认是左边 还是右边
@property (nonatomic, assign) BOOL  isRight;
//是否根据人脸位置调换位置
@property (nonatomic, assign) BOOL  isSuitDirection;
//调换后的位置
@property (nonatomic, assign) CGFloat anchor_offset_suit_x;
@property (nonatomic, assign) CGFloat anchor_offset_suit_y;

@property (nonatomic, assign) CGFloat asize_offset_x;
@property (nonatomic, assign) CGFloat asize_offset_y;

@property (nonatomic, assign) NSInteger radius_Type;    //角度： 0根据双眼计算；1使用指定值
@property (nonatomic, assign) CGFloat mradius;   //角度

@property (nonatomic, assign) NSInteger mid_Type;  //中心点类型： 0根据双眼计算；1使用鼻子点为中点；2使用指定值； 3上嘴唇下沿;4,使用配置点作index取sdk中的坐标
@property (nonatomic, assign) CGFloat mid_x;   //指定坐标
@property (nonatomic, assign) CGFloat mid_y;   //指定坐标

@property (nonatomic, assign) NSInteger mid_Index;  //取sdk点坐标的index，仅在mid_Type=4时有效
@property (nonatomic, assign) NSInteger mid_Index_q;  //取sdk点坐标的index，仅在mid_Type=4时有效

@property (nonatomic, assign) NSInteger scale_Type;  //计算系数： 0除以指定系数计算；1使用指定值
@property (nonatomic, assign) CGFloat scale_ratio;  //除以系数

@property (nonatomic, strong) NSMutableArray *gpuImages;
@property (nonatomic, strong) IFImageFilter *skinFilter;

//－－－－－－－－－－－－－－－表情－－－－－－－－－－－－－－－
@property (nonatomic, assign) NSInteger expression_Type;    //是否需要表情，0不需要；1咧嘴笑；2挑眉；3张嘴；4闭眼
@property (nonatomic, assign) CGFloat expression_Value;     //表情阈值
@property (nonatomic, assign) NSInteger expression_loop;     //表情循环次数 : 0及负数是触发就出现，不触发立即消失；1及以上是触发后循环多少次才消失

- (BOOL)effectImageIsValid;

//- (void)loadGPUImage;

- (void)loadNullImages;

- (void)loadGPUImageIfNeedForIndex:(NSInteger) index;

//非配置字段，代码逻辑判断用
@property (nonatomic, assign) BOOL expression_playing;     //表情正在播放
@property (nonatomic, assign) CGPoint cur_mid_Point;    //取出sdk的坐标点，仅在mid_Type=4时有效

//－－－－－－－－－－－－－－－变脸－－－－－－－－－－－－－－－
@property (nonatomic, assign) NSInteger faceMorph_Type; //变脸类型0：不修改脸型；1:修改脸型；2:透明（预设）
@property (nonatomic, strong) NSString *maskPoint;  //素材点文件名

@end



@interface HJEffect : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSString *ID;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger loop;
@property (nonatomic, assign) NSInteger maxFaceCount;  //最多的脸数
@property (nonatomic, strong) NSString *musicName;  //音乐文件名
@property (nonatomic, assign) NSInteger musicLoop;  //音乐循环次数，0或负数无限循环；正数指次数
@property (nonatomic, strong) NSMutableArray *effectImages;
@property (nonatomic, strong) HJEffectImage *effectImage;
@property (nonatomic, assign) NSInteger faceType;



- (id)initWithJsonString:(NSString *)string dir:(NSString *)url;

@end
