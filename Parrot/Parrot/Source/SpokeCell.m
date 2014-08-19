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
            wallVC.player = spokePlayer;
            updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
            
            spokeSlider.minimumValue = 0;
            spokeSlider.maximumValue = wallVC.player.duration;
            
            [wallVC.player play];
            
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
        if(![respokenVC.player isPlaying])
        {
            respokenVC.player = spokePlayer;
            updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
            
            spokeSlider.minimumValue = 0;
            spokeSlider.maximumValue = respokenVC.player.duration;
            
            [respokenVC.player play];
            
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changePlayButtonImage) name:PLAYBACK_STOP object:nil];
            [playButton removeFromSuperview];
            
            [playContainerView addSubview:spokeSlider];
            [playContainerView addSubview:currentTimeLabel];
            [playContainerView addSubview:pausePlayButton];
        }
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
    NSLog(@"CHANGE PLAY BUTTON IMAGE");
    [updateTimer invalidate];
    [spokeSlider removeFromSuperview];
    [currentTimeLabel removeFromSuperview];
    [pausePlayButton removeFromSuperview];
    [playContainerView addSubview:playButton];
    [playButton setImage:[UIImage imageNamed:@"button_big_replay_enabled.png"] forState:UIControlStateNormal];
    if(profileVC != nil)
    {
        if(![currentSpoke.listOfHeardsID containsObject:[profileVC.userProf getUserID]])
        {
            [profileVC.currentSpokenArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
            [currentSpoke.listOfHeardsID addObject:[profileVC.userProf getUserID]];
        }

        [profileVC.userProf updateTotalSpokeHeard:currentSpoke.spokeID heardID:[profileVC.userProf getUserID]];
    }
    else if(wallVC != nil)
    {
        if(![currentSpoke.listOfHeardsID containsObject:[wallVC.userProf getUserID]])
        {
            [wallVC.wallSpokesArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
            [currentSpoke.listOfHeardsID addObject:[wallVC.userProf getUserID]];
        }
        

        [wallVC.userProf updateTotalSpokeHeard:currentSpoke.spokeID heardID:[wallVC.userProf getUserID]];
    }
    else if(respokenVC != nil)
    {
        if(![currentSpoke.listOfHeardsID containsObject:[respokenVC.userProf getUserID]])
        {
            [respokenVC.wallSpokesArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
            [currentSpoke.listOfHeardsID addObject:[respokenVC.userProf getUserID]];
        }
        
        
        [respokenVC.userProf updateTotalSpokeHeard:currentSpoke.spokeID heardID:[respokenVC.userProf getUserID]];
    }
    int totalHeard = [currentSpoke.listOfHeardsID count];
    currentSpoke.totalHeards = totalHeard;
    heardLabel.text = [NSString stringWithFormat:@"%d heard", totalHeard];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"AUDIO PLAYER DID FINISH");
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
            if(![currentSpoke.listOfThankersID containsObject:[profileVC.userProf getUserID]])
                [currentSpoke.listOfThankersID addObject:[profileVC.userProf getUserID]];
        }
        else
        {
            if([currentSpoke.listOfThankersID containsObject:[profileVC.userProf getUserID]])
                [currentSpoke.listOfThankersID removeObject:[profileVC.userProf getUserID]];
        }

        [profileVC.currentSpokenArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
        [profileVC.userProf updateTotalSpokeLike:currentSpoke.spokeID thanksID:[profileVC.userProf getUserID]addLike:!likeButton.selected totalLikes:[currentSpoke.listOfThankersID count]];
    }
    else if (wallVC != nil)
    {
        if(!likeButton.selected)
        {
            if(![currentSpoke.listOfThankersID containsObject:[wallVC.userProf getUserID]])
                [currentSpoke.listOfThankersID addObject:[wallVC.userProf getUserID]];
        }
        else
        {
            if([currentSpoke.listOfThankersID containsObject:[wallVC.userProf getUserID]])
                [currentSpoke.listOfThankersID removeObject:[wallVC.userProf getUserID]];
        }

        currentSpoke.totalLikes = [currentSpoke.listOfThankersID count];
        [wallVC.wallSpokesArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
        [wallVC.userProf updateTotalSpokeLike:currentSpoke.spokeID thanksID:[wallVC.userProf getUserID]addLike:!likeButton.selected totalLikes:[currentSpoke.listOfThankersID count]];
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
        
        currentSpoke.totalLikes = [currentSpoke.listOfThankersID count];
        [respokenVC.respokenArray replaceObjectAtIndex:currentSpokeIndex withObject:currentSpoke];
        [respokenVC.userProf updateTotalSpokeLike:currentSpoke.spokeID thanksID:[respokenVC.userProf getUserID]addLike:!likeButton.selected totalLikes:[currentSpoke.listOfThankersID count]];
    }
    likeButton.selected = !likeButton.selected;
    
    if([currentSpoke.listOfThankersID count] <= 1)
        likesLabel.text = [NSString stringWithFormat:@"%d like", [currentSpoke.listOfThankersID count]];
    else
        likesLabel.text = [NSString stringWithFormat:@"%d likes", [currentSpoke.listOfThankersID count]];
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
