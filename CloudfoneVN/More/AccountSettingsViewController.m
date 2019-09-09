//
//  AccountSettingsViewController.m
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "AccountSettingsViewController.h"
#import "PBXSettingViewController.h"
#import "ChangePasswordViewController.h"
#import "NewSettingCell.h"

@interface AccountSettingsViewController ()<UITableViewDelegate, UITableViewDataSource>{
    AccountState stateAccount;
    AppDelegate *appDelegate;
    float hCell;
}

@end

@implementation AccountSettingsViewController
@synthesize tbContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    hCell = 60.0;
    if (IS_IPHONE || IS_IPOD) {
        NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
        if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2] || [deviceMode isEqualToString: simulator]) {
            hCell = 70.0;
        }
    }
    
    self.view.backgroundColor = GRAY_230;
    [tbContent registerNib:[UINib nibWithNibName:@"NewSettingCell" bundle:nil] forCellReuseIdentifier:@"NewSettingCell"];
    tbContent.backgroundColor = UIColor.clearColor;
    tbContent.delegate = self;
    tbContent.dataSource = self;
    tbContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbContent.scrollEnabled = FALSE;
    [tbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.bottom.right.equalTo(self.view);
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = FALSE;
    
    self.title = [appDelegate.localization localizedStringForKey:@"Account settings"];
    
    stateAccount = [appDelegate checkSipStateOfAccount];
    [tbContent reloadData];
}

#pragma mark - UITableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (stateAccount == eAccountNone) {
        return 1;
    }
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewSettingCell *cell = (NewSettingCell *)[tableView dequeueReusableCellWithIdentifier: @"NewSettingCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case 0:{
            cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"PBX account"];
            
            switch (stateAccount) {
                case eAccountNone:
                    cell.lbDescription.text = [appDelegate.localization localizedStringForKey:@"No account"];
                    break;
                case eAccountOff:{
                    cell.lbDescription.text = [appDelegate.localization localizedStringForKey:@"Offline"];
                    break;
                }
                case eAccountDis:{
                    cell.lbDescription.text = [appDelegate.localization localizedStringForKey:@"Disabled"];
                    break;
                }
                case eAccountOn:{
                    cell.lbDescription.text = [appDelegate.localization localizedStringForKey:@"Enabled"];
                    break;
                }
            }
            
            break;
        }
        case 1:{
            cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Change password"];
            [cell.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(cell).offset(10);
                make.right.equalTo(cell.imgArrow).offset(-10);
                make.top.bottom.equalTo(cell);
            }];
            cell.lbDescription.text = @"";
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PBXSettingViewController *pbxSettingVC = [[PBXSettingViewController alloc] initWithNibName:@"PBXSettingViewController" bundle:nil];
        [self.navigationController pushViewController:pbxSettingVC animated:TRUE];
        
    }else if (indexPath.section == 1){
        if (stateAccount == eAccountNone) {
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"No account"] duration:3.0 position:CSToastPositionCenter];
        }else{
            ChangePasswordViewController *changePassVC = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController" bundle:nil];
            [self.navigationController pushViewController:changePassVC animated:TRUE];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 2.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}


@end
