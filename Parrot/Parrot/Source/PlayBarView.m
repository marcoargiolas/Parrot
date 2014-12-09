//
//  PlayBarView.m
//  Parrot
//
//  Created by Marco Argiolas on 08/12/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "PlayBarView.h"
#import "GlobalDefines.h"

@implementation PlayBarView
@synthesize playButton;
@synthesize playSlider;
@synthesize nameLabel;
@synthesize timeLabel;
@synthesize updateTimer;
@synthesize respokenVC;
@synthesize profileVC;
@synthesize wallVC;
@synthesize currentPlayingSpokeCell;
@synthesize mainVC;

- (IBAction)leftButtonPressed:(id)sender
{
    int currentIndex = (int)currentPlayingSpokeCell.playButton.tag;
    if (currentPlayingSpokeCell == nil)
    {
        currentIndex = -1;
    }
    if(profileVC != nil)
    {
        if (currentIndex > 0)
        {
            Spoke *nextSpoke = [[UserProfile sharedProfile].spokesArray objectAtIndex:currentIndex - 1];
            currentPlayingSpokeCell = [profileVC changeCell:nextSpoke andIndex:currentIndex - 1];
        }
    }
    else if(wallVC != nil)
    {
        if (currentIndex > 0)
        {
            Spoke *nextSpoke = [[UserProfile sharedProfile].cacheSpokesArray objectAtIndex:currentIndex - 1];
            currentPlayingSpokeCell = [wallVC changeCell:nextSpoke andIndex:currentIndex - 1];
        }
    }
    else if(respokenVC != nil)
    {
        if (currentIndex > 0)
        {
            Spoke *nextSpoke = [respokenVC.respokenArray objectAtIndex:currentIndex - 1];
            currentPlayingSpokeCell = [respokenVC changeCell:nextSpoke andIndex:currentIndex - 1];
        }
        else if(currentIndex == 0)
        {
//            int rowNumber = (int)[respokenVC.respokenTableView numberOfRowsInSection:0];
//            NSLog(@"RIGHE %d", rowNumber);
//            for (int i = 0; i < rowNumber; i++)
//            {
//                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                SpokeCell *cell = (SpokeCell*)[respokenVC tableView:respokenVC.respokenTableView cellForRowAtIndexPath:indexPath];
//                [cell invalidateHidePlayBarViewSelector];
//            }
//            
            currentPlayingSpokeCell = [respokenVC changeCell:nil andIndex:-1];
        }
        else if(currentIndex == -1)
        {
//            [respokenVC.respokenHeader removeHidePlayBarSelector];
        }
    }
}

- (IBAction)rightButtonPressed:(id)sender
{
    int currentIndex;
    if (currentPlayingSpokeCell == nil)
    {
        currentIndex = -1;
    }
    else
    {
        currentIndex = (int)currentPlayingSpokeCell.playButton.tag;
    }
    
    if(profileVC != nil)
    {
        if (currentIndex < [[UserProfile sharedProfile].spokesArray count])
        {
            Spoke *nextSpoke = [[UserProfile sharedProfile].spokesArray objectAtIndex:currentIndex+1];
            currentPlayingSpokeCell = [profileVC changeCell:nextSpoke andIndex:currentIndex+1];
        }
    }
    else if(wallVC != nil)
    {
        if (currentIndex < [[UserProfile sharedProfile].cacheSpokesArray count])
        {
            Spoke *nextSpoke = [[UserProfile sharedProfile].cacheSpokesArray objectAtIndex:currentIndex+1];
            currentPlayingSpokeCell = [wallVC changeCell:nextSpoke andIndex:currentIndex+1];
        }
    }
    else if(respokenVC != nil)
    {
        int nextIndex;
        Spoke *nextSpoke;
        if (currentIndex < [respokenVC.respokenArray count])
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
            SpokeCell *cell = (SpokeCell*)[respokenVC tableView:respokenVC.respokenTableView cellForRowAtIndexPath:indexPath];
            [NSObject cancelPreviousPerformRequestsWithTarget:cell selector:@selector(playSequence) object:nil];
//            [cell invalidateHidePlayBarViewSelector];
            
            nextIndex = currentIndex + 1;
            nextSpoke = [respokenVC.respokenArray objectAtIndex:nextIndex];
        }
        else if(currentIndex == -1)
        {
            nextIndex = 0;
            nextSpoke = [respokenVC.respokenArray objectAtIndex:0];
        }
        currentPlayingSpokeCell = [respokenVC changeCell:nextSpoke andIndex:nextIndex];
    }
}

- (IBAction)playButtonPressed:(id)sender
{
    if(profileVC != nil)
    {
        if(profileVC.player.playing)
        {
            [profileVC.player pause];
            [playButton setSelected:NO];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
        else
        {
            [profileVC.player play];
            [playButton setSelected:YES];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        }
    }
    else if(wallVC != nil)
    {
        if(wallVC.player.playing)
        {
            [wallVC.player pause];
            wallVC.playerInPause = YES;
            [playButton setSelected:YES];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
        else
        {
            [wallVC.player play];
            wallVC.playerInPause = NO;
            [playButton setSelected:NO];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        }
    }
    else if(respokenVC != nil)
    {
        if(respokenVC.player.playing)
        {
            [respokenVC.player pause];
            respokenVC.playerInPause = YES;
            [playButton setSelected:YES];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
        else
        {
            [respokenVC.player play];
            respokenVC.playerInPause = NO;
            [playButton setSelected:NO];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        }
    }
}

- (IBAction)respokenButtonPressed:(id)sender
{
    Spoke *currentSpoke = currentPlayingSpokeCell.currentSpoke;
    [mainVC openRespokenView:currentSpoke];
}

- (void)updateSlider
{
    if(profileVC != nil)
    {
        float progress = profileVC.player.currentTime;
        timeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)profileVC.player.currentTime / 60, (int)profileVC.player.currentTime % 60, nil];
        [playSlider setValue:progress];
    }
    else if(wallVC != nil)
    {
        float progress = wallVC.player.currentTime;
        timeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)wallVC.player.currentTime / 60, (int)wallVC.player.currentTime % 60, nil];
        [playSlider setValue:progress];
    }
    else if(respokenVC != nil)
    {
        float progress = respokenVC.player.currentTime;
        timeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)respokenVC.player.currentTime / 60, (int)respokenVC.player.currentTime % 60, nil];
        [playSlider setValue:progress];
    }
}

- (IBAction)progressSliderMoved:(UISlider*)sender
{
    NSLog(@"PROGRESS SLIDER MOVED");
    if(profileVC != nil)
    {
        [profileVC.player pause];
        [playButton setSelected:YES];
        profileVC.player.currentTime = playSlider.value;
        profileVC.player.currentTime = sender.value;
        timeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)profileVC.player.currentTime / 60, (int)profileVC.player.currentTime % 60, nil];
        playSlider.value = profileVC.player.currentTime;
    }
    else if(wallVC != nil)
    {
        [wallVC.player pause];
        [playButton setSelected:YES];
        wallVC.player.currentTime = playSlider.value;
        wallVC.player.currentTime = sender.value;
        timeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)wallVC.player.currentTime / 60, (int)wallVC.player.currentTime % 60, nil];
        playSlider.value = wallVC.player.currentTime;
    }
    else if(respokenVC != nil)
    {
        [respokenVC.player pause];
        [playButton setSelected:YES];
        respokenVC.player.currentTime = playSlider.value;
        respokenVC.player.currentTime = sender.value;
        timeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)respokenVC.player.currentTime / 60, (int)respokenVC.player.currentTime % 60, nil];
        playSlider.value = respokenVC.player.currentTime;
    }
}

@end
