//
//  SpokeCell.m
//  Parrot
//
//  Created by Marco Argiolas on 19/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "SpokeCell.h"
#import "GlobalDefines.h"

@implementation SpokeCell

@synthesize playButton;
@synthesize profileVC;
@synthesize spokeContainerView;
@synthesize spokeDateLabel;
@synthesize heardLabel;
@synthesize respokeTotalLabel;
@synthesize likesLabel;
@synthesize gotoRespokeButton;
@synthesize totalTimeLabel;
@synthesize currentTimeLabel;
@synthesize spokeSlider;
@synthesize playContainerView;
@synthesize updateTimer;
@synthesize pausePlayButton;
@synthesize likeButton;
@synthesize currentSpoke;
@synthesize wallVC;
@synthesize spokePlayer;
@synthesize currentSpokeIndex;
@synthesize spokeImageButton;
@synthesize spokeNameButton;
@synthesize respokenVC;

- (IBAction)playButtonPressed:(id)sender
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"spokeChanged" object:nil];
    NSLog(@"PLAY BUTTON PRESSED");
    if(profileVC != nil)
    {
        if(profileVC.currentPlayingTag != playButton.tag)
        {
            profileVC.currentPlayingTag = (int)playButton.tag;
        }
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(spokeChanged) name:@"spokeChanged" object:nil];
        if(![profileVC.player isPlaying])
        {
            NSData *soundData = [[NSData alloc] initWithData:currentSpoke.audioData];
            NSError *error;
            AVAudioPlayer *newPlayer =[[AVAudioPlayer alloc] initWithData: soundData error: &error];
            newPlayer.delegate = self;
            
            profileVC.player = newPlayer;
            updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
            
            spokeSlider.minimumValue = 0;
            spokeSlider.maximumValue = profileVC.player.duration;
            
            [profileVC playSelectedAudio];
            
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changePlayButtonImage) name:PLAYBACK_STOP object:nil];
            [playButton removeFromSuperview];
            
            [playContainerView addSubview:spokeSlider];
            [playContainerView addSubview:currentTimeLabel];
            [playContainerView addSubview:pausePlayButton];
        }
    }
    else if(wallVC != nil)
    {
        if(wallVC.currentPlayingTag != playButton.tag)
        {
            wallVC.currentPlayingTag = (int)playButton.tag;
        }
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(spokeChanged) name:@"spokeChanged" object:nil];
        if(![wallVC.player isPlaying])
        {
            NSData *soundData = [[NSData alloc] initWithData:currentSpoke.audioData];
            NSError *error;
            AVAudioPlayer *newPlayer =[[AVAudioPlayer alloc] initWithData: soundData error: &error];
            newPlayer.delegate = self;

            wallVC.player = newPlayer;
            
            updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
            
            spokeSlider.minimumValue = 0;
            spokeSlider.maximumValue = wallVC.player.duration;
            
            [wallVC playSelectedAudio];
            
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changePlayButtonImage) name:PLAYBACK_STOP object:nil];
            [playButton removeFromSuperview];
            
            [playContainerView addSubview:spokeSlider];
            [playContainerView addSubview:currentTimeLabel];
            [playContainerView addSubview:pausePlayButton];
        }
    }
    else if(respokenVC != nil)
    {
        if(respokenVC.currentPlayingTag != playButton.tag)
        {
            respokenVC.currentPlayingTag = (int)playButton.tag;
        }
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(spokeChanged) name:@"spokeChanged" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopRespokenPlayer) name:RESPOKEN_HEADER_PLAY object:nil];

        [[NSNotificationCenter defaultCenter] postNotificationName:CELL_PLAY_STARTED object:nil];
        
        if(![respokenVC.player isPlaying] || respokenVC.currentPlayingTag != -1)
        {
            NSError *dataError;
            NSData *soundData = [[NSData alloc] initWithData:currentSpoke.audioData];
            if(dataError != nil)
            {
                NSLog(@"DATA ERROR %@", dataError);
            }
            
            NSError *error;
            AVAudioPlayer *newPlayer =[[AVAudioPlayer alloc] initWithData: soundData error: &error];
            newPlayer.delegate = self;

            respokenVC.player = newPlayer;
            updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
            
            spokeSlider.minimumValue = 0;
            spokeSlider.maximumValue = respokenVC.player.duration;
            
            [respokenVC playSelectedAudio];
            
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changePlayButtonImage) name:PLAYBACK_STOP object:nil];
            [playButton removeFromSuperview];
            
            [playContainerView addSubview:spokeSlider];
            [playContainerView addSubview:currentTimeLabel];
            [playContainerView addSubview:pausePlayButton];
        }
    }
}

-(void)stopRespokenPlayer
{
    if (respokenVC != nil)
    {
        [respokenVC stopRespokenPlayer];
    }
}

-(void)spokeChanged
{
    NSLog(@"SPOKE CHANGED");
    [self changePlayButtonImage];
    if(profileVC != nil)
    {
        [profileVC.player stop];
        profileVC.player.currentTime = 0;
        profileVC.player = nil;
    }
    else if(wallVC != nil)
    {
        [wallVC.player stop];
        wallVC.player.currentTime = 0;
        wallVC.player = nil;
    }
    else if(respokenVC != nil)
    {
        [respokenVC.player stop];
        respokenVC.player.currentTime = 0;
        respokenVC.player = nil;
    }

    [pausePlayButton setSelected:NO];
}

-(void)changePlayButtonImage
{
    NSLog(@"SPOKE CELL ----------------------------------------- CHANGE PLAY BUTTON IMAGE");
    [updateTimer invalidate];
    [spokeSlider removeFromSuperview];
    [currentTimeLabel removeFromSuperview];
    [pausePlayButton removeFromSuperview];
    [playContainerView addSubview:playButton];
    [playButton setImage:[UIImage imageNamed:@"button_big_replay_enabled.png"] forState:UIControlStateNormal];
    if(profileVC != nil)
    {
        if(![currentSpoke.listOfHeardsID containsObject:[[UserProfile sharedProfile] getUserID]])
        {
            [profileVC.currentSpokenArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
            if ([[UserProfile sharedProfile].cacheSpokesArray count] < currentSpokeIndex)
            {
                [[UserProfile sharedProfile].cacheSpokesArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
            }
            
            [currentSpoke.listOfHeardsID addObject:[[UserProfile sharedProfile] getUserID]];
        }

        [[UserProfile sharedProfile] updateTotalSpokeHeard:currentSpoke.spokeID heardID:[[UserProfile sharedProfile] getUserID]];
        [profileVC sensorStateChange:nil];
    }
    else if(wallVC != nil)
    {
        if(![currentSpoke.listOfHeardsID containsObject:[[UserProfile sharedProfile] getUserID]])
        {
            if ([[UserProfile sharedProfile].cacheSpokesArray count] < currentSpokeIndex)
            {
                [[UserProfile sharedProfile].cacheSpokesArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
            }
            
            [currentSpoke.listOfHeardsID addObject:[[UserProfile sharedProfile] getUserID]];
        }
        

        [[UserProfile sharedProfile] updateTotalSpokeHeard:currentSpoke.spokeID heardID:[[UserProfile sharedProfile] getUserID]];
        
        [wallVC sensorStateChange:nil];
//        int i = currentSpokeIndex;
//        while (i > 0)
//        {
//            NSLog(@"SPOKE CELL I: %d", i);
//            i = i-1;
//            Spoke *tempSpoke = [wallVC.wallSpokesArray objectAtIndex:i];
//
//            if ([tempSpoke.listOfHeardsID containsObject:[[UserProfile sharedProfile] getUserID]])
//            {
//                NSLog(@"GIA SENTITO MAREMMA MERDA");
//            }
//            else
//            {
//                NSLog(@"SENTIAMO IL PROSSIMO MAREMMA CAZZO");
//                currentSpoke = tempSpoke;
//                wallVC.currentPlayingTag = i;
//                //Remember to check boundaries before just setting an indexpath or your app will crash!
//                NSIndexPath *currentSelection = [NSIndexPath indexPathForRow:currentSpokeIndex - 1  inSection:0];
//                
//                [wallVC.wallTableView selectRowAtIndexPath:currentSelection animated:YES scrollPosition: UITableViewScrollPositionTop];
//                currentSpoke = [wallVC.wallSpokesArray objectAtIndex:i];
//                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(spokeChanged) name:@"spokeChanged" object:nil];
//                if(![wallVC.player isPlaying])
//                {
//                    NSData *soundData = [[NSData alloc] initWithData:currentSpoke.audioData];
//                    NSError *error;
//                    AVAudioPlayer *newPlayer =[[AVAudioPlayer alloc] initWithData: soundData error: &error];
//                    newPlayer.delegate = self;
//                    
//                    wallVC.player = newPlayer;
//                    
//                    updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
//                    
//                    spokeSlider.minimumValue = 0;
//                    spokeSlider.maximumValue = wallVC.player.duration;
//                    
//                    [wallVC playSelectedAudio];
//                    
//                    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changePlayButtonImage) name:PLAYBACK_STOP object:nil];
//                    [playButton removeFromSuperview];
//                    
//                    [playContainerView addSubview:spokeSlider];
//                    [playContainerView addSubview:currentTimeLabel];
//                    [playContainerView addSubview:pausePlayButton];
//                }
//
////                [self playButtonPressed:nil];
//                break;
//            }
//        }
    }
    else if(respokenVC != nil)
    {
        if(![currentSpoke.listOfHeardsID containsObject:[respokenVC.userProf getUserID]])
        {
            if ([respokenVC.userProf.cacheSpokesArray count] < currentSpokeIndex)
            {
                [respokenVC.userProf.cacheSpokesArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
            }
            
            [respokenVC.wallSpokesArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
            [currentSpoke.listOfHeardsID addObject:[respokenVC.userProf getUserID]];
        }
        
        [respokenVC sensorStateChange:nil];
        [respokenVC.userProf updateTotalSpokeHeard:currentSpoke.spokeID heardID:[respokenVC.userProf getUserID]];
    }
    int totalHeard = (int)[currentSpoke.listOfHeardsID count];
    currentSpoke.totalHeards = totalHeard;
    heardLabel.text = [NSString stringWithFormat:@"%d heard", totalHeard];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"SPOKE CELL ------------------------------ AUDIO PLAYER DID FINISH");
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter]postNotificationName:PLAYBACK_STOP object:nil];
    
}

-(void)updateHeardLabel
{
    NSLog(@"UPDATE HEARD LABEL");
    int totalHeard = currentSpoke.totalHeards + 1;
    heardLabel.text = [NSString stringWithFormat:@"%d heard", totalHeard];
}


- (IBAction)gotoRespokeButtonPressed:(id)sender
{
    if(profileVC != nil)
    {
        [profileVC openRespokenView:currentSpoke];
    }
    if(wallVC != nil)
    {
        [wallVC openRespokenView:currentSpoke];
    }
    if(respokenVC != nil)
    {
        NSLog(@"APRO I SETTINGS PER I CONTENUTI");
    }
}

- (IBAction)likeButtonPressed:(id)sender
{
    NSLog(@"LIKE BUTTON PRESSED");
    
//    int totalLikes = currentSpoke.totalLikes;
//    if(!likeButton.selected)
//    {
//        totalLikes = totalLikes + 1;
//    }
//    else
//    {
//        totalLikes = totalLikes - 1;
//    }
//    currentSpoke.totalLikes = totalLikes;

    if(currentSpoke.listOfThankersID == nil)
    {
        currentSpoke.listOfThankersID = [[NSMutableArray alloc]init];
    }
    
    if(profileVC != nil)
    {
        if(!likeButton.selected)
        {
            if(![currentSpoke.listOfThankersID containsObject:[[UserProfile sharedProfile] getUserID]])
                [currentSpoke.listOfThankersID addObject:[[UserProfile sharedProfile] getUserID]];
        }
        else
        {
            if([currentSpoke.listOfThankersID containsObject:[[UserProfile sharedProfile] getUserID]])
                [currentSpoke.listOfThankersID removeObject:[[UserProfile sharedProfile] getUserID]];
        }

        [profileVC.currentSpokenArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
    }
    else if (wallVC != nil)
    {
        if(!likeButton.selected)
        {
            if(![currentSpoke.listOfThankersID containsObject:[[UserProfile sharedProfile] getUserID]])
                [currentSpoke.listOfThankersID addObject:[[UserProfile sharedProfile] getUserID]];
        }
        else
        {
            if([currentSpoke.listOfThankersID containsObject:[[UserProfile sharedProfile] getUserID]])
                [currentSpoke.listOfThankersID removeObject:[[UserProfile sharedProfile] getUserID]];
        }
    }
    else if (respokenVC != nil)
    {
        if(!likeButton.selected)
        {
            if(![currentSpoke.listOfThankersID containsObject:[respokenVC.userProf getUserID]])
                [currentSpoke.listOfThankersID addObject:[respokenVC.userProf getUserID]];
        }
        else
        {
            if([currentSpoke.listOfThankersID containsObject:[respokenVC.userProf getUserID]])
                [currentSpoke.listOfThankersID removeObject:[respokenVC.userProf getUserID]];
        }
        
        [respokenVC.respokenArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
    }
    
    [[UserProfile sharedProfile].cacheSpokesArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
    [[UserProfile sharedProfile].spokesArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
    [[UserProfile sharedProfile] updateTotalSpokeLike:currentSpoke.spokeID thanksID:[[UserProfile sharedProfile] getUserID]addLike:!likeButton.selected totalLikes:(int)[currentSpoke.listOfThankersID count]];

    currentSpoke.totalLikes = (int)[currentSpoke.listOfThankersID count];
    likeButton.selected = !likeButton.selected;
    
    if([currentSpoke.listOfThankersID count] <= 1)
        likesLabel.text = [NSString stringWithFormat:@"%d like", (int)[currentSpoke.listOfThankersID count]];
    else
        likesLabel.text = [NSString stringWithFormat:@"%d likes", (int)[currentSpoke.listOfThankersID count]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLikes:) name:@"updateLikes" object:nil];
}

-(void)updateLikes:(NSNotification*)notification
{
//    NSLog(@"UPDATE LIKES");
//    NSDictionary* userInfo = notification.userInfo;
//    BOOL like = [[userInfo objectForKey:@"like"] boolValue];
//
//    [likeButton setSelected:like];
//    int totalLikes = [[userInfo objectForKey:@"totalLikes"] intValue];
//    
////    if(totalLikes <= 1)
////        likesLabel.text = [NSString stringWithFormat:@"%d like", totalLikes];
////    else
////        likesLabel.text = [NSString stringWithFormat:@"%d likes", totalLikes];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"updateLikes" object:nil];
}

- (IBAction)shareButtonPressed:(id)sender {
}

- (IBAction)progressSliderMoved:(UISlider*)sender
{
    NSLog(@"PROGRESS SLIDER MOVED");
    if(profileVC != nil)
    {
        [profileVC.player pause];
        [pausePlayButton setSelected:YES];
        profileVC.player.currentTime = spokeSlider.value;
        profileVC.player.currentTime = sender.value;
        currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)profileVC.player.currentTime / 60, (int)profileVC.player.currentTime % 60, nil];
        spokeSlider.value = profileVC.player.currentTime;
    }
    else if(wallVC != nil)
    {
        [wallVC.player pause];
        [pausePlayButton setSelected:YES];
        wallVC.player.currentTime = spokeSlider.value;
        wallVC.player.currentTime = sender.value;
        currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)wallVC.player.currentTime / 60, (int)wallVC.player.currentTime % 60, nil];
        spokeSlider.value = wallVC.player.currentTime;
    }
    else if(respokenVC != nil)
    {
        [respokenVC.player pause];
        [pausePlayButton setSelected:YES];
        respokenVC.player.currentTime = spokeSlider.value;
        respokenVC.player.currentTime = sender.value;
        currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)respokenVC.player.currentTime / 60, (int)respokenVC.player.currentTime % 60, nil];
        spokeSlider.value = respokenVC.player.currentTime;
    }
}

- (void)updateSlider
{
    if(spokeSlider.tag == playButton.tag)
    {
        if(profileVC != nil)
        {
            float progress = profileVC.player.currentTime;
            currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)profileVC.player.currentTime / 60, (int)profileVC.player.currentTime % 60, nil];
            [spokeSlider setValue:progress];
        }
        else if(wallVC != nil)
        {
            float progress = wallVC.player.currentTime;
            currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)wallVC.player.currentTime / 60, (int)wallVC.player.currentTime % 60, nil];
            [spokeSlider setValue:progress];
        }
        else if(respokenVC != nil)
        {
            float progress = respokenVC.player.currentTime;
            currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)respokenVC.player.currentTime / 60, (int)respokenVC.player.currentTime % 60, nil];
            [spokeSlider setValue:progress];
        }
    }
}

- (IBAction)pausePlayButtonPressed:(id)sender
{
    NSLog(@"PAUSE PLAY BUTTON PRESSED");
    if(profileVC != nil)
    {
        if(profileVC.player.playing)
        {
            [profileVC.player pause];
            [pausePlayButton setSelected:YES];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
        else
        {
            [profileVC.player play];
            [pausePlayButton setSelected:NO];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        }
    }
    else if(wallVC != nil)
    {
        if(wallVC.player.playing)
        {
            [wallVC.player pause];
            wallVC.playerInPause = YES;
            [pausePlayButton setSelected:YES];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
        else
        {
            [wallVC.player play];
            wallVC.playerInPause = NO;
            [pausePlayButton setSelected:NO];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        }
    }
    else if(respokenVC != nil)
    {
        if(respokenVC.player.playing)
        {
            [respokenVC.player pause];
            respokenVC.playerInPause = YES;
            [pausePlayButton setSelected:YES];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
        else
        {
            [respokenVC.player play];
            respokenVC.playerInPause = NO;
            [pausePlayButton setSelected:NO];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        }
    }
}

- (IBAction)spokeImageButtonPressed:(id)sender
{
    if(wallVC != nil)
    {
        [wallVC openUserProfile:currentSpoke];
    }
    else if(respokenVC != nil)
    {
        [respokenVC openUserProfile:currentSpoke];
    }
}

- (IBAction)spokeNameButtonPressed:(id)sender
{
    if(wallVC != nil)
    {
        [wallVC openUserProfile:currentSpoke];
    }
    else if(respokenVC != nil)
    {
        [respokenVC openUserProfile:currentSpoke];
    }
}

@end
