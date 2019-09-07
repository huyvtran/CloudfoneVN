//
//  LanguageViewController.m
//  CloudfoneVN
//
//  Created by Khai Leo on 8/26/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "LanguageViewController.h"
#import "LanguageCell.h"
#import "LanguageObject.h"

@interface LanguageViewController ()<UITableViewDelegate, UITableViewDataSource>{
    AppDelegate *appDelegate;
    NSString *curLanguage;
    NSMutableArray *listLanguage;
}
@end

@implementation LanguageViewController
@synthesize tbContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self autoLayoutForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self showContentOfCurrentLanguage];
    
    curLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:language_key];
    if (curLanguage == nil || [curLanguage isEqualToString: @""]) {
        curLanguage = key_en;
        [[NSUserDefaults standardUserDefaults] setObject:key_en forKey:language_key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self createDataForLanguageView];
    [tbContent reloadData];
}

- (void)createDataForLanguageView {
    if (listLanguage == nil) {
        listLanguage = [[NSMutableArray alloc] init];
    }
    [listLanguage removeAllObjects];
    
    LanguageObject *viLang = [[LanguageObject alloc] init];
    viLang._code = @"vi";
    viLang._title = [appDelegate.localization localizedStringForKey:@"Vietnamese"];
    viLang._flag = @"flag_vietnam";
    [listLanguage addObject: viLang];
    
    LanguageObject *enLang = [[LanguageObject alloc] init];
    enLang._code = @"en";
    enLang._title = [appDelegate.localization localizedStringForKey:@"English"];
    enLang._flag = @"flag_usa";
    [listLanguage addObject: enLang];
}

- (void)showContentOfCurrentLanguage {
    self.title = [appDelegate.localization localizedStringForKey:@"Change language"];
    [self createDataForLanguageView];
    [tbContent reloadData];
}

- (void)autoLayoutForView
{
    self.view.backgroundColor = GRAY_230;
    
    [tbContent registerNib:[UINib nibWithNibName:@"LanguageCell" bundle:nil] forCellReuseIdentifier:@"LanguageCell"];
    tbContent.delegate = self;
    tbContent.dataSource = self;
    tbContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbContent.backgroundColor = UIColor.clearColor;
    [tbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
}

#pragma mark - UITableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LanguageCell *cell = (LanguageCell *)[tableView dequeueReusableCellWithIdentifier: @"LanguageCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    LanguageObject *langObj = [listLanguage objectAtIndex: indexPath.row];
    [cell._lbTitle setText: langObj._title];
    if ([langObj._code isEqualToString: curLanguage]) {
        cell._imgSelect.image = [UIImage imageNamed:@"ic_checked.png"];
    }else{
        cell._imgSelect.image = [UIImage imageNamed:@"ic_not_check.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LanguageObject *lang = [listLanguage objectAtIndex: indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:lang._code forKey:language_key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    curLanguage = lang._code;
    [appDelegate.localization setLanguage: lang._code];
    
    [self showContentOfCurrentLanguage];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

@end
