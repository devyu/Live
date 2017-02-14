//
//  TableViewController.m
//  LiveDemo
//
//  Created by mac on 2017/2/14.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "VideoRecordingVC.h"
#import <GPUImage/GPUImage.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "NSObject+Alert.h"


@interface VideoRecordingVC ()
@property (nonatomic , strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic , strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic , strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic , strong) GPUImageView *filterView;
@property (nonatomic , assign) long     mLabelTime;
@property (nonatomic , strong) NSTimer  *mTimer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarItem;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end


@implementation VideoRecordingVC

- (IBAction)record:(UIBarButtonItem *)sender {
  [self prepareRecording:sender.title];
}

- (IBAction)sliderValueChange:(UISlider *)sender {
  [(GPUImageSepiaFilter *)_filter setIntensity:[(UISlider *)sender value]];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
  _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;//[UIApplication sharedApplication].statusBarOrientation;
  _filter = [[GPUImageSepiaFilter alloc] init];
  _filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
  [self.view insertSubview:_filterView atIndex:0];

  
  [_videoCamera addTarget:_filter];
  [_filter addTarget:_filterView];
  [_videoCamera startCameraCapture];
  
//  [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//    _videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
//  }];
  
}



- (void)onTimer:(id)sender {
  _timeLabel.text = [NSString stringWithFormat:@"录制时间:%lds", _mLabelTime++];
}

- (void)prepareRecording:(NSString *)title {
  NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie6.mp4"];
  NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
  if([title isEqualToString:@"录制"]) {
    _rightBarItem.title = @"结束";
    NSLog(@"Start recording");
    unlink([pathToMovie UTF8String]); // 如果已经存在文件，AVAssetWriter会有异常，删除旧文件
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(320.0, 480.0)];
    _movieWriter.encodingLiveVideo = YES;
    [_filter addTarget:_movieWriter];
    _videoCamera.audioEncodingTarget = _movieWriter;
    [_movieWriter startRecording];
    
    _mLabelTime = 0;
    [self onTimer:nil];
    _mTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
  }
  else {
    _rightBarItem.title = @"录制";
    NSLog(@"End recording");
    if (_mTimer) {
      [_mTimer invalidate];
    }
    [_filter removeTarget:_movieWriter];
    _videoCamera.audioEncodingTarget = nil;
    [_movieWriter finishRecording];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self compressVideo];
    });
    
    // 视频写入相册
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToMovie)) {
      [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
           if (error) {
             [self showAlert:@"视频保存失败"];
           } else {
             [self showAlert:@"视频保存成功"];
             
           }
         });
       }];
    }
  }
}



// 压缩视频
- (void)compressVideo {
  
  NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie6.mp4"];
  NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
  // 通过文件的 url 获取到这个文件的资源
  AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:movieURL options:nil];
  // 用 AVAssetExportSession 这个类来导出资源中的属性
  NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
  
  // 压缩视频
  if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) { // 导出属性是否包含低分辨率
    // 通过资源（AVURLAsset）来定义 AVAssetExportSession，得到资源属性来重新打包资源 （AVURLAsset, 将某一些属性重新定义
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    // 设置导出文件的存放路径
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSDate    *date = [[NSDate alloc] init];
    NSString *outPutPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"output-%@.mp4",[formatter stringFromDate:date]]];
    exportSession.outputURL = [NSURL fileURLWithPath:outPutPath];
    
    NSLog(@"录制好文件path = %@", outPutPath);
    
    CMTime start = CMTimeMakeWithSeconds(0.0, 0);
    CMTimeRange range = CMTimeRangeMake(start, [avAsset duration]);
    exportSession.timeRange = range;
    
    //        exportSession.videoComposition;
    
    // 是否对网络进行优化
    exportSession.shouldOptimizeForNetworkUse = true;
    
    // 转换成MP4格式
    exportSession.outputFileType = AVFileTypeMPEG4;
    
    // 开始导出,导出后执行完成的block
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
      // 如果导出的状态为完成
      
      NSLog(@"state %ld", (long)exportSession.status);
      
      if ([exportSession status] == AVAssetExportSessionStatusFailed) {
        NSLog(@"压缩失败的--%@", exportSession.error);
      }
      
      if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
        dispatch_async(dispatch_get_main_queue(), ^{
          // 更新一下显示包的大小
          NSLog(@"压缩后的大小--%@", [NSString stringWithFormat:@"%f MB",[self getfileSize:outPutPath]]);
        });
      }
    }];
  } else {
    NSLog(@"faile ");
  }
}

- (CGFloat)getfileSize:(NSString *)path {
  NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
  NSLog (@"file size: %f", (unsigned long long)[outputFileAttributes fileSize]/1024.00 /1024.00);
  return (CGFloat)[outputFileAttributes fileSize]/1024.00 /1024.00;
}

@end
