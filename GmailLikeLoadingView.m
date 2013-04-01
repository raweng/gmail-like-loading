//
//  ActivityIndicatorView.m
//  ActivityIndicator
//
//  Created by Nikhil Gohil on 27/12/12.
//  Copyright (c) 2012 Nikhil Gohil. All rights reserved.
//

#import "GmailLikeLoadingView.h"
#import <QuartzCore/QuartzCore.h>

typedef enum {
    kFlipStop = 0,
    kFlipTopBottom,
	kFlipBottomTop,
	kFlipLeftRight,
    kFlipRightLeft,
    kFlipStopAnimating
} kFlipDirectionState;

@interface GmailLikeLoadingView (){
    kFlipDirectionState flipState;
    kFlipDirectionState previousFlipState;
    UIView *frontLayerView;
    UIView *backLayerView;
    UIView *firstHalfFrontLayerView;
	UIView *secondHalfFrontLayerView;
	UIView *firstHalfBackLayerView;
	UIView *secondHalfBackLayerView;
    BOOL horizontal;
    NSMutableArray *colorsArray;
}
-(void)animateView;
-(NSArray*)splitViewToImages:(UIView*)view forFlipState:(kFlipDirectionState)flipDirection;

@end

@implementation GmailLikeLoadingView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        CGFloat diameter = MIN(self.frame.size.width, self.frame.size.height);
        
        colorsArray = [NSMutableArray arrayWithObjects:[UIColor colorWithRed:0.0/255.0f green:147.0/255.0f blue:78.0/255.0f alpha:1.0],[UIColor colorWithRed:20.0/255.0f green:99.0/255.0f blue:233.0/255.0 alpha:1.0],[UIColor colorWithRed:255.0/255.0f green:199.0/255.0f blue:12.0/255.0f alpha:1.0],[UIColor colorWithRed:221.0/255.0f green:0.0/255.0f blue:31.0/255.0 alpha:1.0], nil];
        
        frontLayerView = [[UIView alloc] init];
        [frontLayerView setBackgroundColor:[UIColor clearColor]];
        [frontLayerView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        frontLayerView.layer.cornerRadius = diameter/2;
        UIColor *frontColor = [colorsArray objectAtIndex:0];
        [self moveObjectsInArray];
        [frontLayerView.layer setBackgroundColor:frontColor.CGColor];
        frontLayerView.center = self.center;
        
        backLayerView = [[UIView alloc] init];
        [backLayerView setBackgroundColor:[UIColor clearColor]];
        [backLayerView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        backLayerView.layer.cornerRadius = diameter/2;
        UIColor *backColor = [colorsArray objectAtIndex:0];
        [self moveObjectsInArray];
        [backLayerView.layer setBackgroundColor:backColor.CGColor];
        backLayerView.center = self.center;
        previousFlipState = kFlipStop;
        flipState = kFlipBottomTop;
        animationCount_ = 0;
        horizontal = NO;
    }
    return self;
}

-(NSArray*)splitViewToImages:(UIView*)view forFlipState:(kFlipDirectionState)flipDirection{
    
    
    NSArray *returnArray = nil;
    UIGraphicsBeginImageContextWithOptions(view.layer.bounds.size, view.layer.opaque, 0.f);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGSize size;
    if (flipDirection == kFlipBottomTop || flipDirection == kFlipTopBottom) {
        size = CGSizeMake(renderedImage.size.width, renderedImage.size.height / 2);
    }else{
        size = CGSizeMake(renderedImage.size.width / 2, renderedImage.size.height);
    }
	UIImage *top = nil;
	UIImage *bottom = nil;
	UIGraphicsBeginImageContextWithOptions(size, view.layer.opaque, 0.f);
	{{
		[renderedImage drawAtPoint:CGPointZero];
        
		top = UIGraphicsGetImageFromCurrentImageContext();
	}}
	UIGraphicsEndImageContext();
    
	UIGraphicsBeginImageContextWithOptions(size, view.layer.opaque, 0.f);
	{{
        if (flipDirection == kFlipBottomTop || flipDirection == kFlipTopBottom) {
            [renderedImage drawAtPoint:CGPointMake(CGPointZero.x, -renderedImage.size.height / 2)];
        }else{
            [renderedImage drawAtPoint:CGPointMake(-renderedImage.size.width / 2,CGPointZero.y)];
        }
		bottom = UIGraphicsGetImageFromCurrentImageContext();
	}}
	UIGraphicsEndImageContext();
    
	UIImageView *topHalfView = [[UIImageView alloc] initWithImage:top];
	UIImageView *bottomHalfView = [[UIImageView alloc] initWithImage:bottom];
    if (flipDirection == kFlipBottomTop || flipDirection == kFlipTopBottom) {
        returnArray = [NSArray arrayWithObjects:topHalfView, bottomHalfView, nil];
    }else{
        returnArray = [NSArray arrayWithObjects:topHalfView, bottomHalfView, nil];
    }
	return returnArray;

}

- (CGPoint)center:(CGPoint)oldCenter movedFromAnchorPoint:(CGPoint)oldAnchorPoint toAnchorPoint:(CGPoint)newAnchorPoint withFrame:(CGRect)frame;
{
	CGPoint anchorPointDiff = CGPointMake(newAnchorPoint.x - oldAnchorPoint.x, newAnchorPoint.y - oldAnchorPoint.y);
	CGPoint newCenter = CGPointMake(oldCenter.x + (anchorPointDiff.x * frame.size.width),
									oldCenter.y + (anchorPointDiff.y * frame.size.height));
	return newCenter;
}

-(void)animateView{
    
	NSArray *frontImages = [self splitViewToImages:frontLayerView forFlipState:flipState];
    
    firstHalfFrontLayerView = [frontImages objectAtIndex:0];

	secondHalfFrontLayerView = [frontImages objectAtIndex:1];
    [firstHalfFrontLayerView setFrame:CGRectMake(0, 0, firstHalfFrontLayerView.frame.size.width, firstHalfFrontLayerView.frame.size.height)];
    firstHalfFrontLayerView.frame = CGRectOffset(firstHalfFrontLayerView.frame, 0, 0);
    [self addSubview:firstHalfFrontLayerView];
    
    secondHalfFrontLayerView.frame = firstHalfFrontLayerView.frame;
    if (flipState == kFlipBottomTop || flipState == kFlipTopBottom) {
        secondHalfFrontLayerView.frame = CGRectOffset(secondHalfFrontLayerView.frame, 0.f, firstHalfFrontLayerView.frame.size.height);
    }else{
        secondHalfFrontLayerView.frame = CGRectOffset(secondHalfFrontLayerView.frame, firstHalfFrontLayerView.frame.size.width, 0.f);
    }
    
    [self addSubview:secondHalfFrontLayerView];

	[frontLayerView removeFromSuperview];
    
	NSArray *backImages = [self splitViewToImages:backLayerView forFlipState:flipState];
    
    firstHalfBackLayerView = [backImages objectAtIndex:0];

    secondHalfBackLayerView = [backImages objectAtIndex:1];
    
    firstHalfBackLayerView.frame = firstHalfFrontLayerView.frame;
	[self insertSubview:firstHalfBackLayerView belowSubview:firstHalfFrontLayerView];
    
    secondHalfBackLayerView.frame = secondHalfFrontLayerView.frame;
    
	[self insertSubview:secondHalfBackLayerView belowSubview:secondHalfFrontLayerView];

    CATransform3D skewedIdentityTransform = CATransform3DIdentity;
	float zDistance = 1000.000000;
	skewedIdentityTransform.m34 = 1.0 / -zDistance;
    
    CGPoint newTopViewAnchorPoint;
    CGPoint newAnchorPointBottomHalf;
    float x,y,z;
    
    if (flipState == kFlipBottomTop || flipState == kFlipTopBottom) {
        newTopViewAnchorPoint = CGPointMake(0.5, 1.0);
        newAnchorPointBottomHalf = CGPointMake(0.5f, 0.f);
        x = 1.f;
        y = 0.f;
        z = 0.f;
    }else{
        newTopViewAnchorPoint = CGPointMake(1.0f, 0.5f);
        newAnchorPointBottomHalf = CGPointMake(0.f,0.5f);
        x = 0.f;
        y = 1.f;
        z = 0.f;
    }
	CGPoint newTopViewCenter = [self center:firstHalfFrontLayerView.center movedFromAnchorPoint:firstHalfFrontLayerView.layer.anchorPoint toAnchorPoint:newTopViewAnchorPoint withFrame:firstHalfFrontLayerView.frame];
    
	firstHalfFrontLayerView.layer.anchorPoint = newTopViewAnchorPoint;
    if (flipState == kFlipBottomTop || flipState == kFlipTopBottom) {
        firstHalfFrontLayerView.center = newTopViewCenter;
    }else{
        [firstHalfFrontLayerView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    }

    [[firstHalfFrontLayerView layer] setOpacity:1.0f];
    [[firstHalfFrontLayerView layer] setOpaque:YES];
    
	CABasicAnimation *topAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
	topAnim.beginTime = CACurrentMediaTime();
	topAnim.duration = 0.2;
	topAnim.fromValue = [NSValue valueWithCATransform3D:skewedIdentityTransform];
    if (flipState == kFlipBottomTop || flipState == kFlipTopBottom) {
        topAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, -M_PI_2, x, y, z)];
    }else{
        topAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, M_PI_2, x, y, z)];
    }
	topAnim.delegate = self;
	topAnim.removedOnCompletion = NO;
	topAnim.fillMode = kCAFillModeForwards;
	topAnim.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.70 :0.00 :1.00 :1.00];
    [[firstHalfFrontLayerView layer] setOpacity:0.955555f];
    [[firstHalfFrontLayerView layer] setOpaque:YES];
	[firstHalfFrontLayerView.layer addAnimation:topAnim forKey:@"topDownFlip"];
    
	CGPoint newBottomHalfCenter = [self center:secondHalfBackLayerView.center movedFromAnchorPoint:secondHalfBackLayerView.layer.anchorPoint toAnchorPoint:newAnchorPointBottomHalf withFrame:secondHalfBackLayerView.frame];
	secondHalfBackLayerView.layer.anchorPoint = newAnchorPointBottomHalf;
    if (flipState == kFlipBottomTop || flipState == kFlipTopBottom) {
        secondHalfBackLayerView.center = newBottomHalfCenter;
    }else{
        [secondHalfBackLayerView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];

    }
    [[secondHalfBackLayerView layer] setOpacity:1.0f];
    [[secondHalfBackLayerView layer] setOpaque:YES];
    
	CABasicAnimation *bottomAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
	bottomAnim.beginTime = topAnim.beginTime + topAnim.duration;
	bottomAnim.duration = topAnim.duration;
    if (flipState == kFlipBottomTop || flipState == kFlipTopBottom) {
        bottomAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, M_PI_2, x, y, z)];
    }else{
        bottomAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, -M_PI_2, x, y, z)];
    }
	bottomAnim.toValue = [NSValue valueWithCATransform3D:skewedIdentityTransform];
	bottomAnim.delegate = self;
	bottomAnim.removedOnCompletion = NO;
	bottomAnim.fillMode = kCAFillModeBoth;
	bottomAnim.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.30 :1.00 :1.00 :1.00];
    [[secondHalfBackLayerView layer] setOpacity:0.955555f];
    [[secondHalfBackLayerView layer] setOpaque:YES];
	[secondHalfBackLayerView.layer addAnimation:bottomAnim forKey:@"bottomDownFlip"];
    
}


-(void)checkFlipDirectionState {
    switch (flipState) {
        case kFlipBottomTop:
        {
            horizontal = NO;
            [self animateView];
            previousFlipState = kFlipBottomTop;
            flipState = kFlipTopBottom;
        }
            break;
        case kFlipTopBottom:
        {
            horizontal = NO;
			[secondHalfBackLayerView.superview bringSubviewToFront:secondHalfBackLayerView];
            previousFlipState = kFlipTopBottom;
            flipState = kFlipStop;
        }
            break;
        case kFlipLeftRight:
        {
            horizontal = YES;
            [self animateView];
            previousFlipState = kFlipLeftRight;
            flipState = kFlipRightLeft;
        }
            break;
        case kFlipRightLeft:
        {
            horizontal = YES;
            [secondHalfBackLayerView.superview bringSubviewToFront:secondHalfBackLayerView];
            previousFlipState = kFlipRightLeft;
            flipState = kFlipStop;
        }
            break;
        case kFlipStop:
        {
            [firstHalfFrontLayerView removeFromSuperview];
			[secondHalfFrontLayerView removeFromSuperview];
			[firstHalfBackLayerView removeFromSuperview];
			[secondHalfBackLayerView removeFromSuperview];
			firstHalfFrontLayerView = secondHalfFrontLayerView = firstHalfBackLayerView = secondHalfBackLayerView = nil;
            CGColorRef color = frontLayerView.layer.backgroundColor;
            frontLayerView.layer.backgroundColor = backLayerView.layer.backgroundColor;
            backLayerView.layer.backgroundColor = color;
            if (horizontal == NO) {
                flipState = kFlipLeftRight;
            }else{
                flipState = kFlipBottomTop;
            }
            UIColor *backColor = [colorsArray objectAtIndex:0];
            [self moveObjectsInArray];
            backLayerView.layer.backgroundColor = backColor.CGColor;
            [self checkFlipDirectionState];

        }
            break;
        default:
        {
            [firstHalfFrontLayerView removeFromSuperview];
			[secondHalfFrontLayerView removeFromSuperview];
			[firstHalfBackLayerView removeFromSuperview];
			[secondHalfBackLayerView removeFromSuperview];
            firstHalfFrontLayerView = secondHalfFrontLayerView = firstHalfBackLayerView = secondHalfBackLayerView = nil;
        }
            break;
    }
}

-(BOOL)isAnimating {
    return animationCount_ > 0;
}


-(void)stopAnimating{
    if(![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
        return;
    }
    if(animationCount_==1){
        animationCount_ = 0;
        flipState = kFlipStopAnimating;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkFlipDirectionState) object:nil];
        
        [self checkFlipDirectionState];
        
    }
    else {
        animationCount_--;
    }
    
}
-(void)startAnimating{
    if(![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];
        return;
    }
    if (animationCount_<1) {
		animationCount_ = 1;
        flipState = kFlipBottomTop;
        [self checkFlipDirectionState];
	}
    else {
        animationCount_++;
    }
}


-(void)allStop {
    if(![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(allStop) withObject:nil waitUntilDone:NO];
        return;
    }
    if(![self isAnimating])
        return;
    animationCount_ = 0;
    flipState = kFlipStopAnimating;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkFlipDirectionState) object:nil];
    
    [self checkFlipDirectionState];
    
}

#pragma mark - CAAnimation delegate callbacks

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
{
	[self performSelectorOnMainThread:@selector(checkFlipDirectionState) withObject:nil waitUntilDone:NO];
}


- (void)moveObjectsInArray{
        id obj = [colorsArray objectAtIndex:0];
        [colorsArray removeObjectAtIndex:0];
        [colorsArray addObject:obj];
}


@end
