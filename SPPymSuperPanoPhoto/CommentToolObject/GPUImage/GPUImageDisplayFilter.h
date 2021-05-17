//
//  GPUImageDisplayFilter.h
//  Filto
//
//  Created by sunhaosheng on 2019/2/20.
//  Copyright © 2019 hs sun. All rights reserved.
//

#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageDisplayFilter : GPUImageFilter

@property (nonatomic, assign) CGSize canvasSize;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) NSInteger totalFrames;

@end

NS_ASSUME_NONNULL_END
