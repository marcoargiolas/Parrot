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

const unsigned char SpeechKitApplicationKey[] = {0x89, 0xe2, 0x81, 0x7f, 0x25, 0x20, 0x30, 0xfa, 0x7a, 0xea, 0x80, 0x00, 0x4c, 0xdc, 0x26, 0xd2, 0xb3, 0x72, 0xc4, 0x99, 0x36, 0x1e, 0xb4, 0x2a, 0x0f, 0xf2, 0x46, 0x00, 0x32, 0x93, 0x57, 0xbb, 0x75, 0xd9, 0x3a, 0x9b, 0xf9, 0x6a, 0x95, 0x73, 0x55, 0x16, 0x74, 0xa1, 0xf2, 0x9a, 0x73, 0xa5, 0x0d, 0x37, 0x3f, 0x43, 0x55, 0xf3, 0x6d, 0x64, 0xe6, 0xb3, 0x65, 0x18, 0x47, 0xbc, 0xd4, 0xbc};

@implementation RecordViewController

@synthesize recordButton;
@synthesize recorder;
@synthesize audioPlot;
@synthesize saveButton;
@synthesize startRecord;
@synthesize respokenSpoke;
@synthesize respokenVC;
@synthesize photoButton;
@synthesize messageTextView;
@synthesize positionButton;
@synthesize voiceSearch;


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
    
    [positionButton.layer setCornerRadius:photoButton.frame.size.width/2];
    [positionButton.layer setMasksToBounds:YES];
    [positionButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [positionButton.layer setShadowRadius:2.0];
    [positionButton.layer setBorderWidth:1.0];
    
    hashTagArray = [[NSMutableArray alloc]init];

    [SpeechKit setupWithID:@"NMDPTRIAL_marco_argiolas20141218095517"
                      host:@"sandbox.nmdp.nuancemobility.net"
                      port:443
                    useSSL:NO
                  delegate:nil];
    [SpeechKit setEarcon:[SKEarcon earconWithName:@"startRecord.wav"] forType:SKStartRecordingEarconType];
    [SpeechKit setEarcon:[SKEarcon earconWithName:@"startRecord.wav"] forType:SKStopRecordingEarconType];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.microphone stopFetchingAudio];
    [voiceSearch stopRecording];
    [voiceSearch cancel];

    self.isRecording = NO;
    respokenVC = nil;
    startRecord = NO;

    AVAudioSession* session = [AVAudioSession sharedInstance];
    NSError* error;
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];

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
    [self startRecording];
}

- (void)startRecording
{
    NSLog(@"START RECORDING");
    //    [messageTextView becomeFirstResponder];
    
    if (transactionState == TS_RECORDING)
    {
        [voiceSearch stopRecording];
    }
    else if (transactionState == TS_IDLE)
    {
        NSString* recoType = SKSearchRecognizerType;
        NSString* langType = @"en_US";
        
        transactionState = TS_INITIAL;
        
        messageTextView.text = @"";
        
        if (voiceSearch == nil)
        {
            voiceSearch = [[SKRecognizer alloc] initWithType:recoType detection:SKLongEndOfSpeechDetection language:langType delegate:self];
        }
    }
}

-(void)beginAudioRecording
{
    [self.microphone startFetchingAudio];
    [hintContainerView removeFromSuperview];
    self.isRecording = YES;
    
    /*
     Create the recorder
     */
    self.recorder = [EZRecorder recorderWithDestinationURL:[Utilities soundFilePathUrl]
                                              sourceFormat:self.microphone.audioStreamBasicDescription
                                       destinationFileType:EZRecorderFileTypeM4A];
}

-(void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(beginAudioRecording) userInfo:nil repeats:NO];
}

-(void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    [self stopRecording];
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    NSLog(@"Got results.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    
    long numOfResults = [results.results count];
    
    transactionState = TS_IDLE;
    
    if (numOfResults > 0)
        messageTextView.text = [results firstResult];
    
    //    if (numOfResults > 1)
    //        alternativesDisplay.text = [[results.results subarrayWithRange:NSMakeRange(1, numOfResults-1)] componentsJoinedByString:@"\n"];
    //
    if (results.suggestion) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Suggestion"
                                                        message:results.suggestion
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
    voiceSearch = nil;
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    NSLog(@"Got error.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    
    transactionState = TS_IDLE;
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    if (suggestion) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Suggestion"
                                                        message:suggestion
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
    voiceSearch = nil;
}

- (void) stopRecording
{
    NSLog(@"STOP RECORDING");
    [voiceSearch stopRecording];
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
    transactionState = TS_IDLE;
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
    
    if ([messageTextView.text length] > 0)
    {
        spokeObj.spokeText = messageTextView.text;
        NSArray *words=[messageTextView.text componentsSeparatedByString:@" "];
        
        for (NSString *word in words)
        {
            NSLog(@"WORD %@", word);
            
            if ([word hasPrefix:@"#"])
            {
                NSString *tempString = [word substringFromIndex:1];
                [hashTagArray addObject:tempString];
            }
        }
    }
    [[UserProfile sharedProfile] saveHashTagToRemote:hashTagArray];
    [hashTagArray removeAllObjects];
    
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
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                       selector:@selector(startRecording)
                                       userInfo:nil
                                        repeats:NO];
        //        [self startRecording];
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
}

#pragma mark UITextViewDelegate
- (void) textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"DID BEGIN EDITING");
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"DID END EDITING");
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"--------------------------------------%@------------------------------------", text);
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    NSMutableAttributedString * mutableString = [[NSMutableAttributedString alloc]initWithString:messageTextView.text];
    
    //    NSArray *words=[messageTextView.text componentsSeparatedByString:@" "];
    //
    //    for (NSString *word in words)
    //    {
    //        NSLog(@"WORD %@", word);
    //        NSRange wordRange=[messageTextView.text rangeOfString:word];
    //        if ([word hasPrefix:@"#"])
    //        {
    //            [mutableString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:wordRange];
    //        }
    //        else
    //        {
    //            [mutableString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:wordRange];
    //        }
    //    }
    [messageTextView setAttributedText:mutableString];
    
    return YES;
}
//{
//    NSLog(@"SHOULD CHANGE");
//    CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
//    CGFloat overflow = line.origin.y + line.size.height - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top );
//    if ( overflow > 0)
//    {
//        CGPoint offset = textView.contentOffset;
//        offset.y += overflow + 7;
//        [UIView animateWithDuration:.2 animations:^{
//            [textView setContentOffset:offset];
//        }];
//    }
//
//    CGFloat fixedWidth = messageTextView.frame.size.width;
//    CGSize newSize = [messageTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
//    CGRect newFrame = messageTextView.frame;
//    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
//    if(newFrame.size.height > messageTextView.frame.size.height)
//    {
//        messageTextView.frame = newFrame;
//        [letImageContainerView setFrame:CGRectMake(letImageContainerView.frame.origin.x, messageTextView.frame.origin.y + messageTextView.frame.size.height, letImageContainerView.frame.size.width, letImageContainerView.frame.size.height)];
//        [messageContainerView setContentSize:CGSizeMake(messageContainerView.frame.size.width, messageContainerView.contentSize.height + 34)];
//    }
//
//    int charLeft = [charLeftLabel.text intValue];
//    if (![text isEqualToString:@""])
//        charLeft--;
//    else
//        charLeft++;
//
//    if(charLeft > 300)
//        charLeft = 300;
//    if (charLeft < 0 )
//        charLeft = 0;
//
//    [charLeftLabel setText:[NSString stringWithFormat:@"%d", charLeft]];
//
//    if([textView.text length] > MAX_STATUS_LENGTH && ![text isEqualToString:@""])
//        return NO;
//    return YES;
//}

//- (void) textViewDidChange:(UITextView *)textView
//{
//    //    NSLog(@"TEXT DID CHANGE %@", textView.text);
//    //    int charLeft = [charLeftLabel.text intValue];
//    //    if (![textView.text isEqualToString:@""])
//    //        charLeft--;
//    //    else
//    //        charLeft++;
//    //
//    //    if(charLeft > 300)
//    //        charLeft = 300;
//    //    if (charLeft < 0 )
//    //        charLeft = 0;
//    //
//    //    [charLeftLabel setText:[NSString stringWithFormat:@"%d", charLeft]];
//    //
//    if ([textView.text length] != 0)
//    {
//        letButton.enabled = YES;
//        letItFlyTextViewPlaceholder.hidden = YES;
//    }
//    else
//    {
//        letButton.enabled = NO;
//        letItFlyTextViewPlaceholder.hidden = NO;
//    }
//}

@end
