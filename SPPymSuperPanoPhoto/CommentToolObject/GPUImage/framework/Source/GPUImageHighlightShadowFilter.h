#import "GPUImageFilter.h"

@interface GPUImageHighlightShadowFilter : GPUImageFilter
{
    GLint shadowsUniform, highlightsUniform, saturationUniform;
}

/**
 * 0 - 1, increase to lighten shadows.
 * @default 0
 */
@property(readwrite, nonatomic) CGFloat shadows;

/**
 * 0 - 1, decrease to darken highlights.
 * @default 1
 */
@property(readwrite, nonatomic) CGFloat highlights;

@property (nonatomic,assign) CGFloat saturation;

@end
