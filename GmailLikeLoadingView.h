//
//  ActivityIndicatorView.h
//  ActivityIndicator
//
//  Created by Nikhil Gohil on 27/12/12.
//  Copyright (c) 2012 Nikhil Gohil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GmailLikeLoadingView : UIView {
    NSInteger animationCount_;
}
-(void)startAnimating;
-(void)stopAnimating;
-(void)allStop;
-(BOOL)isAnimating;
@end
