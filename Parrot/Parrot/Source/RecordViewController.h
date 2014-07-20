//
//  RecordViewController.h
//  Parrot
//
//  Created by Marco Argiolas on 01/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAudio.h"
#import <AVFoundation/AVFoundation.h>
#import "UserProfile.h"

#define kAudioFilePath @"EZAudioTest.m4a"

@interface RecordViewController : UIViewController <AVAudioPlayerDelegate,EZMicrophoneDelegate, UIGestureRecognizerDelegate>
{
    NSString *spokeFileName;
    IBOutlet UIView *buttonsContainerView;
    IBOutlet UIButton *recordButton;
    UserProfile *userProf;
    IBOutlet UIView *hintContainerView;
    IBOutlet UIButton *saveButton;
}
/**
 Use a OpenGL based plot to visualize the data coming in
 */
@property (nonatomic,weak) IBOutlet EZAudioPlotGL *audioPlot;

/**
 A flag indicating whether we are recording or not
 */
@property (nonatomic,assign) BOOL isRecording;

/**
 The microphone component
 */
@property (nonatomic,strong) EZMicrophone *microphone;

/**
 The recorder component
 */
@property (nonatomic,strong) EZRecorder *recorder;

#pragma mark - Actions
///**
// Stops the recorder and starts playing whatever has been recorded.
// */
//-(IBAction)playFile:(id)sender;
//
///**
// Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details);
// */
//-(IBAction)toggleMicrophone:(id)sender;
//
///**
// Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details);
// */
//-(IBAction)toggleRecording:(id)sender;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;



@end
