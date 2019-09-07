//
//  CallsHistoryViewController.m
//  linphone
//
//  Created by Ei Captain on 7/5/16.
//
//

#import "CallsHistoryViewController.h"
#import "AllCallsViewController.h"
#import "MissedCallViewController.h"

@interface CallsHistoryViewController () {
    AppDelegate *appDelegate;
    int currentView;
    AllCallsViewController *allCallsVC;
    MissedCallViewController *missedCallsVC;
    float hBTN;
}

@end

@implementation CallsHistoryViewController
@synthesize _viewHeader, _btnEdit, _iconAll, _iconMissed, bgHeader;
@synthesize _pageViewController, _vcIndex;

#pragma mark - My controller
- (void)viewDidLoad {
    [super viewDidLoad];
    //  Sau khi xoá tất cả các cuộc gọi
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUIForView)
//                                                 name:k11ReloadAfterDeleteAllCall object:nil];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //  Cập nhật nhãn delete khi xoá lịch sử cuộc gọi
    self.view.backgroundColor = UIColor.clearColor;
    
    [self autoLayoutForView];
    currentView = eAllCalls;
    [self updateStateIconWithView: currentView];
    
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    
    _pageViewController.view.backgroundColor = UIColor.clearColor;
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    allCallsVC = [[AllCallsViewController alloc] init];
    missedCallsVC = [[MissedCallViewController alloc] init];
    
    NSArray *viewControllers = [NSArray arrayWithObject:allCallsVC];
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:false
                                 completion:nil];
    _pageViewController.view.layer.shadowColor = UIColor.clearColor.CGColor;
    _pageViewController.view.layer.borderWidth = 0;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    [_pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = TRUE;
    
    _btnEdit.tag = 0;
    [self showContentWithCurrentLanguage];
    
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = NO;
    
    //  Reset lại các UI khi vào màn hình
    [self resetUIForView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [AppUtil addCornerRadiusTopLeftAndBottomLeftForButton:_iconAll radius:hBTN/2
                                                withColor:SELECT_TAB_BG_COLOR border:2.0];
    
    [AppUtil addCornerRadiusTopRightAndBottomRightForButton:_iconMissed radius:hBTN/2
                                                  withColor:SELECT_TAB_BG_COLOR border:2.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconAllClicked:(id)sender {
    if (currentView == eAllCalls) {
        return;
    }
    
    currentView = eAllCalls;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers:@[allCallsVC]
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:false completion:nil];
}

- (IBAction)_iconMissedClicked:(id)sender {
    if (currentView == eMissedCalls) {
        return;
    }
    
    currentView = eMissedCalls;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers: @[missedCallsVC]
                                  direction: UIPageViewControllerNavigationDirectionReverse
                                   animated: false completion: nil];
}

- (IBAction)_btnEditPressed:(id)sender {
    if (_btnEdit.tag == 0) {
        _btnEdit.tag = 1;
        [_btnEdit setImage:[UIImage imageNamed:@"ic_tick"] forState:UIControlStateNormal];
    }else{
        _btnEdit.tag = 0;
        [_btnEdit setImage:[UIImage imageNamed:@"ic_trash"] forState:UIControlStateNormal];
    }
    
    if (currentView == eAllCalls) {
        [allCallsVC showDeleteCallHistoryWithTag: (int)_btnEdit.tag];
    }else{
        [missedCallsVC showDeleteCallHistoryWithTag: (int)_btnEdit.tag];
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:deleteHistoryCallsChoosed
//                                                        object:[NSNumber numberWithInt:(int)_btnEdit.tag]];
}

#pragma mark – UIPageViewControllerDelegate Method

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (viewController == allCallsVC) {
        currentView = eAllCalls;
        [self updateStateIconWithView: currentView];
        return nil;
    }else{
        currentView = eMissedCalls;
        [self updateStateIconWithView: currentView];
        return allCallsVC;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (viewController == allCallsVC) {
        currentView = eAllCalls;
        [self updateStateIconWithView: currentView];
        return missedCallsVC;
    }else{
        currentView = eMissedCalls;
        [self updateStateIconWithView: currentView];
        return nil;
    }
}

#pragma mark - My functions

- (void)showContentWithCurrentLanguage {
    [_iconAll setTitle:[appDelegate.localization localizedStringForKey:@"All"] forState:UIControlStateNormal];
    [_iconMissed setTitle:[appDelegate.localization localizedStringForKey:@"Missed"] forState:UIControlStateNormal];
}

//  Reset lại các UI khi vào màn hình
- (void)resetUIForView {
    _btnEdit.hidden = NO;
    _iconAll.hidden = NO;
    _iconMissed.hidden = NO;
}

//  Cập nhật trạng thái của các icon trên header
- (void)updateStateIconWithView: (int)view
{
    if (view == eAllCalls){
        [AppUtil setSelected: YES forButton: _iconAll];
        [AppUtil setSelected: NO forButton: _iconMissed];
    }else{
        [AppUtil setSelected: NO forButton: _iconAll];
        [AppUtil setSelected: YES forButton: _iconMissed];
    }
}


//  setup trạng thái cho các button
- (void)autoLayoutForView {
    float hHeader = appDelegate.hStatus + appDelegate.hNav;
    hBTN = 35.0;
    
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    float originY = appDelegate.hStatus + (appDelegate.hNav - hBTN)/2;
    
    _iconAll.backgroundColor = [UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0];
    [_iconAll setTitle:[appDelegate.localization localizedStringForKey:@"All"]
              forState:UIControlStateNormal];
    [_iconAll setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_iconAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset(originY);
        make.right.equalTo(_viewHeader.mas_centerX);
        make.height.mas_equalTo(hBTN);
        make.width.mas_equalTo(SCREEN_WIDTH/4);
    }];
    
    _iconMissed.backgroundColor = UIColor.clearColor;
    [_iconMissed setTitle:[appDelegate.localization localizedStringForKey:@"Missed"] forState:UIControlStateNormal];
    [_iconMissed setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_iconMissed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader.mas_centerX);
        make.top.bottom.equalTo(_iconAll);
        make.width.equalTo(_iconAll.mas_width);
    }];
    
    _btnEdit.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [_btnEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_viewHeader.mas_right).offset(-5);
        make.centerY.equalTo(_iconAll.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
}

@end
