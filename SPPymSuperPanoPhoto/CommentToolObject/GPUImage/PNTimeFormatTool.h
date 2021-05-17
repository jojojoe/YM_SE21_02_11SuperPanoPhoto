//
//  PNTimeFormatTool.h
//  Pano
//
//  Created by JOJO on 2019/2/25.
//  Copyright © 2019 JOJO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNTimeFormatTool : NSObject
+ (NSString *)getMMSSFromSS:(NSTimeInterval)totalTime;

+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
                                      size:(CGSize)imageSize
                                 transform:(CGAffineTransform)transform;

+ (BOOL)appendToAdapter:(AVAssetWriterInputPixelBufferAdaptor*)adaptor
            pixelBuffer:(CVPixelBufferRef)buffer
                 atTime:(CMTime)presentTime
              withInput:(AVAssetWriterInput*)writerInput;

@end

NS_ASSUME_NONNULL_END
