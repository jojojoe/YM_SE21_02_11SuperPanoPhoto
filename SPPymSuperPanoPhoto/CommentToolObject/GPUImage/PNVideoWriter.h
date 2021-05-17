//
//  PNVideoWriter.h
//  Pano
//
//  Created by JOJO on 2019/2/27.
//  Copyright © 2019 JOJO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface PNVideoWriter : NSObject
- (instancetype)initWithAsset:(AVAsset *)asset;
- (instancetype)initWithAsset:(AVAsset *)asset imageSize:(CGSize)imageSize;
- (void)startWritingWithCompletion:(void(^)(NSURL *outputUrl))completion andProgressBlock:(void(^)(float progress))progressBlock;
+ (NSURL *)outputUrl;
+ (void)writerVideoWithVideoPath:(NSString *)videoPath completion:(void(^)(NSURL *videoPath, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
