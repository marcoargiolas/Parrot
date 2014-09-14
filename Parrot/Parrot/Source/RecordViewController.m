//
//  RecordViewController.m
//  Parrot
//
//  Created by Marco Argiolas on 01/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "RecordViewController.h"
#import "Utilities.h"
#import "Spoke.h"
#import "GlobalDefines.h"

@interface RecordViewController ()

@end

@implementation RecordViewController

@synthesize recordButton;
@synthesize audioPlayer;
@synthesize recorder;
@synthesize audioPlot;
@synthesize saveButton;
@synthesize startRecord;
@synthesize respokenSpoke;
@synthesize respokenVC;

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
    self.audioPlot.plotType        = EZPlotTypeRolling;
    // Fill
    self.audioPlot.shouldFill      = YES;
    // Mirror
    self.audioPlot.shouldMirror    = YES;
    
    /*
     Log out where the file is being written to within the app's documents directory
     */
    
    [buttonsContainerView setFrame:CGRectMake(buttonsContainerView.frame.origin.x, self.view.frame.size.height - buttonsContainerView.frame.size.height, buttonsContainerView.frame.size.width, buttonsContainerView.frame.size.height)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [recordButton addGestureRecognizer:longPress];
    
    [saveButton setEnabled:NO];
    [saveButton setAlpha:0.2];
    [hintContainerView setFrame:CGRectMake(hintContainerView.frame.origin.x, buttonsContainerView.frame.origin.y - hintContainerView.frame.size.height, hintContainerView.frame.size.width, hintContainerView.frame.size.height)];
    
    userProf = [UserProfile sharedProfile];
    if(startRecord)
    {
        [self prepareToRecord];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    respokenVC = nil;
    startRecord = NO;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)dealloc
{
    
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
        [self prepareToRecord];
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
        [self prepareToRecord];
    }
    else if ( gesture.state == UIGestureRecognizerStateEnded )
    {
        
        [self stopRecording];
    }
}

-(void)prepareToRecord
{
    [recordButton setSelected:YES];
    NSURL *soundUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/startRecord.wav", [[NSBundle mainBundle] resourcePath]]];
    
    NSError *dataError;
    NSData *soundData = [[NSData alloc] initWithContentsOfURL:soundUrl options:NSDataReadingMappedIfSafe error:&dataError];
    if(dataError != nil)
    {
        NSLog(@"DATA ERROR %@", dataError);
    }
    
    NSError *error;
    player =[[AVAudioPlayer alloc] initWithData: soundData error: &error];
    player.delegate = self;

    [player prepareToPlay];
    [player play];
}

- (void)startRecording
{
    NSLog(@"START RECORDING");
    [self.microphone startFetchingAudio];
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
//    [NSTimer scheduledTimerWithTimeInterval:10.0
//                                     target:self
//                                   selector:@selector(stopRecording)
//                                   userInfo:nil
//                                    repeats:NO];
}

- (void) stopRecording
{
    NSLog(@"STOP RECORDING");
    [self prepareToRecord];
    [recordButton setSelected:NO];
    [self.microphone stopFetchingAudio];
    self.isRecording = NO;
    [saveButton setEnabled:YES];
    [saveButton setAlpha:1.0];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    startRecord = NO;
    [self.microphone stopFetchingAudio];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender
{
    startRecord = NO;
    [self.recorder closeAudioFile];
    if(userProf.spokesArray == nil)
    {
        userProf.spokesArray = [[NSMutableArray alloc]init];
    }

    UserProfile *prof = [UserProfile sharedProfile];
    Spoke *spokeObj = [[Spoke alloc]init];
    spokeObj.ownerID = [userProf getUserID];
    spokeObj.spokeID = [Utilities soundFilePathString];
    spokeObj.creationDate = [NSDate date];
    spokeObj.updateDate = [NSDate date];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSURL *soundUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.m4a", basePath, spokeObj.spokeID]];
    spokeObj.audioData = [[NSData alloc] initWithContentsOfURL:soundUrl options:NSDataReadingMappedIfSafe error:nil];
    spokeObj.ownerName = [[prof.currentUser objectForKey:@"profile"] objectForKey:@"fullName"];
    spokeObj.ownerImageData = [[prof.currentUser objectForKey:@"profile"] objectForKey:USER_IMAGE_DATA];
    
    if(respokenSpoke != nil)
    {
        spokeObj.respokeToSpokeID = respokenSpoke.spokeID;
        [respokenVC.respokenArray addObject:spokeObj];
        respokenVC.fromRecordView = YES;
        if(respokenVC.currentSpoke.listOfRespokeID == nil)
        {
            respokenVC.currentSpoke.listOfRespokeID = [[NSMutableArray alloc]init];
        }
        [respokenVC.currentSpoke.listOfRespokeID addObject:spokeObj.spokeID];
        [userProf updateRespokenList:respokenVC.currentSpoke.spokeID respokeID:spokeObj.spokeID];
    }
   
    [userProf.spokesArray addObject:spokeObj];
    [userProf.cacheSpokesArray addObject:spokeObj];
    [userProf saveProfileLocal];
    [userProf saveSpokesArrayRemote:spokeObj];
    
    [saveButton setEnabled:NO];
    [saveButton setAlpha:0.2];
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
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(recordButton.selected)
    {
        NSLog(@"SELECTED");
        [self startRecording];
    }
    else
    {
        NSLog(@"NON SELECTED");
        
    }
        
//    audioPlayer = nil;
//    self.playingTextField.text = @"Finished Playing";
    
//    [self.microphone startFetchingAudio];
//    self.microphoneSwitch.on = YES;
//    self.microphoneTextField.text = @"Microphone On";
}

- (IBAction)recordButtonPressed:(id)sender
{
    if (self.isRecording)
    {
        [self stopRecording];
    }
    else
    {
        [self prepareToRecord];
    }
}
@end
