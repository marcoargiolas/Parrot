//
//  UIImage+Additions.h
//  Parrot
//
//  Created by Marco Argiolas on 03/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

/*!
 @method
 
 @abstract It returns a mask rounded image in a given rect of a certain size.
 
 @param aRect A specific rect in which we draw the circle.
 @param aSize A specific size for the mask image.
 
 @return UIImahe of the mask.
 */
+ (UIImage *)ellipsedMaskFromRect:(CGRect)aRect inSize:(CGSize)aSize;

/*!
 @method
 
 @abstract It returns a rounded image with a given mask.
 
 @param size The size of the needed image.
 @param maskImagePar The mask image needed to crop the original image.
 
 @return UIImage rounded.
 */
- (UIImage *)roundedImageWithSize:(CGSize)size andMaskImage:(UIImage*)maskImagePar;

@end
