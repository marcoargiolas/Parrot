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
#import "RespokenViewController.h"
#import "LocationController.h"
#import <SpeechKit/SpeechKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKReverseGeocoder.h>

#define kAudioFilePath @"EZAudioTest.m4a"

@interface RecordViewController : UIViewController <AVAudioPlayerDelegate,EZMicrophoneDelegate, UIGestureRecognizerDelegate, AVAudioSessionDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SpeechKitDelegate, SKRecognizerDelegate, UITextViewDelegate>
{
    NSString *spokeFileName;
    IBOutlet UIView *buttonsContainerView;
    IBOutlet UIButton *recordButton;
    IBOutlet UIView *hintContainerView;
    IBOutlet UIButton *saveButton;
    BOOL startRecord;
//    AVAudioPlayer *player;
    Spoke *respokenSpoke;
    RespokenViewController *respokenVC;
    
    IBOutlet UITextView *messageTextView;
    IBOutlet UIButton *photoButton;
    IBOutlet UIButton *positionButton;
    NSData *imageData;
    LocationController* location;
    SKRecognizer* voiceSearch;
    enum {
        TS_IDLE,
        TS_INITIAL,
        TS_RECORDING,
        TS_PROCESSING,
    } transactionState;

    NSMutableArray *hashTagArray;
    NSData *spokePositionImageData;
    NSString *spokeAddress;
}

@property (strong, nonatomic) IBOutlet UILabel *spokeAddressLabel;
@property(readonly)         SKRecognizer* voiceSearch;
@property (strong, nonatomic) IBOutlet UITextView *messageTextView;
@property (strong, nonatomic) IBOutlet UIButton *photoButton;
@property (nonatomic, strong) RespokenViewController *respokenVC;
@property (strong, nonatomic) IBOutlet UIButton *positionButton;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) BOOL startRecord;
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
//@property (nonatomic,strong) AVAudioPlayer *player;
@property (strong, nonatomic) Spoke *respokenSpoke;

- (IBAction)recordButtonPressed:(id)sender;
- (IBAction)photoButtonPressed:(id)sender;
- (IBAction)positionButtonPressed:(id)sender;


@end
