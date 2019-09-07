//
//  AboutViewController.m
//  linphone
//
//  Created by lam quang quan on 10/26/18.
//

#import "AboutViewController.h"

@interface AboutViewController (){
    NSString *linkToAppStore;
    NSString* appStoreVersion;
}
@end

@implementation AboutViewController
@synthesize imgAppLogo, lbVersion, btnCheckForUpdate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = FALSE;
    self.title = [[AppDelegate sharedInstance].localization localizedStringForKey:@"About"];
    
    linkToAppStore = @"";
    
    [btnCheckForUpdate setTitle:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Check for update"] forState:UIControlStateNormal];
    
    NSString *str = [NSString stringWithFormat:@"%@: %@\n%@: %@", [[AppDelegate sharedInstance].localization localizedStringForKey:@"Version"], [AppUtil getAppVersionWithBuildVersion: YES], [[AppDelegate sharedInstance].localization localizedStringForKey:@"Release date"], [AppUtil getBuildDateWithTime: FALSE]];
    lbVersion.text = str;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCheckForUpdatePress:(UIButton *)sender {
    if (![DeviceUtil checkNetworkAvailable]) {
        [self.view makeToast:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Please check your internet connection!"] duration:1.5 position:CSToastPositionBottom style:nil];
        return;
    }
    
    [ProgressHUD backgroundColor: ProgressHUD_BG];
    [ProgressHUD show:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Checking..."] Interaction:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString* appID = infoDictionary[@"CFBundleIdentifier"];
        if (appID.length > 0) {
            NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", appID]];
            NSData* data = [NSData dataWithContentsOfURL:url];
            
            if (data) {
                NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if ([lookup[@"resultCount"] integerValue] == 1){
                    appStoreVersion = lookup[@"results"][0][@"version"];
                    NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
                    
                    if ([appStoreVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
                        // app needs to be updated
                        linkToAppStore = lookup[@"results"][0][@"trackViewUrl"] ? lookup[@"results"][0][@"trackViewUrl"] : @"";
                    }
                }
            }
        }
        
        if (![AppUtil isNullOrEmpty: linkToAppStore] && ![AppUtil isNullOrEmpty: appStoreVersion])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressHUD dismiss];
                
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                NSString *content = [NSString stringWithFormat:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Current version on App Store is %@. Do you want to update right now?"], appStoreVersion];
                
                NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:content];
                [attrTitle addAttribute:NSFontAttributeName value:[AppDelegate sharedInstance].fontNormal range:NSMakeRange(0, attrTitle.string.length)];
                [alertVC setValue:attrTitle forKey:@"attributedTitle"];
                
                UIAlertAction *btnClose = [UIAlertAction actionWithTitle:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Close"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
                [btnClose setValue:UIColor.redColor forKey:@"titleTextColor"];
                
                UIAlertAction *btnUpdate = [UIAlertAction actionWithTitle:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Update"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkToAppStore] options:[[NSDictionary alloc] init] completionHandler:nil];
                }];
                [btnUpdate setValue:BLUE_COLOR forKey:@"titleTextColor"];
                [alertVC addAction:btnClose];
                [alertVC addAction:btnUpdate];
                [self presentViewController:alertVC animated:YES completion:nil];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressHUD dismiss];
                
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:[[AppDelegate sharedInstance].localization localizedStringForKey:@"You are using the newest version"]];
                [attrTitle addAttribute:NSFontAttributeName value:[AppDelegate sharedInstance].fontNormal range:NSMakeRange(0, attrTitle.string.length)];
                [alertVC setValue:attrTitle forKey:@"attributedTitle"];
                
                UIAlertAction *btnClose = [UIAlertAction actionWithTitle:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Close"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
                [btnClose setValue:UIColor.redColor forKey:@"titleTextColor"];
                [alertVC addAction:btnClose];
                [self presentViewController:alertVC animated:YES completion:nil];
            });
        }
    });
}

//  setup ui trong view
- (void)setupUIForView
{
    float hBTN = 45.0;
    
    imgAppLogo.clipsToBounds = TRUE;
    imgAppLogo.layer.cornerRadius = 10.0;
    [imgAppLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view).offset(30.0);
        make.width.height.mas_equalTo(120.0);
    }];
    
    [lbVersion mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAppLogo.mas_bottom).offset(40.0);
        make.left.equalTo(self.view).offset(20.0);
        make.right.equalTo(self.view).offset(-20.0);
        make.height.mas_lessThanOrEqualTo(100.0);
    }];
    
    btnCheckForUpdate.titleLabel.font = [AppDelegate sharedInstance].fontNormal;
    [btnCheckForUpdate setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnCheckForUpdate.clipsToBounds = YES;
    btnCheckForUpdate.layer.cornerRadius = hBTN/2;
    [btnCheckForUpdate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbVersion.mas_bottom).offset(40.0);
        make.left.equalTo(lbVersion.mas_left);
        make.right.equalTo(lbVersion.mas_right);
        make.height.mas_equalTo(hBTN);
    }];
}

@end
