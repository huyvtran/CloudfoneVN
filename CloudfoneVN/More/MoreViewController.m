//
//  MoreViewController.m
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "MoreViewController.h"
#import "AccountSettingsViewController.h"
#import "SettingsViewController.h"
#import "PolicyViewController.h"
#import "IntroduceViewController.h"
#import "SendLogsViewController.h"
#import "AboutViewController.h"
#import "MenuCell.h"

@interface MoreViewController ()<UITableViewDelegate, UITableViewDataSource> {
    AppDelegate *appDelegate;
    NSMutableArray *listTitle;
    NSMutableArray *listIcon;
    float hInfo;
    float hCell;
}

@end

@implementation MoreViewController
@synthesize viewHeader, bgHeader, imgAvatar, lbFullname, lbAccID, icEdit, lbNoAccount, tbContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self autoLayoutForMainView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = TRUE;
    
    [self updateInformationOfUser];
    [tbContent reloadData];
}

//  Cập nhật vị trí cho view
- (void)autoLayoutForMainView {
    self.view.backgroundColor = GRAY_230;
    
    hCell = 60.0;
    if (IS_IPHONE || IS_IPOD) {
        NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
        if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2] || [deviceMode isEqualToString: simulator]) {
            hCell = 70.0;
        }
    }
    
    //  Header view
    hInfo = appDelegate.hStatus + 10 + 30 + 20 + 10;
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hInfo);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    lbNoAccount.font = appDelegate.fontNormal;
    [lbNoAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader).offset(appDelegate.hStatus);
        make.left.bottom.right.equalTo(viewHeader);
    }];
    
    imgAvatar.clipsToBounds = TRUE;
    imgAvatar.layer.cornerRadius = 50.0/2;
    [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader).offset(10);
        make.top.equalTo(viewHeader).offset(appDelegate.hStatus + 10.0);
        make.width.height.mas_equalTo(50.0);
    }];
    
    //  Edit icon
    [icEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAvatar);
        make.right.equalTo(viewHeader).offset(-10);
        make.width.height.mas_equalTo(35.0);
    }];
    
    [lbFullname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAvatar);
        make.left.equalTo(imgAvatar.mas_right).offset(10);
        make.right.equalTo(icEdit.mas_left).offset(-5);
        make.height.mas_equalTo(30.0);
    }];
    
    [lbAccID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbFullname.mas_bottom);
        make.left.right.equalTo(lbFullname);
        make.bottom.equalTo(imgAvatar.mas_bottom);
    }];
    
    [tbContent registerNib:[UINib nibWithNibName:@"MenuCell" bundle:nil] forCellReuseIdentifier:@"MenuCell"];
    tbContent.delegate = self;
    tbContent.dataSource = self;
    tbContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbContent.scrollEnabled = FALSE;
    [tbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-self.tabBarController.tabBar.frame.size.height);
    }];
    
}

- (void)updateInformationOfUser
{
    AccountState curState = [appDelegate checkSipStateOfAccount];
    if (curState == eAccountNone) {
        [self showProfileView: FALSE];
    }else{
        [self showProfileView: TRUE];
        lbAccID.text = USERNAME;
    }
}

- (void)showProfileView: (BOOL)show {
    imgAvatar.hidden = !show;
    lbAccID.hidden = !show;
    lbFullname.hidden = !show;
    lbNoAccount.hidden = show;
    
    icEdit.hidden = TRUE;
}

#pragma mark - uitableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"MenuCell";
    MenuCell *cell = (MenuCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case eSettingsAccount:{
            cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Account settings"];
            cell._iconImage.image = [UIImage imageNamed:@"ic_setup.png"];
            break;
        }
        case eSettings:{
            cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Settings"];
            cell._iconImage.image = [UIImage imageNamed:@"ic_setting.png"];
            break;
        }
        case eFeedback:{
            cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Feedback"];
            cell._iconImage.image = [UIImage imageNamed:@"ic_support.png"];
            break;
        }
        case ePolicy:{
            cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Privacy Policy"];
            cell._iconImage.image = [UIImage imageNamed:@"ic_term.png"];
            break;
        }
        case eIntroduce:{
            cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Introduction"];
            cell._iconImage.image = [UIImage imageNamed:@"ic_introduce.png"];
            break;
        }
        case eSendLogs:{
            cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Send logs"];
            cell._iconImage.image = [UIImage imageNamed:@"ic_send_logs.png"];
            break;
        }
        case eAbout:{
            cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"About"];
            cell._iconImage.image = [UIImage imageNamed:@"ic_info.png"];
            cell._lbSepa.hidden = TRUE;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case eSettingsAccount:{
            AccountSettingsViewController *accountSettingVC = [[AccountSettingsViewController alloc] initWithNibName:@"AccountSettingsViewController" bundle:nil];
            accountSettingVC.hidesBottomBarWhenPushed = TRUE;
            [self.navigationController pushViewController:accountSettingVC animated:TRUE];
            
            break;
        }
        case eSettings:{
            SettingsViewController *settingVC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
            settingVC.hidesBottomBarWhenPushed = TRUE;
            [self.navigationController pushViewController:settingVC animated:TRUE];
            
            break;
        }
        case eFeedback:{
            NSURL *linkApp = [NSURL URLWithString: link_appstore];
            [[UIApplication sharedApplication] openURL:linkApp options:[[NSDictionary alloc] init] completionHandler:nil];
            
            break;
        }
        case ePolicy:{
            PolicyViewController *policyVC = [[PolicyViewController alloc] initWithNibName:@"PolicyViewController" bundle:nil];
            policyVC.hidesBottomBarWhenPushed = TRUE;
            [self.navigationController pushViewController:policyVC animated:TRUE];
            break;
        }
        case eIntroduce:{
            IntroduceViewController *introduceVC = [[IntroduceViewController alloc] initWithNibName:@"IntroduceViewController" bundle:nil];
            introduceVC.hidesBottomBarWhenPushed = TRUE;
            [self.navigationController pushViewController:introduceVC animated:TRUE];
            break;
        }
        case eSendLogs:{
            SendLogsViewController *sendLogsVC = [[SendLogsViewController alloc] initWithNibName:@"SendLogsViewController" bundle:nil];
            sendLogsVC.hidesBottomBarWhenPushed = TRUE;
            [self.navigationController pushViewController:sendLogsVC animated:TRUE];
            break;
        }
        case eAbout:{
            AboutViewController *aboutVC = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            aboutVC.hidesBottomBarWhenPushed = TRUE;
            [self.navigationController pushViewController:aboutVC animated:TRUE];
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

@end
