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
@synthesize photoButton;
@synthesize messageTextView;
@synthesize positionButton;

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
    [audioPlot setFrame:CGRectMake(audioPlot.frame.origin.x, buttonsContainerView.frame.origin.y - audioPlot.frame.size.height, audioPlot.frame.size.width, audioPlot.frame.size.height)];
    if(startRecord)
    {
        [self prepareToRecord];
    }
    [photoButton.layer setCornerRadius:photoButton.frame.size.width/2];
    [photoButton.layer setMasksToBounds:YES];
    [photoButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [photoButton.layer setShadowRadius:2.0];
    [photoButton.layer setBorderWidth:1.0];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.microphone stopFetchingAudio];
    self.isRecording = NO;
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
    if([UserProfile sharedProfile].spokesArray == nil)
    {
        [UserProfile sharedProfile].spokesArray = [[NSMutableArray alloc]init];
    }

    UserProfile *prof = [UserProfile sharedProfile];
    Spoke *spokeObj = [[Spoke alloc]init];
    spokeObj.ownerID = [[UserProfile sharedProfile] getUserID];
    spokeObj.spokeID = [Utilities soundFilePathString];
    spokeObj.creationDate = [NSDate date];
//    spokeObj.updateDate = [NSDate date];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSURL *soundUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.m4a", basePath, spokeObj.spokeID]];
    spokeObj.audioData = [[NSData alloc] initWithContentsOfURL:soundUrl options:NSDataReadingMappedIfSafe error:nil];
    spokeObj.ownerName = [[prof.currentUser objectForKey:@"profile"] objectForKey:@"fullName"];
    spokeObj.ownerImageData = [[prof.currentUser objectForKey:@"profile"] objectForKey:USER_IMAGE_DATA];
    if ([imageData length] > 0)
    {
        spokeObj.spokeImageData = imageData;
    }
    if (location != nil)
    {
        spokeObj.spokeLocation = location.locManager.location;
    }
    
    if(respokenSpoke != nil)
    {
        spokeObj.respokeToSpokeID = respokenSpoke.spokeID;
        [respokenVC.respokenArray addObject:spokeObj];
        respokenVC.respokenArray = [Utilities orderByDate:respokenVC.respokenArray];
        respokenVC.fromRecordView = YES;
        if(respokenVC.headerSpoke.listOfRespokeID == nil)
        {
            respokenVC.headerSpoke.listOfRespokeID = [[NSMutableArray alloc]init];
        }
        [respokenVC.headerSpoke.listOfRespokeID addObject:spokeObj.spokeID];
        [[UserProfile sharedProfile] updateRespokenList:respokenVC.headerSpoke.spokeID respokeID:spokeObj.spokeID removeRespoken:NO];
 
        for (int i = 0; i < [[UserProfile sharedProfile].cacheSpokesArray count]; i++)
        {
            Spoke *tempSpoke = [[UserProfile sharedProfile].cacheSpokesArray objectAtIndex:i];
            if ([tempSpoke.spokeID isEqualToString:respokenVC.headerSpoke.spokeID])
            {
                [[UserProfile sharedProfile].cacheSpokesArray replaceObjectAtIndex:i withObject:respokenVC.headerSpoke];
            }
        }
        for (int i = 0; i < [[UserProfile sharedProfile].spokesArray count]; i++)
        {
            Spoke *tempSpoke = [[UserProfile sharedProfile].spokesArray objectAtIndex:i];
            if ([tempSpoke.spokeID isEqualToString:respokenVC.headerSpoke.spokeID])
            {
                [[UserProfile sharedProfile].spokesArray replaceObjectAtIndex:i withObject:respokenVC.headerSpoke];
            }
        }
    }
   
    [[UserProfile sharedProfile].spokesArray addObject:spokeObj];
    [[UserProfile sharedProfile].cacheSpokesArray addObject:spokeObj];
    [[UserProfile sharedProfile] saveProfileLocal];
    [[UserProfile sharedProfile] saveSpokesArrayRemote:spokeObj];
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:NEW_SPOKE_ADDED];
    [saveButton setEnabled:NO];
    [saveButton setAlpha:0.2];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:RELOAD_SPOKES_LIST object:nil];
    }];
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

#pragma mark image management
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    CGSize sz = CGSizeMake(100, 100);
    UIGraphicsBeginImageContext(sz);
    [image drawInRect:CGRectMake(0,0,100,100)];
    UIImage *im2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [photoButton setBackgroundImage:im2 forState:UIControlStateNormal];
    [photoButton setTitle:@"" forState:UIControlStateNormal];
    
    if(image != nil)
    {
        imageData = UIImagePNGRepresentation(im2);
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)photoButtonPressed:(id)sender
{
    UIActionSheet *profileImageActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"From Memory", @""), NSLocalizedString(@"From Camera", @""), nil];
    
    [profileImageActionSheet showInView:self.view];
}

#pragma mark ActionSheet and AlertView Delegate Methods

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==2)
        return;
    
    if(buttonIndex==1 && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        //not available
        UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Camera is not available", @"") delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alertView2 show];
        return;
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    
    if(buttonIndex==0)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    if(buttonIndex==1)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"BUTTON INDEX %d", (int)buttonIndex);
    switch (buttonIndex)
    {
            //Change
        case 0:
            break;
        case 1:
            break;
        default:
            break;
    }
}

- (IBAction)positionButtonPressed:(id)sender
{
    location = [LocationController sharedObject];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        if (!location)
        {
            location = [LocationController sharedObject];
        }
        
        [location.locManager requestAlwaysAuthorization];
        [location.locManager startMonitoringSignificantLocationChanges];
    }
    else
    {
        if (!location)
        {
            location = [LocationController sharedObject];
        }
        [location.locManager startMonitoringSignificantLocationChanges];
    }
    NSLog(@"LOCATION %f", location.locManager.location.coordinate.latitude);
}

@end
