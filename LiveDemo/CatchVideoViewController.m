//
//  CatchVideoViewController.m
//  LiveDemo
//
//  Created by mac on 2017/2/9.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "CatchVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "NSObject+Alert.h"

#define kBegainRecord @"开始录制"
#define kStopRecord @"停止录制"

@interface CatchVideoViewController ()<AVCaptureFileOutputRecordingDelegate>
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong) AVCaptureMovieFileOutput *videoOutput;
@end



@implementation CatchVideoViewController


- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"开始录制"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(record:)];
  
  // 1.创建device
  _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  
  // 2.deviceInput
  _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:nil];
  _videoOutput = [[AVCaptureMovieFileOutput alloc] init];
  
  // 3.captureSession
  _captureSession = [[AVCaptureSession alloc] init];
  [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
  
  // 4.preview
  _preview = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
  _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
  _preview.frame = self.view.layer.bounds;
  
  
  if ([_captureSession canAddInput:_videoDeviceInput]) {
    [_captureSession addInput:_videoDeviceInput];
  }
  if ([_captureSession canAddOutput:_videoOutput])
  {
    [_captureSession addOutput:_videoOutput];
  }
  
  [self.view.layer insertSublayer:self.preview atIndex:0];
  [self.captureSession startRunning];
}


- (void)record:(UIBarItem *)sender {
  if ([sender.title isEqualToString:kBegainRecord]) {
    sender.title = kStopRecord;
    AVCaptureConnection *videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([videoConnection isVideoStabilizationSupported]) {
      // 提升视频稳定性
      videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeStandard;
    }
    // 平滑对焦没设置 方向没设置
    // 配置写到指定文件
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"test.mp4"]];
    NSLog(@"video url = %@", url);
    [self.videoOutput startRecordingToOutputFileURL:url recordingDelegate:self];
  } else {
    sender.title = kBegainRecord;
    [self.videoOutput stopRecording];
  }
}

// 视频停止录制时被调用，即使数据没有被成功的写入文件
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
  // 写入捕捉到的视频
  if (error) {
    [self showAlert:@"视频录制出错"];
  } else {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
      
      [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
      
      [self showAlert:@"保存成功"];
      NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
      NSFileManager *manager = [NSFileManager defaultManager];
      if (![manager fileExistsAtPath:[path stringByAppendingPathComponent:@"test.mp4"]]) {
        NSLog(@"文件不存在");
      } else {
        NSLog(@"文件存在");
      }
    }];
  }
}


@end
