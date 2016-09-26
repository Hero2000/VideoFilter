//
//  WKEffectInfo.h
//  SimpleVideoFilter
//
//  Created by 李越 on 16/8/23.
//  Copyright © 2016年 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WKEffectSourceOwn = 0,  //自己
    WKEffectSourceAudience, //观众
    WKEffectSourceMorph,    //变脸
}HJEffectSource;

@interface WKEffectInfo : NSObject

@property (nonatomic, copy) NSString * effectID;
@property (nonatomic, copy) NSString * effectPath;
@property (nonatomic, assign) NSInteger loopCount;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, assign) HJEffectSource effectSource;

@end
