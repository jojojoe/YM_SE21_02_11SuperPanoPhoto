//
//  GPImageToVideoConverter.h
//  Pano
//
//  Created by JOJO on 2019/2/25.
//  Copyright © 2019 JOJO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GPImageToVideoConverter : NSObject

@property (nonatomic, strong) NSBlockOperation *operation;

+ (instancetype)sharedInstance;

- (void)convertImage:(UIImage *)image toVideoProgressCallback:(void(^)(float progress))progressCallback completion:(void(^)(NSString *videoPath,NSError *error))completion;

- (CGSize)originVideoSize;

@end

NS_ASSUME_NONNULL_END
