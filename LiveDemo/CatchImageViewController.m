//
//  CatchImageViewController.m
//  LiveDemo
//
//  Created by mac on 2017/2/9.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "CatchImageViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSObject+Alert.h"
#import <Photos/Photos.h>

@interface CatchImageViewController ()
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *imageOutput; // 将捕捉到的Video转化为图片
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;  // 预览layer
@end


@implementation CatchImageViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  
  self.navigationItem.rightBarButtonItem =
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                target:self
                                                action:@selector(takePictures)];
  
  // 1.创建设备
  _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  // 2.创建设备输入
  _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:nil];
  // 3. 添加device到session
  _captureSession = [[AVCaptureSession alloc] init];
  [_captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
  if ([_captureSession canAddInput:_videoDeviceInput]) {
    [_captureSession addInput:_videoDeviceInput];
  }
  
  //4. 添加预览层
  _preview = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
  _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
  _preview.frame = self.view.layer.bounds;
  [self.view.layer insertSublayer:_preview atIndex:0];
  
  //5. 启动会话
  [self.captureSession startRunning];
  
}

- (void)takePictures {
  AVCaptureConnection *stillImageConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
  
  // 这个函数将在某个未指定的线程上被调用
  [self.imageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
    if (!imageDataSampleBuffer) {
      return ;
    }
    
    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    UIImage *image = [UIImage imageWithData:imageData];
    // 请求访问相册
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
    if (authorStatus == PHAuthorizationStatusAuthorized) {
      [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        NSLog(@" 拍照得到的图片 = %@", image);
      } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
#warning TODO: fix 由于授权原因导致第一张照片为黑色
          [self showAlert:@"保存完成,第一张也许是黑色的，多拍几张"];
        }
        
      }];
    } else {
      [self showAlert:@"没有相册访问权限"];
    }
  }];
}

- (AVCaptureStillImageOutput *)imageOutput {
  if (!_imageOutput) {
    _imageOutput = [[AVCaptureStillImageOutput alloc] init];
    _imageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    if ([self.captureSession canAddOutput:_imageOutput]) {
      [_captureSession addOutput:_imageOutput];
    }
  }
  return _imageOutput;
}


@end
