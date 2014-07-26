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
@synthesize spokeImageView;
@synthesize spokeNameLabel;
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

- (IBAction)playButtonPressed:(id)sender
{
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
        [profileVC.userProf updateTotalSpokeHeard:currentSpoke.spokeID heardID:[profileVC.userProf getUserID]];
    else if(wallVC != nil)
        [wallVC.userProf updateTotalSpokeHeard:currentSpoke.spokeID heardID:[wallVC.userProf getUserID]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHeardLabel) name:@"updateHeards" object:nil];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"AUDIO PLAYER DID FINISH");
    [[NSNotificationCenter defaultCenter]postNotificationName:PLAYBACK_STOP object:nil];
}

-(void)updateHeardLabel
{
    NSLog(@"UPDATE HEARD LABEL");
    int totalHeard = currentSpoke.totalHeards + 1;
    heardLabel.text = [NSString stringWithFormat:@"%d heard", totalHeard];
}


- (IBAction)gotoRespokeButtonPressed:(id)sender {
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
        }
        else
        {
            [profileVC.player play];
            [pausePlayButton setSelected:NO];
        }
    }
    else if(wallVC != nil)
    {
        if(wallVC.player.playing)
        {
            [wallVC.player pause];
            wallVC.playerInPause = YES;
            [pausePlayButton setSelected:YES];
        }
        else
        {
            [wallVC.player play];
            wallVC.playerInPause = NO;
            [pausePlayButton setSelected:NO];
        }
    }
}

@end
