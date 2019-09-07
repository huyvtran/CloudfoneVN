//
//  IntroduceViewController.m
//  linphone
//
//  Created by Apple on 4/28/17.
//
//

#import "IntroduceViewController.h"

@interface IntroduceViewController ()<UIWebViewDelegate>
@end

@implementation IntroduceViewController
@synthesize _wvIntroduce, icWaiting;

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    [self autoLayoutForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = FALSE;
    self.title = [[AppDelegate sharedInstance].localization localizedStringForKey:@"Introduction"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    NSURL *nsurl=[NSURL URLWithString: link_introduce];
    NSURLRequest *nsrequest = [NSURLRequest requestWithURL: nsurl];
    [_wvIntroduce loadRequest:nsrequest];
    
    icWaiting.hidden = NO;
    [icWaiting startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - my functions

//  setup ui trong view
- (void)autoLayoutForView
{
    float tmpMargin = 10.0;
    [_wvIntroduce mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.view).offset(tmpMargin);
        make.bottom.right.equalTo(self.view).offset(-tmpMargin);
    }];
    _wvIntroduce.layer.borderColor = GRAY_200.CGColor;
    _wvIntroduce.layer.borderWidth = 1.0;
    _wvIntroduce.layer.cornerRadius = 5.0;
    _wvIntroduce.backgroundColor = [UIColor whiteColor];
    _wvIntroduce.clipsToBounds = YES;
    _wvIntroduce.delegate = self;
    
    //  waiting loading
    [icWaiting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_wvIntroduce.mas_centerX);
        make.centerY.equalTo(_wvIntroduce.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
}

#pragma mark - Webview delegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return TRUE;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView.loading) {
        return;
    }
    if ([[webView stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"])
    {
        if ([[webView.request.URL absoluteString] isEqualToString: link_introduce]) {
            _wvIntroduce.hidden = FALSE;
            icWaiting.hidden = TRUE;
            [icWaiting stopAnimating];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"KL didFail: %@; stillLoading: %@", [[webView request]URL],
          (webView.loading?@"YES":@"NO"));
}

@end
