#import "SimpleVideoFilterViewController.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "GPUImageMakeUpFilter.h"
#import "GPUImageView.h"
#import "WKAudioEncoder.h"
#import "WKH264Encoder.h"
#import "WKRtmpService.h"
#import "GPUImageFilterPipeline.h"
#import "GPUImageSlimFilter.h"
#import "CanvasView.h"
#import "tracker360.h"
#import "WKEffectInfo.h"
#import "HJEffect.h"
#import "GPUImageCatEarFilter.h"
#import "GPUImageFilterPipeline.h"
#import "GPUImageView.h"

@interface SimpleVideoFilterViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property(nonatomic, retain) WKH264Encoder* videoEncoder;
@property(nonatomic, retain) WKAudioEncoder* audioEncoder;

@property(nonatomic, assign) qh_handle_t hTracker;
@property(nonatomic, strong) CanvasView *viewCanvas ;

@property(nonatomic, strong) WKEffectInfo * effectInfo;
@property(nonatomic, strong) HJEffect *currentEffect;
@property(nonatomic, strong) GPUImageFilterPipeline * pipeline;
@property(nonatomic, strong) dispatch_queue_t faceuQueue;
@property(nonatomic, strong) GPUImageView* gpuImageView;

@end

@implementation SimpleVideoFilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];

    movieWriter = [[WKGPUImageMovieWriter alloc] initWithSize:CGSizeMake(720, 1280)];
    movieWriter.delegate = self;
    
//    NSString *pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Movie.m4v"];
//    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//    movieWriter = [[WKGPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720, 1280)];
//    movieWriter.delegate = self;
    
    [self initMovieEncoder];
    
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    //faceu
    NSString* modelPath = [[NSBundle mainBundle]
                           pathForResource:@"frcnn_full_cross_500000"
                           ofType:@"dat"];
    
    unsigned long lens = [modelPath length];
    NSString* dirPath = [modelPath substringWithRange:NSMakeRange(0, lens-27)];
    NSLog(@"dpath:%@", dirPath);
    
    self.hTracker = qh_face_create_tracker([dirPath UTF8String]);
    self.viewCanvas = [[CanvasView alloc] initWithFrame:CGRectMake(0, 0, 720, 1280)];
    [self.viewCanvas setUserInteractionEnabled:NO];
    [self.view addSubview:self.viewCanvas];
    self.viewCanvas.backgroundColor = [UIColor clearColor];
    
    [self initFaceM];

    
    //美白+嫩肤
//    GPUImageView* filterView =  (GPUImageView *)self.view;
    filter = [[GPUImageMakeUpFilter alloc] initWithLookUpFilter:@"nrfilter.png"]; // 加亮加白
//    filter = [[GPUImageMakeUpFilter alloc] initWithLookUpFilter:@"rfilter.png"]; // 加亮加白及红润
    [(GPUImageMakeUpFilter *) filter setSoftLevel:1.0f];        // 嫩肤0到1
    [(GPUImageMakeUpFilter *) filter setWhiteLevel:1.0f];       // 美白0到1
    [(GPUImageMakeUpFilter *) filter setEyeRatioLevel:0.5f];    // 眼间距，有人脸检测实时传入眼间距与原图较短边的比值，没有则传入0.5
    
    
    //生成pipeline
    NSMutableArray* arrayTemp = [NSMutableArray array];
    GPUImageFilter* emptyFilter = [[GPUImageFilter alloc] init];
    [arrayTemp addObject:emptyFilter];
    
    if (self.currentEffect) {
        for (HJEffectImage *effectImage in self.currentEffect.effectImages) {
            if (effectImage.skinFilter) {
                [arrayTemp addObject:effectImage.skinFilter];
            }
        }
    }
    
    [arrayTemp addObject:filter];
    
    self.pipeline = [[GPUImageFilterPipeline alloc]initWithOrderedFilters:arrayTemp input:videoCamera output:movieWriter];
    
    //显示
    CGRect frame = [UIScreen mainScreen].bounds;
    self.gpuImageView =[[GPUImageView alloc] initWithFrame:frame];
    [filter addTarget:self.gpuImageView];
    [self.containerView addSubview:self.gpuImageView];

    //开始直播
    [videoCamera setDelegate:movieWriter];
    [videoCamera setAudioEncodingTarget:(GPUImageMovieWriter *)movieWriter];
    [videoCamera startCameraCapture];
    [movieWriter startRecording];
}

- (void)initMovieEncoder
{
    char byteAACHeader[] = {0x12, 0x8};
//    rtmp://ps10.live.5kong.tv/live_5kong/1b1ad0830e973d75d2453bb83b307786?sign=1a7742534e270819088d32c5979e054a&tm=20160824191915&domain=ps10.live.5kong.tv
    [[WKRtmpService sharedInstance] createRtmp:@"rtmp://192.168.137.1/live" key:@"test"];
    [[WKRtmpService sharedInstance] setAudioBps:64000/1000
                                       channels:1
                                     sampleSize:16
                                     sampleRate:44100/1000
                                      aacHeader:byteAACHeader
                                  aacHeaderSize:2];
    
    self.audioEncoder = [[WKAudioEncoder alloc] initWithBitrate:64000
                                                     sampleRate:44100
                                                       channels:1
                                                    onDataReady:^(void *buffer, int32_t bufferLen)
                                                    {
                                                        [[WKRtmpService sharedInstance] pushAudioData:buffer size:bufferLen];
                                                    }];
    
    self.videoEncoder = [[WKH264Encoder alloc] initWithWidth:720
                                                      height:1280
                                            keyFrameInterval:3
                                                     bitrate:1000000
                                                         fps:20
                                               onSPSPPSReady:^(char *spspps, int spsppsSize)
                                               {
                                                   [[WKRtmpService sharedInstance] setVideoWidth:720
                                                                                          height:1280
                                                                                             fps:20
                                                                                             bps:1000000
                                                                                          spspps:spspps
                                                                                      spsppsSize:spsppsSize];
                                               }
                                               onDataReady:^(void *buffer, int32_t bufferLen, uint64_t timestamp, BOOL isKeyFrame)
                                               {
                                                  [[WKRtmpService sharedInstance] pushVideoPts:timestamp
                                                                                          data:buffer
                                                                                          size:bufferLen
                                                                                    isKeyFrame:isKeyFrame];
                                               }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Face Detection Delegate Callback

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Map UIDeviceOrientation to UIInterfaceOrientation.
    UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
            orient = UIInterfaceOrientationLandscapeLeft;
            break;

        case UIDeviceOrientationLandscapeRight:
            orient = UIInterfaceOrientationLandscapeRight;
            break;

        case UIDeviceOrientationPortrait:
            orient = UIInterfaceOrientationPortrait;
            break;

        case UIDeviceOrientationPortraitUpsideDown:
            orient = UIInterfaceOrientationPortraitUpsideDown;
            break;

        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
            // When in doubt, stay the same.
            orient = fromInterfaceOrientation;
            break;
    }
    videoCamera.outputImageOrientation = orient;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES; // Support all orientations.
}

- (IBAction)updateSliderValue:(id)sender
{
    [(GPUImageMakeUpFilter *) filter setSoftLevel:[(UISlider *)sender value]];
    [(GPUImageMakeUpFilter *) filter setWhiteLevel:[(UISlider *)sender value]];
}

#pragma mark - WKGPUImageMovieWriter Delegate

- (void)movieAudioBuffer:(CMSampleBufferRef)buffer
{
    [self.audioEncoder encodeSampleBuffer:buffer];
}

- (void)movieVideoBuffer:(CMSampleBufferRef)buffer
{
//    [self.videoEncoder encodeSampleBuffer:buffer];
}

- (void)movieVideoPixelBuffer:(CVPixelBufferRef)buffer
{
    [self.videoEncoder encodePixelBuffer:buffer];
}

#pragma mark - FaceM Methods

#define LoadImageToFilter3(x) {GPUImagePicture*p=x;p.ignorePushToDownStream=YES;p.ignoreDuplicateTargetCheck=YES;[p addTarget:obj];}

- (void)initFaceM
{
    if (!_faceuQueue) {
        _faceuQueue = dispatch_queue_create("Faceu Queue", DISPATCH_QUEUE_SERIAL);
    }
    
    //加载特效资源
    NSString* effectID = @"30004_1";//@"30012_1";
    NSString* path = [NSString stringWithFormat:@"%@/res/%@",[[NSBundle mainBundle] bundlePath], effectID];
    
    self.effectInfo = [[WKEffectInfo alloc] init];
    self.effectInfo.effectSource = WKEffectSourceOwn;
    self.effectInfo.effectID = effectID;
    self.effectInfo.effectPath = path;
    self.effectInfo.loopCount = 0;
    
    NSString *confPath = [NSString stringWithFormat:@"%@/config", self.effectInfo.effectPath];
    
    NSError *error1 = nil;
    NSString *jsonStr = [NSString stringWithContentsOfFile:confPath encoding:NSUTF8StringEncoding error:&error1];
    
    if (jsonStr.length == 0) {
        NSLog(@"文件读取失败---%@", confPath);
        return;
    }
    
    HJEffect *effect = [[HJEffect alloc] initWithJsonString:jsonStr dir:self.effectInfo.effectPath];
    effect.faceType = 1;
    if (effect == nil) {
        NSLog(@"文件解析失败");
        return;
    }
    
    //获取图片序列帧中最大图片数
    int maxIdx = 0;
    int maxCount = 0;
    for (int i = 0; i < [[effect effectImages] count]; i++) {
        HJEffectImage *obj1 = [[effect effectImages] objectAtIndex:i];
        if (obj1.mframeCount > maxCount) {
            maxCount = obj1.mframeCount;
            maxIdx = i;
        }
    }
    
    for ( HJEffectImage *obj1 in effect.effectImages)
    {
        [obj1.gpuImages removeAllObjects];
        //                    [obj1 loadGPUImage];
        [obj1 loadNullImages];
        __weak HJEffectImage* weakobj1 = obj1;
        
        GPUImageCatEarFilter *skinFilter_= [[GPUImageCatEarFilter alloc] initWithPrepareBlock:^(IFImageFilter*obj)
                                            {
                                                int idx = obj.frameCount % weakobj1.mframeCount;
                                                if ([weakobj1.gpuImages count] > idx)
                                                {
                                                    [weakobj1 loadGPUImageIfNeedForIndex:idx];
                                                    LoadImageToFilter3(weakobj1.gpuImages[idx]);
                                                    //                            NSLog(@"-----------------------%s-----%d", __FUNCTION__, __LINE__);
                                                    obj.frameCount++;
                                                }
                                            }];
        skinFilter_.mfaceCount = 0;
        obj1.skinFilter = skinFilter_;
    }
    
    self.currentEffect = effect;
}

- (void)processFaceuSampleBuffer:(CMSampleBufferRef)buffer
{
//    CFRetain(buffer);
//    CGImageRef imageRef = [self imageFromSampleBuffer:buffer];
//    CFRelease(buffer);
//    CVPixelBufferRef pixelBuffer = [self pixelBufferFaster:imageRef];
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(buffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    uint8_t *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    //    int dataLength = CVPixelBufferGetDataSize(pixelBuffer);
    //    NSLog(@"data size:%d", dataLength);
    
    qh_face_t *pFaceRectID = NULL ;
    int iCount = 0;
    
    int iWidth  = (int)CVPixelBufferGetWidth(pixelBuffer);
    int iHeight = (int)CVPixelBufferGetHeight(pixelBuffer);    //    NSLog(@"iCount-----------:%i",iCount);
    
    qh_result_t iRet = QH_OK;
    
    iRet = qh_face_track(self.hTracker, baseAddress, QH_PIX_FMT_BGRA8888, iWidth, iHeight, iWidth * 4, QH_FACE_LEFT, &pFaceRectID, &iCount, true);
    
    int px = 0, py = 0;
    //iRet = qh_face_detect_point(self.hTracker, baseAddress, QH_PIX_FMT_BGRA8888, iWidth, iHeight, iWidth * 4, QH_FACE_LEFT, &px, &py);
    //NSLog(@"%i,%i",px,py);
    
    //    NSLog(@"iCount:%i\n",iCount);
    
    bool bDrawRects = true;
    
    if ( bDrawRects && pFaceRectID != NULL) {
        
        NSMutableArray *arrPersons = [NSMutableArray array] ;
        
        for (int i = 0; i < 1 ; i ++) {
            
            qh_face_t rectIDMain = pFaceRectID[i] ;
            
            NSMutableArray *arrStrPoints = [NSMutableArray array] ;
            
            qh_pointf_t *facialPoints = rectIDMain.points_fine;
            
            //            { // for test
            //                NSLog(@"%f,%f\n", facialPoints[9].x, facialPoints[9].y);
            //            }
            
            for(int i = 0; i < rectIDMain.points_count; i ++) {
                
                //                [arrStrPoints addObject:NSStringFromCGPoint(CGPointMake(facialPoints[i].y, facialPoints[i].x))] ;
                [arrStrPoints addObject:NSStringFromCGPoint(CGPointMake(facialPoints[i].x / 720 * [UIScreen mainScreen].bounds.size.width, facialPoints[i].y / 1280 * [UIScreen mainScreen].bounds.size.height))] ;
            }
            
            facialPoints = rectIDMain.points5;
            
            for(int i = 0; i < 5; i ++) {
                //printf("%d,%d\n", facialPoints[i].x, facialPoints[i].y);
                //[arrStrPoints addObject:NSStringFromCGPoint(CGPointMake(facialPoints[i].y, facialPoints[i].x))] ;
                [arrStrPoints addObject:NSStringFromCGPoint(CGPointMake(facialPoints[i].x / 720 * [UIScreen mainScreen].bounds.size.width, facialPoints[i].y / 1280 * [UIScreen mainScreen].bounds.size.height))] ;
            }
            
            //qh_rect_t rect = rectIDMain.rect ;
            
            //CGRect rectFace = CGRectMake(rect.top , rect.left , rect.right - rect.left, rect.bottom - rect.top);
            //CGRect rectFace = CGRectMake(rect.left , rect.top , rect.right - rect.left, rect.bottom - rect.top);
            
            NSMutableDictionary *dicPerson = [NSMutableDictionary dictionary] ;
            [dicPerson setObject:arrStrPoints forKey:POINTS_KEY];
            //[dicPerson setObject:NSStringFromCGRect(rectFace) forKey:RECT_KEY];
            
            [arrPersons addObject:dicPerson];
            [self grepFacesWithHeight:iHeight width:iWidth point:rectIDMain.points_fine point5:rectIDMain.points5];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showFaceLandmarksAndFaceRectWithPersonsArray:arrPersons];
        } ) ;
        
    } else if (px != 0 && py != 0) {
        NSMutableArray *arrPersons = [NSMutableArray array] ;
        
        for (int i = 0; i < 1 ; i ++) {
            
            NSMutableArray *arrStrPoints = [NSMutableArray array] ;
            
            [arrStrPoints addObject:NSStringFromCGPoint(CGPointMake(px / 720 * [UIScreen mainScreen].bounds.size.width, py / 1280 * [UIScreen mainScreen].bounds.size.height))] ;
            
            
            NSMutableDictionary *dicPerson = [NSMutableDictionary dictionary] ;
            [dicPerson setObject:arrStrPoints forKey:POINTS_KEY];
            [arrPersons addObject:dicPerson] ;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showFaceLandmarksAndFaceRectWithPersonsArray:arrPersons];
            [self grepFacesWithHeight:iHeight width:iWidth point:NULL point5:NULL];
        } ) ;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideFace];
            [self grepFacesWithHeight:iHeight width:iWidth point:NULL point5:NULL];
        });
    }
    qh_face_release_tracker_result(pFaceRectID, iCount);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

- (void)showFaceLandmarksAndFaceRectWithPersonsArray:(NSMutableArray *)arrPersons
{
//    if (self.viewCanvas.hidden)
//    {
//        self.viewCanvas.hidden = NO ;
//    }
//    self.viewCanvas.arrPersons = arrPersons ;
//    [self.viewCanvas setNeedsDisplay] ;
}

- (void)hideFace
{
    if (!self.viewCanvas.hidden)
    {
        self.viewCanvas.hidden = YES;
    }
}

- (void)grepFacesWithHeight:(int)iHeight
                      width:(int)iWidth
                      point:(qh_pointf_t *)facialPoints
                     point5:(qh_pointf_t *)facialPoints_5
{
    if (!self.currentEffect)
        return;
    
    
    
    if (facialPoints == NULL)
    {
        CGPoint left = CGPointMake(0, 0);
        CGPoint right = CGPointMake(0, 0);
        CGPoint ptNose = CGPointMake(0, 0);
        CGPoint mouthUp = CGPointMake(0, 0);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (HJEffectImage *effectImage in self.currentEffect.effectImages) {
                [self updateFilter_qihoo:effectImage leftEye:left rightEye:right nose:ptNose mouthUp:mouthUp];
            }
        } ) ;
    }
    else
    {
    
    switch (self.currentEffect.faceType)
    {
        //face特效
        case 1:
        {
            CGPoint left=CGPointMake(facialPoints_5[0].x / iHeight, facialPoints_5[0].y / iWidth);
            CGPoint right=CGPointMake(facialPoints_5[1].x / iHeight, facialPoints_5[1].y / iWidth);
            CGPoint ptNose=CGPointMake(facialPoints_5[2].x / iHeight, facialPoints_5[2].y / iWidth);
            CGPoint mouthUp=CGPointMake(facialPoints[89].x / iHeight, facialPoints[89].y / iWidth);
            
//            NSLog(@"----left = %@, right = %@", NSStringFromCGPoint(CGPointMake(facialPoints_5[0].x, facialPoints_5[0].y)), NSStringFromCGPoint(CGPointMake(facialPoints_5[1].x, facialPoints_5[1].y)));
//            if (left.y < right.y)
            {
//                if(_desiredPosition == AVCaptureDevicePositionBack)
//                {
//                    CGPoint _exchangeLR = CGPointMake(left.x, left.y);
//                    
//                    left.x = 1.0 - right.x;
//                    left.y = right.y;
//                    
//                    right.x = 1.0 - _exchangeLR.x;
//                    right.y = _exchangeLR.y;
//                    
//                    ptNose.x = 1.0 - ptNose.x;
//                    mouthUp.x = 1.0 - mouthUp.x;
//                }
                
                //是否需要指定点
                for (HJEffectImage *effectImage in self.currentEffect.effectImages)
                {
                    if (4 == effectImage.mid_Type && effectImage.mid_Index_q >= 0 && effectImage.mid_Index_q < 95) {
                        CGPoint mid_point = CGPointMake(facialPoints[effectImage.mid_Index_q].x / iHeight, facialPoints[effectImage.mid_Index_q].y / iWidth);
//                        if(_desiredPosition == AVCaptureDevicePositionBack)
//                        {
//                            mid_point.x = 1.0 - mid_point.x;
//                        }
                        effectImage.cur_mid_Point = mid_point;
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (HJEffectImage *effectImage in self.currentEffect.effectImages) {
                        [self updateFilter_qihoo:effectImage leftEye:left rightEye:right nose:ptNose mouthUp:mouthUp];
                    }
                } ) ;
            }
        }
            break;
            
            //换脸
//        case 2:
//        {
//            DVec2f allPoint[95];
//            for (int j = 0; j < 95; j++) {
//                qh_pointf_t point = facialPoints[j];
//                if(_desiredPosition == AVCaptureDevicePositionBack)
//                {
//                    allPoint[j] = {(float)(iHeight - point.x),point.y};
//                } else {
//                    allPoint[j] = {point.x, point.y};
//                }
//            }
//            
//            if (0 == i) {
//                faceMorph.setParam(iHeight, iWidth, allPoint, 95);
//            }
//            
//            switch (self.currentEffect.effectImage.faceMorph_Type) {
//                case 1:
//                {
//                }
//                    break;
//                    
//                default:
//                {
//                    bool ret = faceMorph.morph();
//                    GPUImageFaceSkinFilter * faceFilter = (GPUImageFaceSkinFilter *)self.currentEffect.effectImage.skinFilter;
//                    if (ret) {
//                        faceFilter.org_cnt_ = CGPointMake(faceMorph.getOrg_cnt().x, faceMorph.getOrg_cnt().y);
//                        faceFilter.msk_cnt_ = CGPointMake(faceMorph.getMsk_cnt().x, faceMorph.getMsk_cnt().y);
//                        [faceFilter setMsk:faceMorph.getMask_data() width:faceMorph.getMask_cols() height:faceMorph.getMask_rows() fsn:fsn];
//                        [faceFilter setTransforms:faceMorph.getTransforms() fsn:fsn];
//                        
//                        faceFilter.mfaceCount = 1;
//                    }
//                    else {
//                        faceFilter.mfaceCount = 0;
//                    }
//                }
//                    break;
//            }
//            
//        }
            break;
        default:
            break;
    }
        }

}

#define KScreenWidth [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight [[UIScreen mainScreen] bounds].size.height

- (void)updateFilter_qihoo:(HJEffectImage *)object leftEye:(CGPoint)leftEye rightEye:(CGPoint)rightEye nose:(CGPoint)nose mouthUp:(CGPoint) mouthUp
{
    if([object.skinFilter isKindOfClass:[GPUImageCatEarFilter class]])
    {
        GPUImageCatEarFilter* cat=(GPUImageCatEarFilter*)object.skinFilter;
        cat.mfaceCount=0;
        
        //头偏转角度
        if (object.radius_Type == 0) {
            cat.mradius0=atan2((leftEye.y - rightEye.y ) * KScreenHeight,(rightEye.x - leftEye.x) * KScreenWidth);
        }
        else {
            cat.mradius0 = object.mradius;
        }
        if ((nose.x < 0.40 && !object.isRight)) {
            object.isRight = YES;
        }
        if (nose.x > 0.6 && object.isRight) {
            object.isRight = NO;
        }
        
        //眼睛中点 --- 不同计算||配置
        switch (object.mid_Type) {
            case 2: //x y均指定值
            {
                cat.mmid0=CGPointMake(object.mid_x, object.mid_y);
            }
                break;
            case 1: //ptNose
            {
                cat.mmid0=nose;
            }
                break;
            case 3: //mouthUp
            {
                cat.mmid0=mouthUp;
            }
                break;
            case 4: //sdk取值
            {
                cat.mmid0=object.cur_mid_Point;
            }
                break;
            default:    //x y 均计算
            {
                cat.mmid0=CGPointMake((rightEye.x-leftEye.x)/2+leftEye.x,((rightEye.y-leftEye.y)/2+leftEye.y));
            }
                break;
        }
        
        float scale=1.0;
        if (object.scale_Type == 0) {
            float dis=sqrtf((rightEye.x-leftEye.x)*(rightEye.x-leftEye.x)+(rightEye.y-leftEye.y)*(rightEye.y-leftEye.y))*720;
            scale=dis/object.scale_ratio;
        }
        else {
            scale=object.scale_ratio;
        }
        if (object.isSuitDirection && object.isRight) {
            cat.bSuit = 1;
            cat.manchor0=CGPointMake(object.anchor_offset_suit_x * scale, object.anchor_offset_suit_y * scale);   // ----- 需配置
        } else {
            cat.bSuit = 0;
            cat.manchor0=CGPointMake(object.anchor_offset_x * scale, object.anchor_offset_y * scale);   // ----- 需配置
        }
        
        cat.msize0=CGPointMake(object.asize_offset_x * scale, object.asize_offset_y * scale);   // ----- 需配置
        cat.mframeCount=cat.frameCount;
        cat.mfaceCount=object.mfaceCount;   //几张脸
    }
}


@end







