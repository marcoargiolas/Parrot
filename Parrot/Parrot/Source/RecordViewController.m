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
#import "PlacesViewController.h"

@implementation EditCell

@synthesize hashtagTextLabel;
@synthesize countLabel;

@end

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:@"UIKeyboardDidHideNotification" object:nil];
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
    
    [self.mapView removeFromSuperview];
    [self.editContainerView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.editContainerView.frame.size.width, self.editContainerView.frame.size.height)];
    [self.editTableView removeFromSuperview];
    
    lookForHashIndex = -1;
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UserProfile sharedProfile] loadHashtagsFromRemote];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(populateHashtagArray:) name:HASHTAG_ARRAY_ARRIVED object:nil];
    
    NSString *spokePlace = [[[NSUserDefaults standardUserDefaults]objectForKey:PLACE_CHOOSE] objectForKey:@"name"];
    if ([spokePlace length] > 0)
    {
        [self.spokeAddressLabel setText:spokePlace];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:PLACE_CHOOSE];
    }
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
   [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        
//        messageTextView.text = @"";
        
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
        spokeObj.spokePositionImageData = spokePositionImageData;
        spokeObj.spokeAddress = spokeAddress;
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
    
    [location.locManager setDistanceFilter:kCLDistanceFilterNone];
    [location.locManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    
    self.mapView.delegate = self;
    [self.mapView setShowsUserLocation:YES];
    
    [self.mapView setCenterCoordinate:location.locManager.location.coordinate];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location.locManager.location completionHandler:^(NSArray *placemarks, NSError *error){

        if (error == nil && [placemarks count] > 0)
        {
            MKPlacemark *placemark = [placemarks lastObject];
            NSString *strAdd = nil;

            if ([placemark.thoroughfare length] != 0)
            {
                // strAdd -> store value of current location
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark thoroughfare]];
                else
                {
                    // strAdd -> store only this value,which is not null
                    strAdd = placemark.thoroughfare;
                }
            }
            
//            if ([placemark.postalCode length] != 0)
//            {
//                if ([strAdd length] != 0)
//                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark postalCode]];
//                else
//                    strAdd = placemark.postalCode;
//            }
            
            if ([placemark.locality length] != 0)
            {
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark locality]];
                else
                    strAdd = placemark.locality;
            }

//            if ([placemark.administrativeArea length] != 0)
//            {
//                if ([strAdd length] != 0)
//                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark administrativeArea]];
//                else
//                    strAdd = placemark.administrativeArea;
//            }
            
            if ([placemark.country length] != 0)
            {
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark country]];
                else
                    strAdd = placemark.country;
            }
            spokeAddress = strAdd;
//            [self.spokeAddressLabel setText:spokeAddress];
        }
    }];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.locManager.location.coordinate, 200, 200);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    self.mapView.showsUserLocation = YES;
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:location.locManager.location.coordinate];
    [annotation setTitle:@"Title"]; //You can set the subtitle too
    [self.mapView addAnnotation:annotation];
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = self.mapView.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = positionButton.frame.size;
    
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
        
        UIImage *image = snapshot.image;
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        {
            [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
            
            CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
            for (id <MKAnnotation> annotation in self.mapView.annotations) {
                CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
                if (CGRectContainsPoint(rect, point)) {
                    point.x = point.x + pin.centerOffset.x -
                    (pin.bounds.size.width / 2.0f);
                    point.y = point.y + pin.centerOffset.y -
                    (pin.bounds.size.height / 2.0f);
                    [pin.image drawAtPoint:point];
                }
            }
            
            UIImage *compositeImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            if(image != nil)
            {
                spokePositionImageData = UIImagePNGRepresentation(compositeImage);
            }
            [positionButton setBackgroundImage:compositeImage forState:UIControlStateNormal];
            [positionButton setTitle:@"" forState:UIControlStateNormal];
        }
    }];
    
    [self queryGooglePlaces:@"puppa"];
}

#pragma mark - MKMapViewDelegate methods.
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views {
    MKCoordinateRegion region;
    region = MKCoordinateRegionMakeWithDistance(location.locManager.location.coordinate,1000,1000);
    
    
    [mv setRegion:region animated:YES];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //Get the east and west points on the map so you can calculate the distance (zoom level) of the current map view.
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    //Set your current distance instance variable.
    currenDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    
    //Set your current center point on the map instance variable.
    currentCentre = self.mapView.centerCoordinate;
}

-(void) queryGooglePlaces: (NSString *) googleType
{
    // Build the url string to send to Google. NOTE: The kGOOGLE_API_KEY is a constant that should contain your own API key that you obtain from Google. See this link for more info:
    // https://developers.google.com/maps/documentation/places/#Authentication
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&sensor=true&key=%@", location.locManager.location.coordinate.latitude, location.locManager.location.coordinate.longitude, kGOOGLE_API_KEY];
    
    url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", location.locManager.location.coordinate.latitude, location.locManager.location.coordinate.longitude, [NSString stringWithFormat:@"%i", currenDist], @"", kGOOGLE_API_KEY];
    //Formulate the string as a URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

-(void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    if (places == nil)
    {
        places = [[NSMutableArray alloc]init];
    }
    places = [json objectForKey:@"results"];
    
    [[NSUserDefaults standardUserDefaults] setObject:places forKey:CURRENT_PLACES_SET];
    
    [self performSegueWithIdentifier:@"placesAction" sender:self];
}

- (IBAction)editViewDoneButtonPressed:(id)sender
{
    [messageTextView resignFirstResponder];
}


- (IBAction)editViewCancelButtonPressed:(id)sender
{
    [messageTextView resignFirstResponder];
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
    NSLog(@"MESSAGE VIEW TEXT %@", messageTextView.text);
    if ([text isEqualToString:@"#"])
    {
        lookForHashIndex = (int)range.location;
    }

    if (lookForHashIndex != -1)
    {
        if (currentHashtagArray == nil)
        {
            currentHashtagArray = [[NSMutableArray alloc]init];
        }
        NSString *textToCheck = [messageTextView.text substringWithRange:NSMakeRange(lookForHashIndex, [messageTextView.text length])];
        NSLog(@"TEXT TO CHECK %@", textToCheck);
        if ([textToCheck length] > 2)
        {
            NSLog(@"TUA MADRE PUTTANA");
            textToCheck = [textToCheck substringFromIndex:1];
            for (int i = 0; i < [availableHashTagArray count]; i++)
            {
                NSString *tempString = [availableHashTagArray objectAtIndex:i];
                NSString *subTempString = [tempString substringToIndex:3];
                NSLog(@"TEMP STRING DEL CAZZO FANCULO %@", subTempString);
                if ([subTempString isEqualToString:textToCheck])
                {
                    NSLog(@"E CHE CAZZO");
                    [currentHashtagArray addObject:tempString];
                }
            }
            if ([currentHashtagArray count] > 0)
            {
                [self.editContainerView addSubview:self.editTableView];
                [self.editTableView reloadData];
            }
        }
    }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [currentHashtagArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"editCellID";
    
    EditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else
    {
        cell.textLabel.text = @"";
        cell.countLabel.text = @"";
    }
    
    cell.hashtagTextLabel.text = [NSString stringWithFormat:@"#%@",[currentHashtagArray objectAtIndex:indexPath.row]];
    cell.countLabel.text = [NSString stringWithFormat:@"%d friends", (int)indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *message = messageTextView.text;
    message = [message substringToIndex:lookForHashIndex];
    NSLog(@"MESSAGE %@", message);
    message = [message stringByAppendingString:[NSString stringWithFormat:@"#%@", [currentHashtagArray objectAtIndex:indexPath.row]]];
    messageTextView.text = message;
    lookForHashIndex = -1;
    [currentHashtagArray removeAllObjects];
    [self.editTableView reloadData];
}

#pragma mark keyboard management

- (void) keyboardWillShow:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSLog(@"Keyboard Height: %f Width: %f", kbSize.height, kbSize.width);
    [self.editTableView reloadData];
    [UIView animateWithDuration:0.3 animations:^{
        [self.editContainerView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - kbSize.height)];
        [self.editHeaderView setFrame:CGRectMake(0, 0, 320, 65)];
        [messageTextView setFrame:CGRectMake(messageTextView.frame.origin.x, self.editHeaderView.frame.size.height, messageTextView.frame.size.width, 60)];
        [self.editTableView setFrame:CGRectMake(self.editTableView.frame.origin.x, messageTextView.frame.origin.y + messageTextView.frame.size.height + 8, self.editTableView.frame.size.width, [UIScreen mainScreen].bounds.size.height - self.editHeaderView.frame.size.height - 8 - messageTextView.frame.size.height - kbSize.height)];
        [self.view addSubview:self.editContainerView];
    }completion:^(BOOL finished)
     {
         [self.editContainerView addSubview:messageTextView];
     }];
}

- (void) keyboardDidHide:(NSNotification *)note
{
    // move the view back to the origin
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.editContainerView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.editContainerView.frame.size.width, self.editContainerView.frame.size.height)];
        [messageTextView setFrame:CGRectMake(messageTextView.frame.origin.x, self.spokeAddressLabel.frame.origin.y + self.spokeAddressLabel.frame.size.height + 8, messageTextView.frame.size.width, 128)];
        [self.view addSubview:messageTextView];
    }completion:^(BOOL finished)
     {
         [self.editContainerView removeFromSuperview];
     }];
}

-(void)populateHashtagArray:(NSNotification*)notification
{
    if (availableHashTagArray == nil)
    {
        availableHashTagArray = [[NSMutableArray alloc]init];
    }
    availableHashTagArray = (NSMutableArray*)[[notification userInfo]objectForKey:HASHTAG_ARRAY];
}

@end
