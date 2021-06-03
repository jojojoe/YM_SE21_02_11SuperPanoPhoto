//
//  GPImageToVideoConverter.m
//  Pano
//
//  Created by JOJO on 2019/2/25.
//  Copyright © 2019 JOJO. All rights reserved.
//

#import "GPImageToVideoConverter.h"
#import "UIImage+Extense.h"
#import <AVFoundation/AVFoundation.h>
#import "PNTimeFormatTool.h"

@interface GPImageToVideoConverter ()

@property (nonatomic, assign) CGSize imageSize;

@end

@implementation GPImageToVideoConverter

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)convertImage:(UIImage *)image toVideoProgressCallback:(void(^)(float progress))progressCallback completion:(void(^)(NSString *videoPath,NSError *error))completion {
    
    [self generateVideoWithImage:image andProgressCallback:^(float progress) {
        progressCallback(progress);
    } andComlpetion:^(NSString *path,NSError *error) {
        completion(path, error);
    }];
}

- (void)generateVideoWithImage:(UIImage *)image andProgressCallback:(void(^)(float progress))progressCallback andComlpetion:(void(^)(NSString *path,NSError *error))completion {
    
    self.operation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/temp.mp4"];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        
        NSError *error = nil;
        AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
                                                               fileType:AVFileTypeMPEG4
                                                                  error:&error];
        if (error) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil,error);
                });
            }
            return;
        }
        self.imageSize = image.size;
        
        CGFloat bitsPerPixel = 6.0;
        NSInteger bitsPerSecond = image.size.width * image.size.height * bitsPerPixel;
        NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
        AVVideoExpectedSourceFrameRateKey : @(30),
        AVVideoMaxKeyFrameIntervalKey : @(3),
        AVVideoProfileLevelKey : AVVideoProfileLevelH264MainAutoLevel };
        
        //
        NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecTypeH264,
                                        AVVideoWidthKey: [NSNumber numberWithInt:image.size.width],
                                        AVVideoHeightKey: [NSNumber numberWithInt:image.size.height],
                                        AVVideoCompressionPropertiesKey : compressionProperties
        };
        
        NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                                               [NSNumber numberWithInt:image.size.width], kCVPixelBufferWidthKey,
                                                               [NSNumber numberWithInt: image.size.height], kCVPixelBufferHeightKey,
                                                               nil];
        
        
        
        AVAssetWriterInput* videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        
        NSParameterAssert([videoWriter canAddInput:videoInput]);
        [videoWriter addInput:videoInput];
        
        AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
        //Start a session:
        BOOL status = [videoWriter startWriting];        
        [videoWriter startSessionAtSourceTime:kCMTimeZero];
        
        // write video data
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CVPixelBufferRef buffer;
            CVPixelBufferPoolCreatePixelBuffer(NULL, adaptor.pixelBufferPool, &buffer);

            CMTime presentTime = kCMTimeZero;
            CMTime stepTime = CMTimeMake(1, 30);
            NSInteger totalFrames = 10 * 30;
            for (int i = 0; i < totalFrames; i++) {
                buffer = [PNTimeFormatTool pixelBufferFromCGImage:image.CGImage size:image.size transform:CGAffineTransformIdentity];
                BOOL success = [PNTimeFormatTool appendToAdapter:adaptor
                                                     pixelBuffer:buffer
                                                          atTime:presentTime
                                                       withInput:videoInput];
                if (!success) {
                    //                NSLog(@"error");
                }
                CVBufferRelease(buffer);
                float progress = (float)i/totalFrames;
                if (progressCallback) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressCallback(progress);
                    });
                }
                presentTime = CMTimeAdd(presentTime, stepTime);
            }
            [videoInput markAsFinished];
            CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
            [videoWriter finishWritingWithCompletionHandler:^{
                //            NSLog(@"Successfully closed video writer");
                if (videoWriter.status == AVAssetWriterStatusCompleted) {
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(path,nil);
                        });
                    }
                } else {
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(nil,videoWriter.error);
                        });
                    }
                }
            }];
        });
        
        
    }];
    
    [self.operation start];
    
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mp4"];
//        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
//
//        NSError *error = nil;
//        AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
//                                                               fileType:AVFileTypeMPEG4
//                                                                  error:&error];
//        if (error) {
//            if (completion) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    completion(nil,error);
//                });
//            }
//            return;
//        }
//        self.imageSize = image.size;
//        NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecTypeH264,
//                                        AVVideoWidthKey: [NSNumber numberWithInt:image.size.width],
//                                        AVVideoHeightKey: [NSNumber numberWithInt:image.size.height]};
//
//        AVAssetWriterInput* videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
//
//        NSParameterAssert([videoWriter canAddInput:videoInput]);
//        [videoWriter addInput:videoInput];
//
//        AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoInput sourcePixelBufferAttributes:nil];
//        //Start a session:
//        [videoWriter startWriting];
//        [videoWriter startSessionAtSourceTime:kCMTimeZero];
//
//        // write video data
//        CVPixelBufferRef buffer;
//        CVPixelBufferPoolCreatePixelBuffer(NULL, adaptor.pixelBufferPool, &buffer);
//
//        CMTime presentTime = kCMTimeZero;
//        CMTime stepTime = CMTimeMake(1, 30);
//        NSInteger totalFrames = 10 * 30;
//        for (int i = 0; i < totalFrames; i++) {
//            buffer = [PNTimeFormatTool pixelBufferFromCGImage:image.CGImage size:image.size transform:CGAffineTransformIdentity];
//            BOOL success = [PNTimeFormatTool appendToAdapter:adaptor
//                                                 pixelBuffer:buffer
//                                                      atTime:presentTime
//                                                   withInput:videoInput];
//            if (!success) {
//                //                NSLog(@"error");
//            }
//            CVBufferRelease(buffer);
//            float progress = (float)i/totalFrames;
//            if (progressCallback) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    progressCallback(progress);
//                });
//            }
//            presentTime = CMTimeAdd(presentTime, stepTime);
//        }
//        [videoInput markAsFinished];
//        CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
//        [videoWriter finishWritingWithCompletionHandler:^{
//            //            NSLog(@"Successfully closed video writer");
//            if (videoWriter.status == AVAssetWriterStatusCompleted) {
//                if (completion) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        completion(path,nil);
//                    });
//                }
//            } else {
//                if (completion) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        completion(nil,videoWriter.error);
//                    });
//                }
//            }
//        }];
//    });
}

- (CGSize)originVideoSize {
    return self.imageSize;
}



@end
