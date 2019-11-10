//
//  SettingsViewController.m
//  CloudfoneVN
//
//  Created by OS on 8/26/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "SettingsViewController.h"
#import "LanguageViewController.h"
#import "SettingCell.h"

@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate>{
    AppDelegate *appDelegate;
    float hCell;
}
@end

@implementation SettingsViewController
@synthesize tbContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setupUIForView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = FALSE;
    
    [self showContentWithCurrentLanguage];
}

- (void)showContentWithCurrentLanguage {
    self.title = [appDelegate.localization localizedStringForKey:@"Settings"];
    [tbContent reloadData];
}

- (void)setupUIForView
{
    self.view.backgroundColor = GRAY_230;
    hCell = 60.0;
    if (IS_IPHONE || IS_IPOD) {
        if (SCREEN_WIDTH >= SCREEN_WIDTH_IPHONE_6PLUS) {
            hCell = 70.0;
        }
    }
    
    [tbContent registerNib:[UINib nibWithNibName:@"SettingCell" bundle:nil] forCellReuseIdentifier:@"SettingCell"];
    tbContent.backgroundColor = UIColor.clearColor;
    tbContent.delegate = self;
    tbContent.dataSource = self;
    tbContent.scrollEnabled = NO;
    tbContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingCell *cell = (SettingCell *)[tableView dequeueReusableCellWithIdentifier: @"SettingCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Change language"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LanguageViewController *languageVC = [[LanguageViewController alloc] initWithNibName:@"LanguageViewController" bundle:nil];
    [self.navigationController pushViewController:languageVC animated:TRUE];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return hCell;
}

@end
