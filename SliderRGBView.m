//
//  SliderRGBView.m
//  tryRGB
//
//  Created by mac1 on 16/5/11.
//  Copyright © 2016年 mac1. All rights reserved.
//

#import "SliderRGBView.h"

@implementation SliderRGBView
-(SliderRGBView *)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    //分段颜色数组
    NSMutableArray *colorArray = [@[[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1.0f],
                                                    [UIColor colorWithRed:0.0f green:1.0f blue:1.0f alpha:1.0f],
                                                    [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f],
                                                    [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f],
                                                    [UIColor colorWithRed:1.0f green:0.0f blue:1.0f alpha:1.0f],
                                                    [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f],
                                                    [UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:1.0f],
                                ] mutableCopy];
    
    
    //彩虹条
    self.bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, frame.size.width, 3)];
    self.bgImg.image = [self BgImageFromColors:colorArray withFrame:CGRectMake(0, 5,frame.size.width , 3)];
     [self addSubview:self.bgImg];
    
    
    self.slider = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 30, 30)];
#warning mark - 修改这个图片更换滑动条下面的图片样式
    [self.slider setImage:[UIImage imageNamed:@"bg_color_cursor"]];
    [self addSubview:self.slider];
    
    //演示颜色的圆圈
    self.colorIndatorView = [[UIView alloc] initWithFrame:CGRectMake(5, 3, 20, 20)];
    self.colorIndatorView.layer.cornerRadius = 10.0;
    [self.colorIndatorView setBackgroundColor:[self getPixelColorAtLocation:CGPointMake(self.slider.center.x, 1)]];
    
    //滑动条上面的水滴图片
    self.colorIndatorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -30, 30, 30)];
    [self.colorIndatorImgView setImage:[UIImage imageNamed:@"bg_color_cursor"]];
    [self.slider addSubview:self.colorIndatorImgView];
    [self.colorIndatorImgView addSubview:self.colorIndatorView];
    
    
    //拖动手势
    UIPanGestureRecognizer * panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(getColor:)];
    [self.slider setUserInteractionEnabled:YES];
    [self.slider addGestureRecognizer:panRecognizer];
    return self;
}
/**
 *  滑动取色
 *
 *  @param pRecognizer 拖动手势
 */
-(void)getColor:(UIPanGestureRecognizer *)pRecognizer
{
    CGPoint point = [pRecognizer translationInView:self];
    CGFloat sliderX = pRecognizer.view.center.x + point.x;
    if (sliderX <= 15) {
        sliderX = 15;
    }
    if (sliderX >= self.frame.size.width - 15) {
        sliderX = self.frame.size.width - 15;
    }
    self.slider.center = CGPointMake(sliderX, self.slider.center.y);
   
    [pRecognizer setTranslation:CGPointMake(0, 0) inView:self];
    
    [self getPixelColorAtLocation:CGPointMake(self.slider.center.x, 2)];
   // [self.slider setBackgroundColor: [self getPixelColorAtLocation:CGPointMake(self.slider.center.x - 15, 1)]];
    [self.colorIndatorView setBackgroundColor:[self getPixelColorAtLocation:CGPointMake(self.slider.center.x , 1)]];
    [self.delegate getSliderColorMethod:[self getPixelColorAtLocation:CGPointMake(self.slider.center.x , 1)]];
    
}
//生成渐变色图片
- (UIImage*) BgImageFromColors:(NSArray*)colors withFrame: (CGRect)frame

{
    
    NSMutableArray *ar = [NSMutableArray array];
    
    for(UIColor *c in colors) {
        
        [ar addObject:(id)c.CGColor];
        
    }
    
    UIGraphicsBeginImageContextWithOptions(frame.size, YES, 1);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    
    CGPoint start;
    
    CGPoint end;
    
    
    
    start = CGPointMake(0.0, frame.size.height);
    
    end = CGPointMake(frame.size.width, 0.0);
    
    
    
    CGContextDrawLinearGradient(context, gradient, start, end,kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(context);
    
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsEndImageContext();
    
    return image;
    
}
//image 取色
- (UIColor *) getPixelColorAtLocation:(CGPoint)point {
    UIColor* color = nil;
    CGImageRef inImage = self.bgImg.image.CGImage;//self.image.CGImage;
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) {
        return nil; /* error */
    }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        //NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    return color;
}
- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
