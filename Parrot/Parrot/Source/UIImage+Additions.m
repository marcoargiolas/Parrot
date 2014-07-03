//
//  UIImage+Additions.m
//  Parrot
//
//  Created by Marco Argiolas on 03/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (UIImage *)ellipsedMaskFromRect:(CGRect)aRect inSize:(CGSize)aSize
{
    UIImage *retImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(aSize, YES, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, 255.0, 255.0, 255.0, 1.0);
    CGContextSetRGBStrokeColor(context, 255.0, 255.0, 255.0, 1.0);
    
    CGContextFillRect(context, CGRectMake(0, 0, aSize.width, aSize.height));
    
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    
    CGContextFillEllipseInRect(context, aRect);
    
    retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return retImage;
}

- (UIImage *)roundedImageWithSize:(CGSize)size andMaskImage:(UIImage*)maskImagePar
{
    UIGraphicsBeginImageContextWithOptions(size, YES, self.scale);
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* eyeImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIImage *maskImage = [maskImagePar scaleToSize:size];
    
    CGImageRef mask = CGImageMaskCreate (CGImageGetWidth (maskImage.CGImage),
                                         CGImageGetHeight (maskImage.CGImage),
                                         CGImageGetBitsPerComponent (maskImage.CGImage),
                                         CGImageGetBitsPerPixel (maskImage.CGImage),
                                         CGImageGetBytesPerRow (maskImage.CGImage),
                                         CGImageGetDataProvider (maskImage.CGImage), NULL , false);
    
    CGImageRef masked = CGImageCreateWithMask(eyeImage.CGImage, mask);
    
    CGImageRef cutted = CGImageCreateWithImageInRect(masked, CGRectMake(0.0, 0.0, size.width, size.height));
    
    UIImage* retVal = [UIImage imageWithCGImage:cutted scale: self.scale orientation:self.imageOrientation];
    
    CGImageRelease(cutted);
    
    CGImageRelease(masked);
    CGImageRelease(mask);
    
    UIGraphicsEndImageContext();
    
    return retVal;
}

- (UIImage *)scaleToSize:(CGSize)size
{
    // Create a bitmap graphics context
    // This will also set it as the current context
    UIGraphicsBeginImageContext(size);
    
    // Draw the scaled image in the current context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // Create a new image from current context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Pop the current context from the stack
    UIGraphicsEndImageContext();
    
    // Return our new scaled image
    return scaledImage;
}

@end
