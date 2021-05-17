//
//  UIImage+Extense.h
//  HelloWorld
//
//  Created by Albert on 2/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage(Extense)
- (UIImage*)imageByScalingWithScale:(CGFloat)theScale;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage*)resizeImageWithPixels:(float)numPixels;
- (UIImage*)convertImageWithPixels:(float)numPixels radius:(float)radius;
- (UIImage*)imageByScalingAcecptRadioToSize:(CGSize)theSize;
- (CGFloat)ratioForFittingToSize:(CGSize)theSize;
- (UIImage*)imageByScalingAcecptFillRadioToSize:(CGSize)theSize;
- (UIImage*)imageByRotatingImageFromImageOrientation:(UIImageOrientation)orientation;

- (UIImage *)processPreviewImgaeWithScreen;

- (UIImage *)fixOrientation;
@end
