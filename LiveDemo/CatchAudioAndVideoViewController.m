//
//  CatchAudioAndVideoViewController.m
//  LiveDemo
//
//  Created by mac on 2017/2/9.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "CatchAudioAndVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface CatchAudioAndVideoViewController ()
<
AVCaptureAudioDataOutputSampleBufferDelegate,
AVCaptureVideoDataOutputSampleBufferDelegate
>

@property (nonatomic, strong) AVCaptureSession *captureSession; // 捕捉会话
@property (nonatomic, strong) AVCaptureDevice *videoDevice; // 获取视频设备
@property (nonatomic, strong) AVCaptureDevice *audioDevice; // 获取音频设备
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput; // 视频输入对象
@property (nonatomic, strong) AVCaptureDeviceInput *audioDeviceInput; // 音频输入对象
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput; // 获取视频输出设备
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput; // 获取音频输出设备
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview; // 预览视图
@property (nonatomic, strong) AVCaptureConnection *audioConnection;
@property (nonatomic, strong) AVCaptureConnection *videoConnection; // 链接捕获的输入、输出对象
@end

@implementation CatchAudioAndVideoViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // 1.创建捕捉会话
  _captureSession = [[AVCaptureSession alloc] init];
  [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
  
  // 2.获取设备
  _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  
  // 3.获取声音
  _audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
  
  // 4.预览layer
  _preview = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
  _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
  _preview.frame = self.view.layer.bounds;
  
  // 5.创建视频、音频输入对象
  _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:nil];
  _audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.audioDevice error:nil];
  
  // 6.添加视频，音频到会话
  if ([_captureSession canAddInput:_videoDeviceInput]) {
    [_captureSession addInput:_videoDeviceInput];
  }
  if ([_captureSession canAddInput:_audioDeviceInput]) {
    [_captureSession addInput:_audioDeviceInput];
  }
  
  // 9.获取视频输入与输出连接，用于分辨音视频数据
  self.videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
  self.audioConnection = [self.audioOutput connectionWithMediaType:AVMediaTypeAudio];
  
  // 10.添加视频预览图层、
  [self.view.layer insertSublayer:self.preview atIndex:0];
  // 11.启动会话
  [_captureSession startRunning];
}

// 7.获取视频输出设备
- (AVCaptureAudioDataOutput *)audioOutput {
  if (!_audioOutput) {
    _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    // 这里的队列必须是串行队列，保证音频/视频按照视频帧按顺序到达
    dispatch_queue_t audioQueue = dispatch_queue_create("serial.audioQueue", DISPATCH_QUEUE_SERIAL);
    [_audioOutput setSampleBufferDelegate:self queue:audioQueue];
    if ([self.captureSession canAddOutput:_audioOutput]) {
      [_captureSession addOutput:_audioOutput];
    }
  }
  return _audioOutput;
}

// 8.获取音频输出设备
- (AVCaptureVideoDataOutput *)videoOutput {
  if (!_videoOutput) {
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    dispatch_queue_t videoQueue = dispatch_queue_create("serial.videoQueue", DISPATCH_QUEUE_SERIAL);
    [_videoOutput setSampleBufferDelegate:self queue:videoQueue];
    if ([self.captureSession canAddOutput:_videoOutput]) {
      [_captureSession addOutput:_videoOutput];
    }
  }
  return _videoOutput;
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
  if (self.videoConnection == connection) {
    NSLog(@"采集到视频数据");
    // 进行转码，准备推流到服务器
  } else if(self.audioConnection == connection) {
    NSLog(@"采集到音频");
  }
}

// 当丢失帧的时候，会调用这里
- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection NS_AVAILABLE(10_7, 6_0) {
  NSLog(@"丢失帧");
}

@end
