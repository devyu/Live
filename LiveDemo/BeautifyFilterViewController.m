//
//  BeautifyFilterViewController.m
//  LiveDemo
//
//  Created by mac on 2017/2/13.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "BeautifyFilterViewController.h"
#import <GPUImage/GPUImage.h>

@interface BeautifyFilterViewController ()
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, weak) GPUImageView *captureVideoPreview;

// 美白滤镜：提高亮度
@property (weak, nonatomic) GPUImageBrightnessFilter *brightnessFilter;
// 磨皮滤镜: 双边模糊
@property (weak, nonatomic) GPUImageBilateralFilter *bilateraFilter;
@end

@implementation BeautifyFilterViewController


- (void)viewDidLoad {
  [super viewDidLoad];
  
  
  GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionFront];
  videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
  _videoCamera = videoCamera;

  // 预览View
  GPUImageView *captureVideoPreview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
  [self.view insertSubview:captureVideoPreview atIndex:0];
  _captureVideoPreview = captureVideoPreview;

  // ------------
  // 创建滤镜：磨皮、美白、组合滤镜
  GPUImageFilterGroup *groupFilter = [[GPUImageFilterGroup alloc] init];
  GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc] init];
  [groupFilter addTarget:bilateralFilter];
  _bilateraFilter = bilateralFilter;
  GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
  [groupFilter addTarget:brightnessFilter];
  _brightnessFilter = brightnessFilter;
  // 设置滤镜组链
  [bilateralFilter addTarget:brightnessFilter];
  [groupFilter setInitialFilters:@[bilateralFilter]];
  groupFilter.terminalFilter = brightnessFilter;
  

  // ------------
  
  // 设置处理链
  [_videoCamera addTarget:groupFilter];
  [groupFilter addTarget:_captureVideoPreview];
  // 开始采集视频，必须调用startCameraCapture，底层才会把采集到的视频源，渲染到GPUImageView中
  [videoCamera startCameraCapture];
}


// 美颜：本质是提高亮度
- (IBAction)beatutifyFilterValueChange:(UISlider *)sender {
  [_bilateraFilter setDistanceNormalizationFactor:(5-sender.value)];
}

// 磨皮：本质是像素点模糊
- (IBAction)brightnessFilterValueChange:(UISlider *)sender {
  _brightnessFilter.brightness = sender.value;
}

@end
