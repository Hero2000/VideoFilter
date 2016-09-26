//
//  WKAudioEncoder.h
//  SimpleVideoFilter
//
//  Created by liyue-g on 16/8/18.
//  Copyright © 2016年 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^WKEncoderAudioDataReadyBlock)(void* buffer, int32_t bufferLen);

@interface WKAudioEncoder : NSObject

- (instancetype)initWithBitrate:(NSUInteger)bitrate
                      sampleRate:(NSUInteger)sampleRate
                        channels:(NSUInteger)channels
                     onDataReady:(WKEncoderAudioDataReadyBlock)dataReady;

- (void)encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
