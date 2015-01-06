//
//  ViewController.h
//  RecordingTest
//
//  Created by 张海迪 on 15/1/6.
//  Copyright (c) 2015年 haidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    
    IBOutlet UIButton *recordButton;
    IBOutlet UIButton *playButton;
}
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
- (IBAction)record:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *fileNameLabel;

- (IBAction)play:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *fileSizeLabel;
- (IBAction)stop:(id)sender;

@end

