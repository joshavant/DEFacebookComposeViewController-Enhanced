//
//  DEFacebookComposeViewController.m
//  DEFacebooker
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
//  DEFacebookComposeViewController.m
//  DEFacebook
//
//  Modified by Vladmir on 03/09/2012.
//  www.developers-life.com


#import "DEFacebookComposeViewController.h"
#import "DEFacebookSheetCardView.h"
#import "DEFacebookTextView.h"
#import "DEFacebookGradientView.h"
#import "UIDevice+DEFacebookComposeViewController.h"
#import <QuartzCore/QuartzCore.h>

#import <Social/Social.h>

static BOOL waitingForAccess = NO;

NSString *const DEFacebookComposeViewControllerDelegateDidFinishFBOperation = @"DEFacebookComposeViewControllerDelegateDidFinishFBOperation";


@interface DEFacebookComposeViewController () <UITextViewDelegate, UIAlertViewDelegate,
UIPopoverControllerDelegate>

@property (strong, nonatomic) IBOutlet DEFacebookSheetCardView *cardView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIView *cardHeaderLineView;
@property (strong, nonatomic) IBOutlet DEFacebookTextView *textView;
@property (strong, nonatomic) IBOutlet UIView *textViewContainer;
@property (strong, nonatomic) IBOutlet UIImageView *paperClipView;
@property (strong, nonatomic) IBOutlet UIImageView *attachment1FrameView;
@property (strong, nonatomic) IBOutlet UIImageView *attachment2FrameView;
@property (strong, nonatomic) IBOutlet UIImageView *attachment3FrameView;
@property (strong, nonatomic) IBOutlet UIImageView *attachment1ImageView;
@property (strong, nonatomic) IBOutlet UIImageView *attachment2ImageView;
@property (strong, nonatomic) IBOutlet UIImageView *attachment3ImageView;
@property (strong, nonatomic) IBOutlet UILabel *characterCountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *navImage;


@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *urls;
@property (nonatomic, strong) NSArray *attachmentFrameViews;
@property (nonatomic, strong) NSArray *attachmentImageViews;
@property (nonatomic) UIStatusBarStyle previousStatusBarStyle;
@property (nonatomic, weak) UIViewController *fromViewController;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) DEFacebookGradientView *gradientView;
@property (nonatomic, strong) UIPickerView *accountPickerView;
@property (nonatomic, strong) UIPopoverController *accountPickerPopoverController;
@property (strong, nonatomic) NSString *urlSchemeSuffix;


- (void)facebookComposeViewControllerInit;
- (void)updateFramesForOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)isPresented;
- (NSInteger)attachmentsCount;
- (void)updateAttachments;

- (void)updateView;

- (IBAction)send;
- (IBAction)cancel;

@end


@implementation DEFacebookComposeViewController

    // IBOutlets
@synthesize cardView = _cardView;
@synthesize titleLabel = _titleLabel;
@synthesize cancelButton = _cancelButton;
@synthesize sendButton = _sendButton;
@synthesize cardHeaderLineView = _cardHeaderLineView;
@synthesize textView = _textView;
@synthesize textViewContainer = _textViewContainer;
@synthesize paperClipView = _paperClipView;
@synthesize attachment1FrameView = _attachment1FrameView;
@synthesize attachment2FrameView = _attachment2FrameView;
@synthesize attachment3FrameView = _attachment3FrameView;
@synthesize attachment1ImageView = _attachment1ImageView;
@synthesize attachment2ImageView = _attachment2ImageView;
@synthesize attachment3ImageView = _attachment3ImageView;
@synthesize characterCountLabel = _characterCountLabel;

    // Public
@synthesize delegate;

    // Private
@synthesize text = _text;
@synthesize images = _images;
@synthesize urls = _urls;
@synthesize attachmentFrameViews = _attachmentFrameViews;
@synthesize attachmentImageViews = _attachmentImageViews;
@synthesize previousStatusBarStyle = _previousStatusBarStyle;
@synthesize fromViewController = _fromViewController;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize gradientView = _gradientView;
@synthesize accountPickerView = _accountPickerView;
@synthesize accountPickerPopoverController = _accountPickerPopoverController;

@synthesize navImage = _navImage;

enum {
    DEFacebookComposeViewControllerNoAccountsAlert = 1,
    DEFacebookComposeViewControllerCannotSendAlert
};

#define degreesToRadians(x) (M_PI * x / 180.0f)


#pragma mark - Class Methods


#pragma mark - Setup & Teardown

- (id)initWithDelegate:(id<DEFacebookComposeViewControllerDelegate>)aDelegate
{
    return [self initWithDelegate:aDelegate urlSchemeSuffix:nil];
}

- (id)initWithUrlSchemeSuffix:(NSString *)urlSchemeSuffix
{
    
    return [self initWithDelegate:nil urlSchemeSuffix:urlSchemeSuffix];
}

- (id)initWithDelegate:(id<DEFacebookComposeViewControllerDelegate>)aDelegate urlSchemeSuffix:(NSString *)urlSchemeSuffix
{
    self = [super init];
    if (self) {
        [self facebookComposeViewControllerInit];
        self.urlSchemeSuffix = urlSchemeSuffix;
        self.delegate = aDelegate;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateView)
                                                     name:DEFacebookComposeViewControllerDelegateDidFinishFBOperation
                                                   object:nil];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self facebookComposeViewControllerInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self facebookComposeViewControllerInit];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DEFacebookComposeViewControllerDelegateDidFinishFBOperation
                                                  object:nil];
}


- (void)facebookComposeViewControllerInit
{
    _images = [[NSMutableArray alloc] init];
    _urls = [[NSMutableArray alloc] init];
}

#pragma mark - Superclass Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setCancelButtonTitle:NSLocalizedString(@"Cancel",@"")];
    [self setSendButtonTitle:NSLocalizedString(@"Post",@"")];

    self.view.backgroundColor = [UIColor clearColor];
    self.textViewContainer.backgroundColor = [UIColor clearColor];
    self.textView.backgroundColor = [UIColor clearColor];
    
    
    
    if ([UIDevice de_isIOS5]) {
        self.fromViewController = self.presentingViewController;
        self.textView.keyboardType = UIKeyboardTypeTwitter;
    }
    else {
        self.fromViewController = self.parentController;
    }
    
    
    
    
        // Put the attachment frames and image views into arrays so they're easier to work with.
        // Order is important, so we can't use IB object arrays. Or at least this is easier.
    self.attachmentFrameViews = [NSArray arrayWithObjects:
                                 self.attachment1FrameView,
                                 self.attachment2FrameView,
                                 self.attachment3FrameView,
                                 nil];
    
    self.attachmentImageViews = [NSArray arrayWithObjects:
                                 self.attachment1ImageView,
                                 self.attachment2ImageView,
                                 self.attachment3ImageView,
                                 nil];
    
        // Now add some angle to attachments 2 and 3.
    self.attachment2FrameView.transform = CGAffineTransformMakeRotation(degreesToRadians(-6.0f));
    self.attachment2ImageView.transform = CGAffineTransformMakeRotation(degreesToRadians(-6.0f));
    self.attachment3FrameView.transform = CGAffineTransformMakeRotation(degreesToRadians(-12.0f));
    self.attachment3ImageView.transform = CGAffineTransformMakeRotation(degreesToRadians(-12.0f));
    
        // Mask the corners on the image views so they don't stick out of the frame.
    [self.attachmentImageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        ((UIImageView *)obj).layer.cornerRadius = 3.0f;
        ((UIImageView *)obj).layer.masksToBounds = YES;
    }];
    
    self.textView.text = self.text;
    [self.textView becomeFirstResponder];
    
    

    
    
    [self updateAttachments];
    
    [self.navImage setNeedsDisplay];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
        // Now let's fade in a gradient view over the presenting view.
    self.gradientView = [[DEFacebookGradientView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    self.gradientView.autoresizingMask = UIViewAutoresizingNone;
    self.gradientView.transform = self.fromViewController.view.transform;
    self.gradientView.alpha = 0.0f;
    self.gradientView.center = [UIApplication sharedApplication].keyWindow.center;
    [self.fromViewController.view addSubview:self.gradientView];
    [UIView animateWithDuration:0.3f
                     animations:^ {
                         self.gradientView.alpha = 1.0f;
                     }];    
    
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES]; 
    
    [self updateFramesForOrientation:self.interfaceOrientation];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.backgroundImageView.alpha = 1.0f;
    //self.backgroundImageView.frame = [self.view convertRect:self.backgroundImageView.frame fromView:[UIApplication sharedApplication].keyWindow];
    [self.view insertSubview:self.gradientView aboveSubview:self.backgroundImageView];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:self.navImage.bounds
                                                      byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                            cornerRadii:CGSizeMake(13.f, 13.f)];
    [roundedPath closePath];
    maskLayer.path = [roundedPath CGPath];
    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
    maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
    self.navImage.layer.mask = maskLayer;
    [self.navImage setNeedsDisplay];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIView *presentingView = [UIDevice de_isIOS5] ? self.fromViewController.view : self.parentController.view;
    [presentingView addSubview:self.gradientView];
    
    [self.backgroundImageView removeFromSuperview];
    self.backgroundImageView = nil;
    
    [UIView animateWithDuration:0.3f
                     animations:^ {
                         self.gradientView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [self.gradientView removeFromSuperview];
                     }];
    
    [[UIApplication sharedApplication] setStatusBarStyle:self.previousStatusBarStyle animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self.parentController respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)]) {
        return [self.parentController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    
    if ([UIDevice de_isPhone]) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }

    return YES;  // Default for iPad.
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateFramesForOrientation:interfaceOrientation];

    // Our fake background won't rotate properly. Just hide it.
    if (interfaceOrientation == self.presentedViewController.interfaceOrientation) {
        self.backgroundImageView.alpha = 1.0f;
    }
    else {
        self.backgroundImageView.alpha = 0.0f;
    }
}

#pragma mark - Public

- (BOOL)setInitialText:(NSString *)initialText
{
    if ([self isPresented]) {
        return NO;
    }
    
    self.text = initialText;  // Keep a copy in case the view isn't loaded yet.
    self.textView.text = self.text;
    
    return YES;
}


- (BOOL)addImage:(UIImage *)image
{
    [self.images removeAllObjects];
    
    if (image == nil) {
        return NO;
    }
    
    if ([self isPresented]) {
        return NO;
    }
        
    [self.images addObject:image];
    return YES;
}


- (BOOL)addImageWithURL:(NSURL *)url;
    // Not yet impelemented.
{
        // We should probably just start the download, rather than saving the URL.
        // Just save the image once we have it.
    return NO;
}


- (BOOL)removeAllImages
{
    if ([self isPresented]) {
        return NO;
    }
    
    [self.images removeAllObjects];
    return YES;
}

#pragma mark - Private

- (void)updateFramesForOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    CGFloat buttonHorizontalMargin = 8.0f;
    CGFloat cardWidth, cardTop, cardHeight, cardHeaderLineTop, buttonTop;
    UIImage *cancelButtonImage, *sendButtonImage;
    CGFloat titleLabelFontSize, titleLabelTop;
    
    if ([UIDevice de_isPhone]) {
        cardWidth = CGRectGetWidth(self.view.bounds) - 10.0f;
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            cardTop = 25.0f;
            cardHeight = 189.0f;
            buttonTop = 7.0f;
            cancelButtonImage = [[UIImage imageNamed:@"DEFacebookSendButtonPortrait"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            sendButtonImage = [[UIImage imageNamed:@"DEFacebookSendButtonPortrait"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            cardHeaderLineTop = 41.0f;
            titleLabelFontSize = 20.0f;
            titleLabelTop = 9.0f;
        }
        else {
            cardTop = -1.0f;
            cardHeight = 150.0f;
            buttonTop = 6.0f;
            cancelButtonImage = [[UIImage imageNamed:@"DEFacebookSendButtonLandscape"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            sendButtonImage = [[UIImage imageNamed:@"DEFacebookSendButtonLandscape"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
            cardHeaderLineTop = 32.0f;
            titleLabelFontSize = 17.0f;
            titleLabelTop = 5.0f;
        }
    }
    else {  // iPad. Similar to iPhone portrait.
        cardWidth = 543.0f;
        cardHeight = 189.0f;
        buttonTop = 7.0f;
        cancelButtonImage = [[UIImage imageNamed:@"DEFacebookSendButtonPortrait"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
        sendButtonImage = [[UIImage imageNamed:@"DEFacebookSendButtonPortrait"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
        cardHeaderLineTop = 41.0f;
        titleLabelFontSize = 20.0f;
        titleLabelTop = 9.0f;
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            cardTop = 280.0f;
        }
        else {
            cardTop = 110.0f;
        }
    }
    
    CGFloat cardLeft = trunc((CGRectGetWidth(self.view.bounds) - cardWidth) / 2);
    self.cardView.frame = CGRectMake(cardLeft, cardTop, cardWidth, cardHeight);
    
    self.navImage.frame = CGRectMake(0, 0, cardWidth, 44);
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:titleLabelFontSize];
    self.titleLabel.frame = CGRectMake(0.0f, titleLabelTop, cardWidth, self.titleLabel.frame.size.height);
    
    [self.cancelButton setBackgroundImage:cancelButtonImage forState:UIControlStateNormal];
    self.cancelButton.frame = CGRectMake(buttonHorizontalMargin, buttonTop, self.cancelButton.frame.size.width, cancelButtonImage.size.height);
    
    [self.sendButton setBackgroundImage:sendButtonImage forState:UIControlStateNormal];
    self.sendButton.frame = CGRectMake(self.cardView.bounds.size.width - buttonHorizontalMargin - self.sendButton.frame.size.width, buttonTop, self.sendButton.frame.size.width, sendButtonImage.size.height);
    
    self.cardHeaderLineView.frame = CGRectMake(0.0f, cardHeaderLineTop, self.cardView.bounds.size.width, self.cardHeaderLineView.frame.size.height);
    
    CGFloat textWidth = CGRectGetWidth(self.cardView.bounds);
    if ([self attachmentsCount] > 0) {
        textWidth -= CGRectGetWidth(self.attachment1FrameView.frame) + 10.0f;  // Got to measure frame 1, because it's not rotated. Other frames are funky.
    }
    CGFloat textTop = CGRectGetMaxY(self.cardHeaderLineView.frame) - 1.0f;
    
    
    CGFloat textHeight = self.cardView.bounds.size.height - textTop - 30.0f;
    self.textViewContainer.frame = CGRectMake(0.0f, textTop, self.cardView.bounds.size.width, textHeight);
    self.textView.frame = CGRectMake(0.0f, 6.0f, textWidth, self.textViewContainer.frame.size.height-6);
    self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, -(self.cardView.bounds.size.width - textWidth - 1.0f));
    
    self.paperClipView.frame = CGRectMake(CGRectGetMaxX(self.cardView.frame) - self.paperClipView.frame.size.width + 6.0f,
                                          CGRectGetMinY(self.cardView.frame) + CGRectGetMaxY(self.cardHeaderLineView.frame) - 1.0f,
                                          self.paperClipView.frame.size.width,
                                          self.paperClipView.frame.size.height);
    
        // We need to position the rotated views by their center, not their frame.
        // This isn't elegant, but it is correct. Half-points are required because
        // some frame sizes aren't evenly divisible by 2.
    self.attachment1FrameView.center = CGPointMake(self.cardView.bounds.size.width - 45.0f, CGRectGetMaxY(self.paperClipView.frame) - cardTop + 18.0f);
    self.attachment1ImageView.center = CGPointMake(self.cardView.bounds.size.width - 45.5, self.attachment1FrameView.center.y - 2.0f);
    
    self.attachment2FrameView.center = CGPointMake(self.attachment1FrameView.center.x - 4.0f, self.attachment1FrameView.center.y + 5.0f);
    self.attachment2ImageView.center = CGPointMake(self.attachment1ImageView.center.x - 4.0f, self.attachment1ImageView.center.y + 5.0f);
    
    self.attachment3FrameView.center = CGPointMake(self.attachment2FrameView.center.x - 4.0f, self.attachment2FrameView.center.y + 5.0f);
    self.attachment3ImageView.center = CGPointMake(self.attachment2ImageView.center.x - 4.0f, self.attachment2ImageView.center.y + 5.0f);
    
    self.gradientView.frame = self.gradientView.superview.bounds;
    
    if([self.delegate respondsToSelector:@selector(isFacebookSessionOpen)] &&
       ![self.delegate isFacebookSessionOpen]) {
        [self setSendButtonTitle:NSLocalizedString(@"Log in",@"")];
    }
    [self.navImage setNeedsDisplay];
}


- (BOOL)isPresented
{
    return [self isViewLoaded];
}


- (void)updateView
{
    if([self.delegate respondsToSelector:@selector(isFacebookSessionOpen)] &&
       [self.delegate isFacebookSessionOpen])
    {
        [self setSendButtonTitle:NSLocalizedString(@"Post",@"")];
    }
    else if([self.delegate respondsToSelector:@selector(isFacebookSessionOpen)] &&
            ![self.delegate isFacebookSessionOpen])
    {
        [self setSendButtonTitle:NSLocalizedString(@"Log in",@"")];
    }
    
    if(self.view.userInteractionEnabled == NO) { self.view.userInteractionEnabled = YES; }
    if(self.sendButton.enabled == NO) { self.sendButton.enabled = YES; }
    
    if([[[self.sendButton subviews] lastObject] isKindOfClass:[UIActivityIndicatorView class]])
    {
        [[[self.sendButton subviews] lastObject] removeFromSuperview];
    }
}

- (NSInteger)attachmentsCount
{
    return [self.images count] + [self.urls count];
}


- (void)updateAttachments
{
    CGRect frame = self.textView.frame;
    if ([self attachmentsCount] > 0) {
        frame.size.width = self.cardView.frame.size.width - self.attachment1FrameView.frame.size.width;
    }
    else {
        frame.size.width = self.cardView.frame.size.width;
    }
    self.textView.frame = frame;
    
        // Create a array of attachment images to display.
    NSMutableArray *attachmentImages = [NSMutableArray arrayWithArray:self.images];
    for (NSInteger index = 0; index < [self.urls count]; index++) {
        [attachmentImages addObject:[UIImage imageNamed:@"DEFacebookURLAttachment"]];
    }
    
    self.paperClipView.hidden = YES;
    self.attachment1FrameView.hidden = YES;
    self.attachment2FrameView.hidden = YES;
    self.attachment3FrameView.hidden = YES;
    
    if ([attachmentImages count] >= 1) {
        self.paperClipView.hidden = NO;
        self.attachment1FrameView.hidden = NO;
        self.attachment1ImageView.image = [attachmentImages objectAtIndex:0];
        
        if ([attachmentImages count] >= 2) {
            self.paperClipView.hidden = NO;
            self.attachment2FrameView.hidden = NO;
            self.attachment2ImageView.image = [attachmentImages objectAtIndex:1];
            
            if ([attachmentImages count] >= 3) {
                self.paperClipView.hidden = NO;
                self.attachment3FrameView.hidden = NO;
                self.attachment3ImageView.image = [attachmentImages objectAtIndex:2];
            }
        }
    }
}




#pragma mark - Actions

- (IBAction)send
{
    if([self.delegate respondsToSelector:@selector(isFacebookSessionOpen)] &&
       [self.delegate isFacebookSessionOpen])
    {
        if([self.delegate respondsToSelector:@selector(facebookComposeControllerDidStartLogin:)])
        {
            [self.delegate facebookComposeControllerDidStartLogin:self];
        }
    }
    
    
    self.sendButton.enabled = NO;
        
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activity setCenter:CGPointMake(_sendButton.frame.size.width/2, _sendButton.frame.size.height/2)];
    [self setSendButtonTitle:@""];
    [_sendButton addSubview:activity];
    [activity startAnimating];
    self.view.userInteractionEnabled = NO;
}


- (IBAction)cancel
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - UIAlertViewDelegate

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    // Notice this is a class method since we're displaying the alert from a class method.
{
    // no op
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    // This gets called if there's an error sending the tweet.
{
    if (alertView.tag == DEFacebookComposeViewControllerNoAccountsAlert) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else if (alertView.tag == DEFacebookComposeViewControllerCannotSendAlert) {
        if (buttonIndex == 1) {
                // The user wants to try again.
            [self send];
        }
    }
}

#pragma mark - Parent View Controller

- (UIViewController *)parentController
{
    float currentVersion = 5.0;
    float sysVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (sysVersion >= currentVersion) {
        // iOS 5.0 or later version of iOS specific functionality hanled here
        return self.presentingViewController;
    }
    else {
        //Previous than iOS 5.0 specific functionality
        return self.parentViewController;
    }
}


#pragma mark - Button width

- (void)setSendButtonTitle:(NSString *)title
{
    UIButton *button = self.sendButton;
    [button setTitle:title forState:UIControlStateNormal];
    [self autoSizeButton:button right:YES];
}

- (void)setCancelButtonTitle:(NSString *)title
{
    UIButton *button = self.cancelButton;
    [button setTitle:title forState:UIControlStateNormal];
    [self autoSizeButton:button right:NO];
}

- (void)autoSizeButton:(UIButton *)button right:(BOOL)right
{
    NSString *title = button.titleLabel.text;
    
    CGSize s = [title sizeWithFont:button.titleLabel.font];
    s.width += 14.f; // padding
    
    CGRect frame = button.frame;
    CGFloat offset = s.width - frame.size.width;
    
    if (right) frame.origin.x -= offset;
    frame.size.width = s.width;
    button.frame = frame;
}

@end
