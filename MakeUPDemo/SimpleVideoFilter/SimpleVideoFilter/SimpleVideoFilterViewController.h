#import <UIKit/UIKit.h>
#import "GPUImageVideoCamera.h"
#import "WKGPUImageMovieWriter.h"

@interface SimpleVideoFilterViewController : UIViewController <WKGPUImageMovieWriterDelegate>
{
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageOutput<GPUImageInput> *filter_face_feature;
    WKGPUImageMovieWriter *movieWriter;
}

- (IBAction)updateSliderValue:(id)sender;

@end
