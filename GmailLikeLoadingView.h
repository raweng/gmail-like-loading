//
//  ActivityIndicatorView.h
//  ActivityIndicator
//
//  Created by Nikhil Gohil on 27/12/12.
//  Copyright (c) 2012 Nikhil Gohil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GmailLikeLoadingView : UIView
-(void)startAnimating;
-(void)stopAnimating;
@property (nonatomic) BOOL isAnimating;

@end
