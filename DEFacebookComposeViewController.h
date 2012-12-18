//
//  DETwitterComposeViewController.h
//  DETwitter
//
//  Copyright (c) 2011-2012 Double Encore, Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer 
//  in the documentation and/or other materials provided with the distribution. Neither the name of the Double Encore Inc. nor the names of its 
//  contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
//  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

//  RENAMED to
//  DEFacebookComposeViewController.h
//  DEFacebook
//
//  Modified by Vladmir on 03/09/2012.
//  www.developers-life.com

////
// SAMPLE IMPLEMENTATION + FLOW:
//
// -Create instance with initWithDelegate
// -When the view is created, this asks its delegate whether a FB session is open
// --If so, Post button is displayed
// --If not, Log In button is displayed
// -User presses Post or Log In: an activity indicator is shown and an appropriate delegate method is called
// -The object completing the Facebook operation should, upon completion of the operation, send the notification:
//    DEFacebookComposeViewControllerDelegateDidFinishFBOperation
//  to the default center. This signals the VC to update the view accordingly.
// (-If the user just logged in, they are presented with a Post button which allows them to post.)
//
// NOTE: It is recommended to immediately dismiss this view, if displayed modally, once all Facebook operations
// successfully finish.
////

@class DEFacebookComposeViewController;
@protocol DEFacebookComposeViewControllerDelegate <NSObject>

- (BOOL)isFacebookSessionOpen;
- (void)facebookComposeControllerDidStartLogin:(DEFacebookComposeViewController *)controller;
- (void)facebookComposeController:(DEFacebookComposeViewController *)controller didPostText:(NSString *)text;

@end

extern NSString *const DEFacebookComposeViewControllerDelegateDidFinishFBOperation; // clears activity indicator, etc


@interface DEFacebookComposeViewController : UIViewController

@property(nonatomic,unsafe_unretained) id<DEFacebookComposeViewControllerDelegate> delegate;

- (id)initWithDelegate:(id<DEFacebookComposeViewControllerDelegate>)aDelegate; // initializer you probably want to use
- (id)initWithUrlSchemeSuffix:(NSString *)urlSchemeSuffix; // Adds url scheme suffix for DEFacebookComposeViewController
- (id)initWithDelegate:(id<DEFacebookComposeViewControllerDelegate>)aDelegate urlSchemeSuffix:(NSString *)urlSchemeSuffix;

// Sets the initial text to be tweeted. Returns NO if the specified text will
// not fit within the character space currently available, or if the sheet
// has already been presented to the user.
- (BOOL)setInitialText:(NSString *)text;

// Adds an image to the tweet. Returns NO if the additional image will not fit
// within the character space currently available, or if the sheet has already
// been presented to the user.
- (BOOL)addImage:(UIImage *)image;

// Removes all images from the tweet. Returns NO and does not perform an operation
// if the sheet has already been presented to the user.
- (BOOL)removeAllImages;

@end
