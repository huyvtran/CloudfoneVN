//
//  AppTabbarViewController.m
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "AppTabbarViewController.h"
#import "CallsHistoryViewController.h"
#import "ContactsListViewController.h"
#import "DialerViewController.h"
#import "MoreViewController.h"

@interface AppTabbarViewController (){
    AppDelegate *appDelegate;
    UIColor *actColor;
    
    UITabBarItem *historyItem;
    CallsHistoryViewController *historyVC;
    DialerViewController *dialerVC;
    ContactsListViewController *contactsVC;
    MoreViewController *moreVC;
}
@end

@implementation AppTabbarViewController
@synthesize tabBarController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    actColor = [UIColor colorWithRed:(58/255.0) green:(75/255.0) blue:(101/255.0) alpha:1.0];
    
    tabBarController = [[UITabBarController alloc] init];
    
    // Do any additional setup after loading the view.
    [self setupUIForView];
    
    
    //  Tabbar history
    UIFont *itemFont = [UIFont fontWithName:@"HelveticaNeue" size:12.5];
    if (IS_IPHONE || IS_IPOD) {
        if (SCREEN_WIDTH >= SCREEN_WIDTH_IPHONE_6PLUS) {
            itemFont = [UIFont fontWithName:@"HelveticaNeue" size:15];
        }
    }else{
        itemFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    }
    
    historyVC = [[CallsHistoryViewController alloc] initWithNibName:@"CallsHistoryViewController" bundle:nil];
    UINavigationController *historyNav = [[UINavigationController alloc] initWithRootViewController: historyVC];
    
    UIImage *imgHistory = [UIImage imageNamed:@"history_menu_def"];
    imgHistory = [imgHistory imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *imgHistoryAct = [UIImage imageNamed:@"history_menu_act"];
    imgHistoryAct = [imgHistoryAct imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    historyItem = [[UITabBarItem alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"History"] image:imgHistory selectedImage:imgHistoryAct];
    [historyItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [historyItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_DEFAULT_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    [historyItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_ACTIVE_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    historyNav.tabBarItem = historyItem;
    
    //  Tabbar contacts
    contactsVC = [[ContactsListViewController alloc] initWithNibName:@"ContactsListViewController" bundle:nil];
    UINavigationController *contactsNav = [[UINavigationController alloc] initWithRootViewController: contactsVC];
    
    UIImage *imgContacts = [UIImage imageNamed:@"contacts_menu_def"];
    imgContacts = [imgContacts imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *imgContactsAct = [UIImage imageNamed:@"contacts_menu_act"];
    imgContactsAct = [imgContactsAct imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *contactsItem = [[UITabBarItem alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Contacts"] image:imgContacts selectedImage:imgContactsAct];
    [contactsItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [contactsItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_DEFAULT_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    [contactsItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_ACTIVE_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    contactsNav.tabBarItem = contactsItem;
    
    //  Tabbar Dialer
    dialerVC = [[DialerViewController alloc] initWithNibName:@"DialerViewController" bundle:nil];
    UINavigationController *dialerNav = [[UINavigationController alloc] initWithRootViewController: dialerVC];
    
    UIImage *imgDialer = [UIImage imageNamed:@"dialer_menu_def"];
    imgDialer = [imgDialer imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *imgDialerAct = [UIImage imageNamed:@"dialer_menu_act"];
    imgDialerAct = [imgDialerAct imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *dialerItem = [[UITabBarItem alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Dialer"] image:imgDialer selectedImage:imgDialerAct];
    [dialerItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [dialerItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_DEFAULT_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    [dialerItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_ACTIVE_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    dialerNav.tabBarItem = dialerItem;
    
    //  Tabbar More
    moreVC = [[MoreViewController alloc] initWithNibName:@"MoreViewController" bundle:nil];
    UINavigationController *moreNav = [[UINavigationController alloc] initWithRootViewController: moreVC];
    
    UIImage *imgMore = [UIImage imageNamed:@"more_menu_def"];
    imgMore = [imgMore imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *imgMoreAct = [UIImage imageNamed:@"more_menu_act"];
    imgMoreAct = [imgMoreAct imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *moreItem = [[UITabBarItem alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"More"] image:imgMore selectedImage:imgMoreAct];
    [moreItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [moreItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_DEFAULT_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateNormal];
    [moreItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: MENU_ACTIVE_COLOR, NSForegroundColorAttributeName, itemFont, NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    moreNav.tabBarItem = moreItem;
    
    //  tabBarController.viewControllers = @[homeNav, boNav , transHisNav, moreNav];
    tabBarController.viewControllers = @[historyNav, contactsNav, dialerNav, moreNav];
    [self.view addSubview: tabBarController.view];
    
//    UIView *lbTop = [[UILabel alloc] init];
//    lbTop.backgroundColor = BORDER_COLOR;
//    lbTop.hidden = TRUE;
//    [tabBarController.view addSubview: lbTop];
//    [lbTop mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(tabBarController.view);
//        make.bottom.equalTo(tabBarController.view).offset(-tabBarController.tabBar.frame.size.height);
//        make.height.mas_equalTo(1.0);
//    }];
    
    tabBarController.selectedIndex = 2;
    
    [self updateNumBadgeForMissedCall];
    [self registerObservers];
}

- (void)setupUIForView {
    tabBarController.tabBar.tintColor = [UIColor colorWithRed:(58/255.0) green:(75/255.0) blue:(101/255.0) alpha:1.0];
    tabBarController.tabBar.barTintColor = UIColor.whiteColor;
    tabBarController.tabBar.backgroundColor = UIColor.whiteColor;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    appDelegate.hNav = dialerVC.navigationController.navigationBar.frame.size.height;
}

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNumBadgeForMissedCall)
                                                 name:updateMissedCallBadge object:nil];
}

- (void)updateNumBadgeForMissedCall {
    if ([AppUtil isNullOrEmpty: USERNAME] || [AppUtil isNullOrEmpty: PASSWORD]) {
        historyItem.badgeValue = nil;
        return;
    }
    int missedCall = [DatabaseUtil getUnreadMissedCallHisotryWithAccount: USERNAME];
    if (missedCall > 0) {
        historyItem.badgeValue = [NSString stringWithFormat:@"%d", missedCall];
    }else {
        historyItem.badgeValue = nil;
    }
}

@end
