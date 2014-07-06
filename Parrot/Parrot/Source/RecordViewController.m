//
//  RecordViewController.m
//  Parrot
//
//  Created by Marco Argiolas on 01/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "RecordViewController.h"
#import "Utilities.h"

@interface RecordViewController ()

@end

@implementation RecordViewController

@synthesize recordButton;
@synthesize audioPlayer;
@synthesize recorder;
@synthesize audioPlot;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    self.audioPlot.backgroundColor = [UIColor blackColor];
    // Waveform color
    self.audioPlot.color           = [UIColor whiteColor];
    // Plot type
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    // Fill
    self.audioPlot.shouldFill      = YES;
    // Mirror
    self.audioPlot.shouldMirror    = YES;
    
    /*
     Log out where the file is being written to within the app's documents directory
     */
 
    [self.microphone startFetchingAudio];
    
    [buttonsContainerView setFrame:CGRectMake(buttonsContainerView.frame.origin.x, self.view.frame.size.height - buttonsContainerView.frame.size.height, buttonsContainerView.frame.size.width, buttonsContainerView.frame.size.height)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [recordButton addGestureRecognizer:longPress];
    
    [hintContainerView setFrame:CGRectMake(hintContainerView.frame.origin.x, buttonsContainerView.frame.origin.y - hintContainerView.frame.size.height, hintContainerView.frame.size.width, hintContainerView.frame.size.height)];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    // Set up an observer for proximity changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    userProf = [UserProfile sharedProfile];
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)dealloc
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)sensorStateChange:(NSNotificationCenter *)notification
{
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        [self startRecording];
    }
    else
    {
        [self stopRecording];
    }
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        [self startRecording];
    }
    else if ( gesture.state == UIGestureRecognizerStateEnded )
    {
        
        [self stopRecording];
    }
}

- (void)startRecording
{
    NSLog(@"START RECORDING");
    [hintContainerView removeFromSuperview];
    if( self.audioPlayer )
    {
        if( self.audioPlayer.playing )
        {
            [self.audioPlayer stop];
        }
        self.audioPlayer = nil;
    }
    self.isRecording = YES;
    /*
     Create the recorder
     */
    self.recorder = [EZRecorder recorderWithDestinationURL:[Utilities soundFilePathUrl]
                                              sourceFormat:self.microphone.audioStreamBasicDescription
                                       destinationFileType:EZRecorderFileTypeM4A];
}

- (void) stopRecording
{
    NSLog(@"STOP RECORDING");
    [self.microphone stopFetchingAudio];
    self.isRecording = NO;
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self.microphone stopFetchingAudio];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender
{
    [self.recorder closeAudioFile];
    if(userProf.spokesArray == nil)
    {
        userProf.spokesArray = [[NSMutableArray alloc]init];
    }
    [userProf.spokesArray addObject:[Utilities soundFilePathString]];
    [userProf saveProfileLocal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EZMicrophoneDelegate
#warning Thread Safety
// Note that any callback that provides streamed audio data (like streaming microphone input) happens on a separate audio thread that should not be blocked. When we feed audio data into any of the UI components we need to explicity create a GCD block on the main thread to properly get the UI to work.
-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    // Getting audio data as an array of float buffer arrays. What does that mean? Because the audio is coming in as a stereo signal the data is split into a left and right channel. So buffer[0] corresponds to the float* data for the left channel while buffer[1] corresponds to the float* data for the right channel.
    
    // See the Thread Safety warning above, but in a nutshell these callbacks happen on a separate audio thread. We wrap any UI updating in a GCD block on the main thread to avoid blocking that audio flow.
    dispatch_async(dispatch_get_main_queue(),^{
        // All the audio plot needs is the buffer data (float*) and the size. Internally the audio plot will handle all the drawing related code, history management, and freeing its own resources. Hence, one badass line of code gets you a pretty plot :)
        [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    
    // Getting audio data as a buffer list that can be directly fed into the EZRecorder. This is happening on the audio thread - any UI updating needs a GCD main queue block. This will keep appending data to the tail of the audio file.
    if( self.isRecording )
    {
        [self.recorder appendDataFromBufferList:bufferList  withBufferSize:bufferSize];
    }
    
}

#pragma mark - AVAudioPlayerDelegate
/*
 Occurs when the audio player instance completes playback
 */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    audioPlayer = nil;
//    self.playingTextField.text = @"Finished Playing";
    
    [self.microphone startFetchingAudio];
//    self.microphoneSwitch.on = YES;
//    self.microphoneTextField.text = @"Microphone On";
}

@end
