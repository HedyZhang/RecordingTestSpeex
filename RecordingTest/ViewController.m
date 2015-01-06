//
//  ViewController.m
//  RecordingTest
//
//  Created by 张海迪 on 15/1/6.
//  Copyright (c) 2015年 haidi. All rights reserved.
//

#import "ViewController.h"
#import "RecorderManager.h"
#import "PlayerManager.h"
@interface ViewController ()<RecordingDelegate, PlayingDelegate>
{
    NSTimer *timer;
    NSInteger timeCount;
    
}
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, copy) NSString *filename;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[RecorderManager sharedManager] setDelegate:self];
    
    [self addObserver:self forKeyPath:@"isRecording" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}
- (void)dealloc {
    [[RecorderManager sharedManager] setDelegate:nil];
    [self removeObserver:self forKeyPath:@"isRecording"];
    [self removeObserver:self forKeyPath:@"isPlaying"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)startTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
}
- (void)changeTime
{
    timeCount++;
    self.timeLabel.text = [NSString stringWithFormat:@"%lu", timeCount];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isRecording"]) {
        [recordButton setTitle:(self.isRecording ? @"停止录音" : @"录音") forState:UIControlStateNormal];
    }
    else if ([keyPath isEqualToString:@"isPlaying"]) {
        [playButton setTitle:(self.isPlaying ? @"停止播放" : @"播放") forState:UIControlStateNormal];
    }
}

- (IBAction)record:(id)sender
{
    if (self.isPlaying)
    {
        return;
    }
    if ( !self.isRecording)
    {
        self.isRecording = YES;
        [[RecorderManager sharedManager] startRecording];
        [self startTimer];
    }
}

- (IBAction)stop:(id)sender
{
    self.isRecording = NO;
    [[RecorderManager sharedManager] stopRecording];
    [timer invalidate];
    timeCount = 0;
   
}
- (IBAction)play:(id)sender
{
    if (self.isRecording)
    {
        return;
    }
    if ( !self.isPlaying)
    {
        [PlayerManager sharedManager].delegate = nil;
        self.isPlaying = YES;
        self.fileNameLabel.text = [NSString stringWithFormat:@"正在播放: %@", [self.filename substringFromIndex:[self.filename rangeOfString:@"Documents"].location]];
        [[PlayerManager sharedManager] playAudioWithFileName:self.filename delegate:self];
    }
    else
    {
        self.isPlaying = NO;
        [[PlayerManager sharedManager] stopPlaying];
    }
}
- (void)getFileSize
{
    NSString *path = self.filename;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
    {
       unsigned long long fileSize = [[fileManager attributesOfItemAtPath:path error:nil] fileSize];
        self.fileSizeLabel.text = [NSString stringWithFormat:@"%llu", fileSize / 1024];
    }
}

#pragma mark - RecorderManager Delegate Methods
- (void)recordingFinishedWithFileName:(NSString *)filePath time:(NSTimeInterval)interval
{
    self.isRecording = NO;
    self.filename = filePath;
    [self.fileNameLabel performSelectorOnMainThread:@selector(setText:)
                                        withObject:[NSString stringWithFormat:@"录音完成: %@", [self.filename substringFromIndex:[self.filename rangeOfString:@"Documents"].location]]
                                     waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(getFileSize) withObject:nil waitUntilDone:NO];
}
- (void)recordingTimeout
{
    self.isRecording = NO;
    self.fileNameLabel.text = @"录音超时";
    [self getFileSize];
}
- (void)recordingStopped  //录音机停止采集声音
{
    self.isRecording = NO;
}
- (void)recordingFailed:(NSString *)failureInfoString
{
    self.isRecording = NO;
    self.fileNameLabel.text = @"录音失败";
}
#pragma mark - PlayManager Delegate Method
- (void)playingStoped
{
    self.isPlaying = NO;
    self.fileNameLabel.text = [NSString stringWithFormat:@"播放完成: %@", [self.filename substringFromIndex:[self.filename rangeOfString:@"Documents"].location]];
}

@end
