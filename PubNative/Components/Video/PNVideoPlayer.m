//
// PNVideoPlayer.m
//
// Created by Csongor Nagy on 06/03/14.
// Copyright (c) 2014 PubNative
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PNVideoPlayer.h"

@implementation PNVideoPlayer

- (id)initWithDelegate:(id<PNVideoPlayerDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
    }
	
    return self;
}

- (void)dealloc
{
    [self close];
}

- (void)open:(NSString*)urlString autoplay:(BOOL)autoplay
{
    [self cleanup];
    
    NSURL *url = nil;
    
	if ([urlString hasPrefix:@"/"])
    {
        url = [NSURL fileURLWithPath:urlString];
    }
    else
    {
        url= [NSURL URLWithString:urlString];
    }
    
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [self.player setControlStyle:MPMovieControlStyleNone];
    [self.player setScalingMode:MPMovieScalingModeAspectFit];
    [self.player setFullscreen:YES animated:YES];
    [self.player setShouldAutoplay:autoplay];
    [self.player setMovieSourceType:MPMovieSourceTypeFile];
    
    if ([self.delegate respondsToSelector:@selector(videoViewAvailable:)])
    {
        [self.delegate videoViewAvailable:self.player.view];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidStarted:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackPrepared:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:nil];
    
    [self.player prepareToPlay];
    
    if ([self.delegate respondsToSelector:@selector(playbackPreparing)])
    {
        [self.delegate playbackPreparing];
    }
}

- (void)close
{
    self.delegate = nil;
    [self stop];
    [self cleanup];
    
}

- (void)cleanup
{
    if ([self.progressTimer isValid])
    {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
    
    [self.player.view removeFromSuperview];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)play
{
    [self.player play];
}

- (void)stop
{
    [self.player stop];
}

- (void)pause
{
    [self.player pause];
}

- (void)seekTo:(NSInteger)posInSeconds
{
    if (posInSeconds >= 0 &&
        posInSeconds <= self.player.duration)
    {
        self.player.currentPlaybackTime = posInSeconds;
    }
}

- (NSInteger)duration
{
    return self.player.duration;
}

- (NSInteger)currentPosition
{
    NSInteger ret = 0;
    
    if (self.player.loadState & MPMovieLoadStatePlayable)
    {
        ret = self.player.currentPlaybackTime;
    }
    
	return ret;
}



#pragma mark - Movie Player Notifications

- (void)moviePlaybackPrepared:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.progressTimer.isValid)
        {
            [self.progressTimer invalidate];
            self.progressTimer = nil;
        }
        
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(onProgressTimer)
                                                            userInfo:nil
                                                             repeats:YES];
    });
}

- (void)moviePlayBackDidStarted:(NSNotification*)notification
{
    if (self.player.playbackState == MPMoviePlaybackStatePlaying)
    {
        if ([self.delegate respondsToSelector:@selector(playbackStartedWithDuration:)])
        {
            [self.delegate playbackStartedWithDuration:self.player.playableDuration];
        }
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSNumber *reason = [userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
        
        switch (reason.integerValue)
        {
            case MPMovieFinishReasonPlaybackEnded:
                if ([self.delegate respondsToSelector:@selector(playbackCompleted)])
                {
                    [self.delegate playbackCompleted];
                }
                break;
            case MPMovieFinishReasonPlaybackError:
                if ([self.delegate respondsToSelector:@selector(playbackError:)])
                {
                    [self.delegate playbackError:0];
                }
                break;
            default:
                break;
        }
        
        [self cleanup];
    });
}

- (void)onProgressTimer
{
    if ([self.player isPreparedToPlay])
    {
        if ([self.delegate respondsToSelector:@selector(playbackProgress:duration:)])
        {
            [self.delegate playbackProgress:self.player.currentPlaybackTime
                                   duration:self.player.duration];
        }
    }
}

@end
