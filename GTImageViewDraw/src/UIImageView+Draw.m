//
//  UIView+Draw.m
//  GTImageViewDraw
//
//  Created by Gianluca Tursi on 25/03/14.
//  Copyright (c) 2014 Gianluca Tursi. All rights reserved.
//

#import "UIImageView+Draw.h"


@implementation UIImageView (Draw)

UIImage *mainImg;
UIImageView *mainImageView;

BOOL _isErasing = NO;
BOOL activate = NO;
CGPoint lastPoint;
CGFloat red = 0.0/255.0;
CGFloat green = 0.0/255.0;
CGFloat blue = 0.0/255.0;
CGFloat brush = 5.0;
CGFloat opacity = 1.0;
BOOL mouseSwiped;

- (void)startDrawing{

    activate = YES;
    self.userInteractionEnabled = YES;
    mainImg = self.image;
    mainImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:mainImageView];
    
}

- (void)debugMode:(BOOL)mode {
    if (mode) {
        self.layer.borderWidth = 4;
        self.layer.borderColor = [UIColor redColor].CGColor;
        mainImageView.layer.borderWidth = 2;
        mainImageView.layer.borderColor = [UIColor blueColor].CGColor;
    } else {
        self.layer.borderWidth = 0;
        mainImageView.layer.borderWidth = 0;
    }
}

- (void)stopDrawing {
    
    activate = NO;
}

- (void)resetImage {
    
     _isErasing = NO;
    [mainImageView removeFromSuperview];
    mainImageView = nil;
    mainImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:mainImageView];
}

- (void)setBrush:(CGFloat) b {
    
    brush = b;
}

- (void) setColor:(UIColor *) color {
     _isErasing = NO;
    [color getRed:&red green:&green blue:&blue alpha:&opacity];
}

- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    
    CGSize newImageSize = CGSizeMake(MAX(firstImage.size.width, secondImage.size.width), MAX(firstImage.size.height, secondImage.size.height));
    
    UIGraphicsBeginImageContextWithOptions(newImageSize, NO, 0.0);

    [firstImage drawAtPoint:CGPointMake(roundf((newImageSize.width-firstImage.size.width)/2),
                                        roundf((newImageSize.height-firstImage.size.height)/2))];
    [secondImage drawAtPoint:CGPointMake(roundf((newImageSize.width-secondImage.size.width)/2),
                                         roundf((newImageSize.height-secondImage.size.height)/2))];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (CGFloat)getScale {
    CGFloat scale = 1.0;
    if([[UIScreen mainScreen]respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen]scale];
    }
    return scale;
}

- (void)save {
    
    UIImage *imageToSave = [self imageByCombiningImage:mainImg withImage:mainImageView.image];
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO,0.0);
    [imageToSave drawInRect:CGRectMake(0, 0, mainImageView.frame.size.width, mainImageView.frame.size.height)];
    UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(SaveImage, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}

- (UIImage *)getCurrentImage {
    
    
    UIImage *bottomImage = mainImg; //background image
    UIImage *image       = mainImageView.image; //foreground image
    
    CGSize newSize = CGSizeMake(mainImg.size.width, mainImg.size.height);
    UIImage *newImage;
    
    @autoreleasepool {
        UIGraphicsBeginImageContext(newSize);
        
        // Use existing opacity as is
        [bottomImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        
        // Apply supplied opacity if applicable
        CGFloat imageViewAspect = bottomImage.size.width / bottomImage.size.height;
        CGFloat drawingViewAspect = image.size.width / image.size.height;
        CGFloat aspectChange = imageViewAspect / drawingViewAspect;
        CGRect drawRect = CGRectMake(0, (1 - aspectChange) * newSize.height / 2, newSize.width,  aspectChange * newSize.height);
        [image drawInRect:drawRect];
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
    }
    self.layer.contents = nil;
    mainImg = nil;
    mainImageView.image = nil;
    mainImageView = nil;
    return newImage;
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    //
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if(!activate){
        [self startDrawing];
    }
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self];
}

-(void)selectRubber{
    
    _isErasing = YES;
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(activate){
        mouseSwiped = YES;
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self];
        
        UIGraphicsBeginImageContext(self.frame.size);
        [mainImageView.image drawInRect:CGRectMake(0, 0, roundf(self.frame.size.width), roundf(self.frame.size.height))];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        
        if (_isErasing) {
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
        }
        else {
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        }
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        [mainImageView setAlpha:opacity];
        UIGraphicsEndImageContext();
        
        lastPoint = currentPoint;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(activate){
        if(!mouseSwiped) {
            UIGraphicsBeginImageContext(self.frame.size);
            [mainImageView.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextStrokePath(UIGraphicsGetCurrentContext());
            CGContextFlush(UIGraphicsGetCurrentContext());
            mainImageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
}

@end
