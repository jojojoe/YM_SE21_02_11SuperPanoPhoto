//
//  GPUImageDisplayFilter.m
//  Filto
//
//  Created by sunhaosheng on 2019/2/20.
//  Copyright © 2019 hs sun. All rights reserved.
//

#import "GPUImageDisplayFilter.h"

@interface GPUImageDisplayFilter() {
    CGFloat currentOffset;
}

@end

@implementation GPUImageDisplayFilter

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    CGFloat yRate = self.canvasSize.height / self.imageSize.height;
    CGFloat rate = self.canvasSize.width / (self.imageSize.width * yRate);
    CGFloat totalOffset = 1 - rate;
    
    CGFloat step = totalOffset / self.totalFrames;
    GLfloat textures[] = {
//        currentOffset + rate, 0.0f,
//        currentOffset, 0.0f,
//        currentOffset + rate, 1,
//        currentOffset, 1,
        currentOffset, 0.0f,
        currentOffset + rate, 0.0f,
        currentOffset, 1,
        currentOffset + rate, 1,
    };
//    NSLog(@"currentOffset = %.2f , currentOffset2 = %.2f , step = %.2f",currentOffset,currentOffset + rate, step);
    currentOffset += step;
    [self renderToTextureWithVertices:imageVertices textureCoordinates:textures];
    
    [self informTargetsAboutNewFrameAtTime:frameTime];
}

- (void)VO_resetAnimationStep {
    currentOffset = 0;
}

@end
