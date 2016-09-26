//
//  HJEffect.m
//  living
//
//  Created by Tide on 16/2/17.
//  Copyright © 2016年 MJHF. All rights reserved.
//

#import "HJEffect.h"
#import "GPUImagePicture.h"

@interface HJEffectImage ()

@end


@implementation HJEffectImage


- (id)init
{
    self = [super init];
    if (self) {
        self.gpuImages = [NSMutableArray array];
        self.imageNames = [NSMutableArray array];
    }
    return self;
}

- (BOOL)effectImageIsValid
{
    if (self.mfaceCount <=0 || self.mframeCount <= 0 || [self.imageName length] <= 0) {
        NSLog(@"---effectImageIsValid----");
        return NO;
    }
    
    return YES;
}

- (BOOL)checkAllImageIsValid:(NSString *)ID
{
    for (int i = 0; i < self.mframeCount; i++) {

        NSString *confPath = [NSString stringWithFormat:@"%@/%@/%@%d.png",ID, self.imageName,self.imageName, i];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:confPath]) {
            NSLog(@"---checkAllImageIsValid--%@", confPath);
            return NO;
        } else {
            [self.imageNames addObject:confPath];
        }
    }
    return YES;
}

//- (void)loadGPUImage
//{
//    int idx = 0;
//    for (NSString *name in self.imageNames) {
//        GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:name]];
//        if (picture) {
//            [self.gpuImages addObject:picture];
//            [self.gpuImages[idx] processImage];
//        }
//        idx++;
//    }
//}

- (void)loadNullImages {
    for (NSString *name in self.imageNames) {
        [self.gpuImages addObject:[NSNull null]];
    }
}

- (void)loadGPUImageIfNeedForIndex:(NSInteger) index {
    if (index < self.imageNames.count) {
        if (![self.gpuImages[index] isKindOfClass:[NSNull class]]) {
            return;
        } else {
            GPUImagePicture * picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:self.imageNames[index]]];
            if (picture) {
                [picture processImage];
                [self.gpuImages replaceObjectAtIndex:index withObject:picture];
            }
        }
    }
}

- (void)cleanImage
{
    [self.gpuImages removeAllObjects];
}

@end

@interface HJEffect ()
@property (nonatomic, strong) NSString *dir;

@end

@implementation HJEffect

- (id)initWithJsonString:(NSString *)string dir:(NSString *)url;
{
    self = [super init];
    if (self) {
        if ([string length]) {
            self.effectImages = [NSMutableArray array];
            
            NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
            __autoreleasing NSError* error = nil;
            if (data) {
                id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                if (error != nil){
                    return nil;
                }
                if (![result isKindOfClass:[NSDictionary class]]) {
                    return nil;
                }
                self.dir = url;//_STR(url);
                self.name = [NSString stringWithFormat:@"%@", [result objectForKey:@"Name"]];//_STR(result[@"Name"]);
                self.ID = [NSString stringWithFormat:@"%@", [result objectForKey:@"ID"]];//_STR(result[@"ID"]);
                self.type = [[result objectForKey:@"Type"] integerValue];//_INTEGER(result[@"Type"]);
                self.loop = [[result objectForKey:@"loop"] integerValue];//_INTEGER(result[@"loop"]);
                self.musicName = [NSString stringWithFormat:@"%@", [result objectForKey:@"music"]];//_STR(result[@"music"]);
                self.musicLoop = [[result objectForKey:@"musicLoop"] integerValue];//_INTEGER(result[@"musicLoop"]);
                
                NSArray *array  = [result objectForKey:@"texture"];//_ARRAY(result[@"texture"]);
                for (NSDictionary *dict in array) {
                    if ([dict isKindOfClass:[NSDictionary class]]) {
                        HJEffectImage *effectImage = [[HJEffectImage alloc] init];
                        for (NSString *str in dict) {
                            @try {
                                if (dict[str] && str) {
                                    [effectImage setValue:dict[str] forKey:str];
                                }
                            } @catch (NSException *exception) {
                                
                            }
                        }
                        
                        if (![effectImage effectImageIsValid] || ![effectImage checkAllImageIsValid:self.dir]) {
                            NSLog(@"---faceu file error----");
                            return nil;
                        }
                        [self.effectImages addObject:effectImage];
                    }
                }
            }
        }
    }
    return self;
}

@end
