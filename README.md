## GmailLikeLoading ##

Gmail iOS app like Loading view. 

Completely created using core animation.

Easy to drop into your project like a UIView.

You can resize the frame to whatever size.

## Blog

[https://www.built.io/blog/2013/02/gmaillikeloading/] (https://www.built.io/blog/2013/02/gmaillikeloading/ "https://www.built.io/blog/2013/02/gmaillikeloading/")

## How to use ##
	
Drag GmailLikeLoadingView.h amd GmailLikeLoadingView.m files to your project.

Required framework: QuartzCore.framework

	#import "GmailLikeLoadingView.h"

	GmailLikeLoadingView *loadingView = [[GmailLikeLoadingView alloc] initWithFrame:CGRectMake(x, y, width, height)];

	[self addSubview:loadingView];

	[loadingView startAnimating];

### To stop animating: ###

	[loadingView stopAnimating];

### To Check view is animating: ###

	[loadingView isAnimating];


## How it looks ##

![GmailLikeLoading] (https://github.com/raweng/gmail-like-loading/blob/master/GmailLikeLoading.gif)

## Lincense ##

[MIT License] (http://raweng.mit-license.org/ "MIT License")
