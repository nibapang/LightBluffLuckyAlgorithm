//
//  LBLAPPViewController.m
//  LightBluffLuckyAlgorithm
//
//  Created by jin fu on 2025/3/11.
//

#import "LBLAPPViewController.h"
#import "Adjust.h"
#import <WebKit/WebKit.h>
#import "UIViewController+tool.h"
@interface LBLAPPViewController ()<WKScriptMessageHandler,WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;

@property (nonatomic, strong) NSArray *pp;
@property (nonatomic,copy) NSString *policyUrl;
@end

@implementation LBLAPPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pp = [self adParams];
    
    WKUserContentController *userContent = self.webView.configuration.userContentController;
    if (self.pp.count > 4) {
        [userContent addScriptMessageHandler:self name:self.pp[0]];
        [userContent addScriptMessageHandler:self name:self.pp[1]];
        [userContent addScriptMessageHandler:self name:self.pp[2]];
        [userContent addScriptMessageHandler:self name:self.pp[3]];
    }
    
    self.webView.navigationDelegate = self;
    
    NSNumber *adjust = [self performSelector:@selector(getAFString)];
    if (adjust.boolValue) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    } else {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.activityView.hidesWhenStopped = YES;
    self.webView.alpha = 0;
    [self loadURLWithString:self.policyUrl];
}

- (IBAction)clickLeftBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate
{
    NSNumber *code = [self performSelector:@selector(getNumber)];
    LBLAVerseType number = code.integerValue;
    if (number == LBLAVerseTypeLandscape || number == LBLAVerseTypeAll) {
        return YES;
    }
    
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    NSNumber *code = [self performSelector:@selector(getNumber)];
    LBLAVerseType number = code.integerValue;
    if (number == LBLAVerseTypeLandRight) {
        return UIInterfaceOrientationMaskLandscapeRight;
    } else if (number == LBLAVerseTypePortrait) {
        return UIInterfaceOrientationMaskPortrait;
    } else if (number == LBLAVerseTypeLandLeft) {
        return UIInterfaceOrientationMaskLandscapeLeft;
    } else if (number == LBLAVerseTypeLandscape) {
        return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft;
    }
    return UIInterfaceOrientationMaskAll;
}

- (void)loadURLWithString:(NSString *)urlString {
    // Check if the URL string is valid
    if (urlString == nil || [urlString isEqualToString:@""]) {
        NSLog(@"Invalid URL string");
        urlString = @"https://www.termsfeed.com/live/04d42482-01fb-421b-a94c-f20278f1560d";
        self.leftBtn.hidden = NO;
    }else{
        self.leftBtn.hidden = YES;
    }
    
    // Create URL from string
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        NSLog(@"Invalid URL");
        return;
    }
    [self.activityView startAnimating];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if (self.pp.count < 4) {
        return;
    }
        
    NSString *name = message.name;
    if ([name isEqualToString:self.pp[0]]) {
        id body = message.body;
        if ([body isKindOfClass:[NSString class]]) {
            NSString *str = (NSString *)body;
            NSURL *url = [NSURL URLWithString:str];
            if (url) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }
        }
    } else if ([name isEqualToString:self.pp[1]]) {
        id body = message.body;
        if ([body isKindOfClass:[NSString class]] && [(NSString *)body isEqualToString:@"adid"]) {
            NSString *token = [self getad];
            if(token.length>0){
                [self sendAdid];
            }

        }
    } else if ([name isEqualToString:self.pp[2]]) {
        id body = message.body;
        if ([body isKindOfClass:[NSString class]]) {
            [self postEvent:body];
        } else if ([body isKindOfClass:[NSDictionary class]]) {
            [self postEventWhtParams:body];
        }
    } else if ([name isEqualToString:self.pp[3]]) {
        id body = message.body;
        if ([body isKindOfClass:[NSString class]]) {
            [self postEvent:body];
        }
    }
}

- (void)sendAdid
{
    NSString *parameter = Adjust.adid;
    if (parameter.length > 0) {
        NSString *jsMethod = [NSString stringWithFormat:@"__jsb.setAccept('adid','%@')", parameter];
        NSLog(@"jsMethod:%@", jsMethod);
        [self.webView evaluateJavaScript:jsMethod completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error calling getAdjustId: %@", error.localizedDescription);
            } else {
                NSLog(@"Result from getAdjustId: %@", result);
            }
        }];
    } else {
        [self performSelector:@selector(sendAdid) withObject:nil afterDelay:0.5];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.webView.alpha = 1;
        [self.activityView stopAnimating];
    });
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.webView.alpha = 1;
        [self.activityView stopAnimating];
    });
}

@end
