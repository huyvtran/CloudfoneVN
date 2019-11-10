//
//  PhoneBookDetailViewController.m
//  linphone
//
//  Created by lam quang quan on 6/24/19.
//

#import "PhoneBookDetailViewController.h"
#import "EditContactViewController.h"
#import "UIContactPhoneCell.h"
#import "UIKContactCell.h"
#import "ContactDetailObj.h"

@interface PhoneBookDetailViewController ()<UITableViewDelegate, UITableViewDataSource>{
    AppDelegate *appDelegate;
    float hCell;
    NSMutableArray *listPhone;
    ABRecordRef contact;
}

@end

@implementation PhoneBookDetailViewController
@synthesize _viewHeader, _iconBack, _lbTitle, _iconEdit, _imgAvatar, _lbContactName;
@synthesize _tbContactInfo, idContact;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self autoLayoutForView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = TRUE;
    [self displayContactInformation];
}

- (IBAction)_iconBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated: TRUE];
}

- (IBAction)_iconEditClicked:(id)sender
{
    EditContactViewController *editContactVC = [[EditContactViewController alloc] initWithNibName:@"EditContactViewController" bundle:nil];
    editContactVC.idContact = idContact;
    editContactVC.curPhoneNumber = @"";
    [self.navigationController pushViewController:editContactVC animated:TRUE];
}

- (void)autoLayoutForView
{
    self.view.backgroundColor = GRAY_230;
    hCell = 60.0;
    if (IS_IPHONE || IS_IPOD) {
        if (SCREEN_WIDTH >= SCREEN_WIDTH_IPHONE_6PLUS) {
            hCell = 70.0;
        }
    }
    
    _lbTitle.font =appDelegate.fontLarge;
    
    //  header
    float wAvatar = 120.0;
    float hName = 40.0;
    
    float hHeader = appDelegate.hStatus + appDelegate.hNav + wAvatar + hName + 10.0;
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    [_bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    [_lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset(appDelegate.hStatus);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.mas_equalTo(200.0);
        make.height.mas_equalTo(appDelegate.hNav);
    }];
    
    _iconBack.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader);
        make.centerY.equalTo(_lbTitle.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    
    _iconEdit.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [_iconEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconBack);
        make.right.equalTo(_viewHeader);
        make.width.equalTo(_iconBack.mas_width);
        make.height.equalTo(_iconBack.mas_height);
    }];
    
    _imgAvatar.layer.cornerRadius = wAvatar/2;
    _imgAvatar.layer.borderWidth = 2.0;
    _imgAvatar.layer.borderColor = UIColor.whiteColor.CGColor;
    _imgAvatar.clipsToBounds = YES;
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbTitle.mas_bottom).offset(10);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.height.mas_equalTo(wAvatar);
    }];
    
    _lbContactName.font = appDelegate.fontLarge;
    [_lbContactName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgAvatar.mas_bottom);
        make.left.right.equalTo(_viewHeader);
        make.height.mas_equalTo(appDelegate.hNav);
    }];
    
    //  content
    [_tbContactInfo registerNib:[UINib nibWithNibName:@"UIContactPhoneCell" bundle:nil] forCellReuseIdentifier:@"UIContactPhoneCell"];
    [_tbContactInfo registerNib:[UINib nibWithNibName:@"UIKContactCell" bundle:nil] forCellReuseIdentifier:@"UIKContactCell"];
    _tbContactInfo.delegate = self;
    _tbContactInfo.dataSource = self;
    _tbContactInfo.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbContactInfo.backgroundColor = UIColor.clearColor;
    [_tbContactInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)displayContactInformation {
    ABAddressBookRef addressListBook = ABAddressBookCreate();
    contact = ABAddressBookGetPersonWithRecordID(addressListBook, idContact);
    NSString *name = [ContactsUtil getFullNameFromContact: contact];
    _lbContactName.text = name;
    
    UIImage *avatar = [ContactsUtil getAvatarFromContact: contact];
    _imgAvatar.image = avatar;
    
    listPhone = [ContactsUtil getListPhoneOfContactPerson: contact];
    [_tbContactInfo reloadData];
}

#pragma mark - Tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int numRow = [self getRowForSection];
    return numRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < listPhone.count)
    {
        UIContactPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier: @"UIContactPhoneCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        ContactDetailObj *anItem = [listPhone objectAtIndex: indexPath.row];
        cell.lbTitle.text = anItem._titleStr;
        cell.lbPhone.text = anItem._valueStr;

        [cell.icCall setTitle:anItem._valueStr forState:UIControlStateNormal];
        [cell.icCall addTarget:self
                        action:@selector(onIconCallClicked:)
              forControlEvents:UIControlEventTouchUpInside];

        return cell;
    }else{
        UIKContactCell *cell = [tableView dequeueReusableCellWithIdentifier: @"UIKContactCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        NSString *company = [ContactsUtil getCompanyFromContact: contact];
        NSString *email = [ContactsUtil getEmailFromContact: contact];
        
        if (indexPath.row == listPhone.count) {
            if (company != nil && ![company isEqualToString:@""]) {
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Company"];
                cell.lbValue.text = company;
            }else if (email != nil && ![email isEqualToString:@""]){
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Email"];
                cell.lbValue.text = email;
            }
        }else if (indexPath.row == listPhone.count + 1){
            if (email != nil && ![email isEqualToString:@""]){
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Email"];
                cell.lbValue.text = email;
            }
        }
        return cell;
    }
}

- (void)onIconCallClicked: (UIButton *)sender
{
    [SipUtil makeCallToPhoneNumber: sender.currentTitle displayName:@""];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

- (int)getRowForSection {
    int result = (int)listPhone.count;
    
    NSString *company = [ContactsUtil getCompanyFromContact: contact];
    if (company != nil && ![company isEqualToString:@""]) {
        result = result + 1;
    }
    
    NSString *email = [ContactsUtil getEmailFromContact: contact];
    if (email != nil && ![email isEqualToString:@""]) {
        result = result + 1;
    }
    return result;
}

@end
