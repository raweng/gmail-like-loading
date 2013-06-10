//
//  ActivityIndicatorView.m
//  ActivityIndicator
//
//  Created by Nikhil Gohil on 27/12/12.
//  Copyright (c) 2012 Nikhil Gohil. All rights reserved.
//

#import "GmailLikeLoadingView.h"
#import <QuartzCore/QuartzCore.h>
#define COLOR_MEDIUM_SEA_GREEN [UIColor colorWithRed:0.0/255.0f green:147.0/255.0f blue:78.0/255.0f alpha:1.0]
#define COLOR_MEDUIM_BLUE [UIColor colorWithRed:20.0/255.0f green:99.0/255.0f blue:233.0/255.0 alpha:1.0]
#define COLOR_ORANGE [UIColor colorWithRed:255.0/255.0f green:199.0/255.0f blue:12.0/255.0f alpha:1.0]
#define COLOR_MEDIUM_RED [UIColor colorWithRed:221.0/255.0f green:0.0/255.0f blue:31.0/255.0 alpha:1.0]
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
    NSMutableArray *colorsArray;
}
-(void)animateView;
-(void)arrangeTopFirstAnimation;
-(void)arrangeBottomFirstAnimation;
-(NSArray*)splitViewToImages:(UIView*)view forFlipState:(kFlipDirectionState)flipDirection;
-(BOOL)isBottomFirstAnimation;

@end

@implementation GmailLikeLoadingView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        CGFloat diameter = MIN(self.frame.size.width, self.frame.size.height);
        
        colorsArray = [NSMutableArray arrayWithObjects:COLOR_MEDIUM_SEA_GREEN,COLOR_MEDUIM_BLUE,COLOR_ORANGE,COLOR_MEDIUM_RED, nil];
        
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
	
    [renderedImage drawAtPoint:CGPointZero];
    
    top = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();
    
	UIGraphicsBeginImageContextWithOptions(size, view.layer.opaque, 0.f);
	
    if (flipDirection == kFlipBottomTop || flipDirection == kFlipTopBottom) {
        [renderedImage drawAtPoint:CGPointMake(CGPointZero.x, -renderedImage.size.height / 2)];
    }else{
        [renderedImage drawAtPoint:CGPointMake(-renderedImage.size.width / 2,CGPointZero.y)];
    }
    bottom = UIGraphicsGetImageFromCurrentImageContext();
	
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


-(void)animateView{
    //If bottom first animation, use backLayerView, otherwise use frontLayerView
	NSArray *frontImages = nil;
    if ([self isBottomFirstAnimation]) {
        frontImages = [self splitViewToImages:backLayerView forFlipState:flipState];
    }
    else {
        frontImages = [self splitViewToImages:frontLayerView forFlipState:flipState];
    }
    
    firstHalfFrontLayerView = [frontImages objectAtIndex:0];

	secondHalfFrontLayerView = [frontImages objectAtIndex:1];
    firstHalfFrontLayerView.frame = firstHalfFrontLayerView.bounds;
    [self addSubview:firstHalfFrontLayerView];
    
    if (flipState == kFlipBottomTop || flipState == kFlipTopBottom) {
        secondHalfFrontLayerView.frame = CGRectOffset(firstHalfFrontLayerView.frame, 0.f, firstHalfFrontLayerView.frame.size.height);
    }else{
        secondHalfFrontLayerView.frame = CGRectOffset(firstHalfFrontLayerView.frame, firstHalfFrontLayerView.frame.size.width, 0.f);
    }
    
    [self addSubview:secondHalfFrontLayerView];
   
    
    //If bottom first animation, use frontLayerView, otherwise use backLayerView
	NSArray *backImages = nil;
    if ([self isBottomFirstAnimation]) {
        backImages = [self splitViewToImages:frontLayerView forFlipState:flipState];
    }
    else {
        backImages = [self splitViewToImages:backLayerView forFlipState:flipState];
    }
    
    firstHalfBackLayerView = [backImages objectAtIndex:0];

    secondHalfBackLayerView = [backImages objectAtIndex:1];
    
    firstHalfBackLayerView.frame = firstHalfFrontLayerView.frame;
	[self insertSubview:firstHalfBackLayerView belowSubview:firstHalfFrontLayerView];
    
    secondHalfBackLayerView.frame = secondHalfFrontLayerView.frame;
    
	[self insertSubview:secondHalfBackLayerView belowSubview:secondHalfFrontLayerView];
    
    CGPoint newTopViewAnchorPoint;
    CGPoint newAnchorPointBottomHalf;
    
    if (flipState == kFlipBottomTop || flipState == kFlipTopBottom) {
        newTopViewAnchorPoint = CGPointMake(0.5, 1.0);
        newAnchorPointBottomHalf = CGPointMake(0.5f, 0.f);
    }else{
        newTopViewAnchorPoint = CGPointMake(1.0f, 0.5f);
        newAnchorPointBottomHalf = CGPointMake(0.f,0.5f);
    }
	
	firstHalfFrontLayerView.layer.anchorPoint = newTopViewAnchorPoint;
   
    [firstHalfFrontLayerView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    

    [[firstHalfFrontLayerView layer] setOpacity:1.0f];
    [[firstHalfFrontLayerView layer] setOpaque:YES];
    

    
	secondHalfBackLayerView.layer.anchorPoint = newAnchorPointBottomHalf;
   
    [secondHalfBackLayerView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];

    
    [[secondHalfBackLayerView layer] setOpacity:1.0f];
    [[secondHalfBackLayerView layer] setOpaque:YES];
    
    if ([self isBottomFirstAnimation]) {
        [self arrangeBottomFirstAnimation];
    }
    else {
        [self arrangeTopFirstAnimation];
    }
	    
}

-(BOOL)isBottomFirstAnimation {
    if (flipState == kFlipTopBottom || flipState == kFlipLeftRight) {
        return NO;
    }
    else {
        return YES;
    }
}


-(void)arrangeTopFirstAnimation {
    CATransform3D skewedIdentityTransform = CATransform3DIdentity;
	float zDistance = 1000.000000;
	skewedIdentityTransform.m34 = 1.0 / -zDistance;
    float x,y,z;
    if (flipState == kFlipBottomTop || flipState == kFlipTopBottom) {
        
        x = 1.f;
        y = 0.f;
        z = 0.f;
    }else{
        
        x = 0.f;
        y = 1.f;
        z = 0.f;
    }
    CABasicAnimation *topAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
	topAnim.beginTime = CACurrentMediaTime();
	topAnim.duration = 0.5;
	topAnim.fromValue = [NSValue valueWithCATransform3D:skewedIdentityTransform];
    
    switch (flipState) {
        case kFlipBottomTop:
            topAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, -M_PI_2, x, y, z)];
            break;
        case kFlipTopBottom:
            topAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, -M_PI_2, x, y, z)];
            break;
        case kFlipLeftRight:
            topAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, M_PI_2, x, y, z)];
            break;
        case kFlipRightLeft:
            topAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, M_PI_2, x, y, z)];
            break;
        default:
            break;
    }
    
	topAnim.delegate = nil;
	topAnim.removedOnCompletion = NO;
    
	topAnim.fillMode = kCAFillModeBoth;
	topAnim.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.70 :0.00 :1.00 :1.00];
    [[firstHalfFrontLayerView layer] setOpacity:1];
    [[firstHalfFrontLayerView layer] setOpaque:YES];
	[firstHalfFrontLayerView.layer addAnimation:topAnim forKey:@"topDownFlip"];
    [self bringSubviewToFront:firstHalfFrontLayerView];
    
    CABasicAnimation *bottomAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
	bottomAnim.beginTime = topAnim.beginTime + topAnim.duration;
	bottomAnim.duration = topAnim.duration;
    
    switch (flipState) {
        case kFlipBottomTop:
            bottomAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, M_PI_2, x, y, z)];
            break;
        case kFlipTopBottom:
            bottomAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, M_PI_2, x, y, z)];
            break;
        case kFlipLeftRight:
            bottomAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, -M_PI_2, x, y, z)];
            break;
        case kFlipRightLeft:
            bottomAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, -M_PI_2, x, y, z)];
            break;
        default:
            break;
    }
    
	bottomAnim.toValue = [NSValue valueWithCATransform3D:skewedIdentityTransform];
	bottomAnim.delegate = self;
	bottomAnim.removedOnCompletion = NO;
	bottomAnim.fillMode = kCAFillModeBoth;
	bottomAnim.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.30 :1.00 :1.00 :1.00];
    [[secondHalfBackLayerView layer] setOpacity:1];
    [[secondHalfBackLayerView layer] setOpaque:YES];
	[secondHalfBackLayerView.layer addAnimation:bottomAnim forKey:@"bottomDownFlip"];
    [self bringSubviewToFront:secondHalfBackLayerView];
}

-(void)arrangeBottomFirstAnimation {
    CATransform3D skewedIdentityTransform = CATransform3DIdentity;
	float zDistance = 1000.000000;
	skewedIdentityTransform.m34 = 1.0 / -zDistance;
    float x,y,z;
    if (flipState == kFlipBottomTop || flipState == kFlipTopBottom) {
        
        x = 1.f;
        y = 0.f;
        z = 0.f;
    }else{
        
        x = 0.f;
        y = 1.f;
        z = 0.f;
    }
    
    
    CABasicAnimation *bottomAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
	bottomAnim.beginTime = CACurrentMediaTime();
	bottomAnim.duration = 0.5;
    bottomAnim.fromValue = [NSValue valueWithCATransform3D:skewedIdentityTransform];
    
    switch (flipState) {
        case kFlipBottomTop:
            bottomAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, M_PI_2, x, y, z)];
            break;
        case kFlipTopBottom:
            bottomAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, M_PI_2, x, y, z)];
            break;
        case kFlipLeftRight:
            bottomAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, -M_PI_2, x, y, z)];
            break;
        case kFlipRightLeft:
            bottomAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, -M_PI_2, x, y, z)];
            break;
        default:
            break;
    }
    
	bottomAnim.delegate = nil;
	bottomAnim.removedOnCompletion = NO;
    bottomAnim.fillMode = kCAFillModeForwards;
    
	
    
    bottomAnim.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.70 :0.00 :1.00 :1.00];
    [[secondHalfBackLayerView layer] setOpacity:1];
    [[secondHalfBackLayerView layer] setOpaque:YES];
	[secondHalfBackLayerView.layer addAnimation:bottomAnim forKey:@"bottomDownFlip"];
    [self bringSubviewToFront:secondHalfBackLayerView];
    
    
    
    
    CABasicAnimation *topAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    topAnim.beginTime = bottomAnim.beginTime + bottomAnim.duration;
	topAnim.duration = bottomAnim.duration;
	topAnim.toValue = [NSValue valueWithCATransform3D:skewedIdentityTransform];
    
    switch (flipState) {
        case kFlipBottomTop:
            topAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, -M_PI_2, x, y, z)];
            break;
        case kFlipTopBottom:
            topAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, -M_PI_2, x, y, z)];
            break;
        case kFlipLeftRight:
            topAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, M_PI_2, x, y, z)];
            break;
        case kFlipRightLeft:
            topAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(skewedIdentityTransform, M_PI_2, x, y, z)];
            break;
        default:
            break;
    }
    
	topAnim.delegate = self;
	topAnim.removedOnCompletion = NO;
	//topAnim.fillMode = kCAFillModeForwards;
    topAnim.fillMode = kCAFillModeBoth;
    
    
    topAnim.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.30 :1.00 :1.00 :1.00];
    [[firstHalfFrontLayerView layer] setOpacity:1];
    [[firstHalfFrontLayerView layer] setOpaque:YES];
	[firstHalfFrontLayerView.layer addAnimation:topAnim forKey:@"topDownFlip"];
    
    [self bringSubviewToFront:firstHalfFrontLayerView];


}



-(void)checkFlipDirectionState {
    switch (flipState) {
        case kFlipBottomTop:
        {
            [self animateView];
            previousFlipState = kFlipBottomTop;
            flipState = kFlipStop;
        }
            break;
        case kFlipTopBottom:
        {
			[self animateView];
            previousFlipState = kFlipTopBottom;
            flipState = kFlipStop;
        }
            break;
        case kFlipLeftRight:
        {
            [self animateView];
            previousFlipState = kFlipLeftRight;
            flipState = kFlipStop;
        }
            break;
        case kFlipRightLeft:
        {
            [self animateView];
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
           
            
            
            switch (previousFlipState) {
                case kFlipBottomTop:
                    flipState = kFlipRightLeft;
                    break;
                case kFlipTopBottom:
                    flipState = kFlipLeftRight;
                    break;
                case kFlipLeftRight:
                    flipState = kFlipBottomTop;
                    break;
                case kFlipRightLeft:
                    flipState = kFlipTopBottom;
                    break;
                default:
                    break;
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
        flipState = kFlipTopBottom;
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
