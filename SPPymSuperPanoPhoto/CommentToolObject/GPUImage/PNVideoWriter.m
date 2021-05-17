//
//  PNVideoWriter.m
//  Pano
//
//  Created by JOJO on 2019/2/27.
//  Copyright © 2019 JOJO. All rights reserved.
//

#import "PNVideoWriter.h"
#import "GPUImage.h"
#import "GPUImageDisplayFilter.h"
#import "GPImageToVideoConverter.h"

@interface PNVideoWriter ()

@property (nonatomic, strong) GPUImageMovie *movieFile;
@property (nonatomic, strong) GPUImageMovieWriter *writer;
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) GPUImageDisplayFilter *displayFilter;
@end

@implementation PNVideoWriter

/*
 
 */

- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [super init];
    if (self) {
        _asset = asset;
        _movieFile = [[GPUImageMovie alloc] initWithAsset:asset];
        _movieFile.playAtActualSpeed = NO;
        _movieFile.runBenchmark = NO;
        
        CGSize imageSize = [[GPImageToVideoConverter sharedInstance] originVideoSize];
        
        CGSize reSize = CGSizeMake(imageSize.height * (40.f / 50.f) / 2, imageSize.height / 2);
        
        CGSize outputSize = CGSizeMake(400, 500);
        _displayFilter = [[GPUImageDisplayFilter alloc] init];
        _displayFilter.canvasSize = outputSize;
        _displayFilter.imageSize = reSize;
        _displayFilter.totalFrames = 30 * 10;
        
        
        NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecTypeH264,
                                        AVVideoWidthKey: [NSNumber numberWithInt:outputSize.width],
                                        AVVideoHeightKey: [NSNumber numberWithInt:outputSize.height]
                                        };
        _writer = [[GPUImageMovieWriter alloc] initWithMovieURL:[PNVideoWriter outputUrl] size:outputSize fileType:AVFileTypeMPEG4 outputSettings:videoSettings];
        
        if ([asset tracksWithMediaType:AVMediaTypeAudio].count != 0) {
            _movieFile.audioEncodingTarget = _writer;
        }
        [_movieFile enableSynchronizedEncodingUsingMovieWriter:_writer];
        
        [_movieFile addTarget:_displayFilter];
        [_displayFilter addTarget:_writer];
        
    }
    return self;
}

- (instancetype)initWithAsset:(AVAsset *)asset imageSize:(CGSize)imageSize {
    self = [super init];
    if (self) {
        _asset = asset;
        _movieFile = [[GPUImageMovie alloc] initWithAsset:asset];
        _movieFile.playAtActualSpeed = NO;
        _movieFile.runBenchmark = NO;
        
        CGSize imageSize = [[GPImageToVideoConverter sharedInstance] originVideoSize];
        
        CGSize reSize1 = imageSize;
        
        CGSize outputSize = CGSizeMake(400, 500);
        _displayFilter = [[GPUImageDisplayFilter alloc] init];
        _displayFilter.canvasSize = outputSize;
        _displayFilter.imageSize = reSize1;
        _displayFilter.totalFrames = 30 * 10;
        
        
        NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecTypeH264,
                                        AVVideoWidthKey: [NSNumber numberWithInt:outputSize.width],
                                        AVVideoHeightKey: [NSNumber numberWithInt:outputSize.height]
                                        };
        _writer = [[GPUImageMovieWriter alloc] initWithMovieURL:[PNVideoWriter outputUrl] size:outputSize fileType:AVFileTypeMPEG4 outputSettings:videoSettings];
        
        if ([asset tracksWithMediaType:AVMediaTypeAudio].count != 0) {
            _movieFile.audioEncodingTarget = _writer;
        }
        [_movieFile enableSynchronizedEncodingUsingMovieWriter:_writer];
        
        [_movieFile addTarget:_displayFilter];
        [_displayFilter addTarget:_writer];
        
    }
    return self;
}


- (void)startWritingWithCompletion:(void (^)(NSURL * _Nonnull url))completion andProgressBlock:(nonnull void (^)(float))progressBlock {
    __weak typeof(self) weakSelf = self;
    unlink([[PNVideoWriter outputUrl].path UTF8String]);
    [weakSelf.writer startRecording];
    [weakSelf.movieFile startProcessing];
    [weakSelf.writer setCompletionBlock:^{
        [weakSelf.writer finishRecordingWithCompletionHandler:^{
            if (completion) {
                completion([PNVideoWriter outputUrl]);
            }
        }];
    }];
}

+ (NSURL *)outputUrl {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"output.mp4"];
    
    return [NSURL fileURLWithPath:path];
}

+ (void)writerVideoWithVideoPath:(NSString *)videoPath completion:(void(^)(NSURL *videoPath, NSError *error))completion {
    
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)}];
    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    AVMutableComposition *editComposition = [AVMutableComposition compositionWithURLAssetInitializationOptions:nil];
    AVMutableCompositionTrack *compositionVideoTrack = [editComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    compositionVideoTrack.preferredTransform = videoTrack.preferredTransform;
    
//    if (self.musicToolView.filePath && ![self.musicToolView.filePath isEqualToString:@""]) {
//        //    if (self.isAddMusic) {
//        // add music
//        NSString *audioPath = self.musicToolView.filePath;
//        AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:audioPath] options:nil];
//        AVAssetTrack *audioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
//        AVMutableCompositionTrack *compositionAudioTrack = [self.editComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:INSERT_AUDIO_TRACK_ID];
//        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:audioTrack atTime:kCMTimeZero error:nil];
//        //
//    }
    __weak typeof(self) weakSelf = self;
    [editComposition loadValuesAsynchronouslyForKeys:@[@"tracks",@"duration"] completionHandler:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        AVKeyValueStatus status = [editComposition statusOfValueForKey:@"tracks" error:nil];
        if (status != AVKeyValueStatusLoaded) {
            return;
        }
        status = [editComposition statusOfValueForKey:@"duration" error:nil];
        if (status != AVKeyValueStatusLoaded) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            PNVideoWriter *videoWriter = [[PNVideoWriter alloc] initWithAsset:editComposition];
            
            [videoWriter startWritingWithCompletion:^(NSURL * _Nonnull outputUrl) {
                NSLog(@"outputUrl : %@",outputUrl);
                if (outputUrl) {
                    completion(outputUrl,nil);
                }
            } andProgressBlock:^(float progress) {
                
            }];
        });
    }];
}

@end
