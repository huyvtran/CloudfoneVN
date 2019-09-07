//
//  AllContactListViewController.m
//  linphone
//
//  Created by admin on 1/29/18.
//

#import "AllContactListViewController.h"
#import "EditContactViewController.h"
#import "ContactCell.h"

@interface AllContactListViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    AppDelegate *appDelegate;
    NSMutableDictionary *contactsInfo;
    NSMutableArray *searchs;
    
    float hSection;
    float hCell;
    
    NSTimer *searchTimer;
    BOOL isSearching;
    
    NSArray *listCharacter;
    UIFont *textFont;
}

@end

@implementation AllContactListViewController
@synthesize viewHeader, iconBack, lbHeader, bgHeader, tfSearch, iconClear, tbContacts, lbNoContact;
@synthesize phoneNumber;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    listCharacter = [[NSArray alloc] initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F",
                     @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    [self autoLayoutForMainView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (contactsInfo == nil) {
        contactsInfo = [[NSMutableDictionary alloc] init];
    }else{
        [contactsInfo removeAllObjects];
    }
    
    if (searchs == nil) {
        searchs = [[NSMutableArray alloc] init];
    }else{
        [searchs removeAllObjects];
    }
    
    [self showContentWithCurrentLanguage];
    
    if ([tfSearch.text isEqualToString:@""]) {
        iconClear.hidden = TRUE;
        isSearching = FALSE;
        if (appDelegate.contacts.count > 0) {
            lbNoContact.hidden = TRUE;
        }else{
            lbNoContact.hidden = FALSE;
        }
        [tbContacts reloadData];
    }else{
        iconClear.hidden = FALSE;
        isSearching = TRUE;
        
        [self startSearchPhoneBook];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)iconBackClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated: TRUE];
}

- (IBAction)iconCloseClicked:(UIButton *)sender {
    iconClear.hidden = TRUE;
    tfSearch.text = @"";
    [searchs removeAllObjects];
    isSearching = FALSE;
    tbContacts.hidden = FALSE;
    [tbContacts reloadData];
}

#pragma mark - my functions

- (void)showContentWithCurrentLanguage {
    lbHeader.text = [appDelegate.localization localizedStringForKey:@"Choose contact"];
    lbNoContact.text = [appDelegate.localization localizedStringForKey:@"No contacts"];
}

//  Setup frame cho view
- (void)autoLayoutForMainView
{
    float hSearchView = 60.0;
    float hHeader = appDelegate.hStatus + appDelegate.hNav + hSearchView;
    
    viewHeader.backgroundColor = UIColor.clearColor;
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    lbHeader.font = appDelegate.fontLarge;
    [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader).offset(appDelegate.hStatus);
        make.centerX.equalTo(viewHeader.mas_centerX);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(appDelegate.hNav);
    }];
    
    iconBack.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader);
        make.centerY.equalTo(lbHeader.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    
    float hTextfield = 32.0;
    tfSearch.backgroundColor = [UIColor colorWithRed:(16/255.0) green:(59/255.0)
                                                 blue:(123/255.0) alpha:0.8];
    tfSearch.font = [UIFont systemFontOfSize: 16.0];
    tfSearch.borderStyle = UITextBorderStyleNone;
    tfSearch.layer.cornerRadius = hTextfield/2;
    tfSearch.clipsToBounds = YES;
    tfSearch.textColor = UIColor.whiteColor;
    if ([self.tfSearch respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        tfSearch.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[appDelegate.localization localizedStringForKey:@"Search..."] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:1.0]}];
    } else {
        tfSearch.placeholder = [appDelegate.localization localizedStringForKey:@"Search..."];
    }
    [tfSearch addTarget:self
                  action:@selector(whenTextFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    UIView *pLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hTextfield, hTextfield)];
    tfSearch.leftView = pLeft;
    tfSearch.leftViewMode = UITextFieldViewModeAlways;
    
    [tfSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbHeader.mas_bottom).offset((hSearchView-hTextfield)/2);
        make.left.equalTo(viewHeader).offset(30.0);
        make.right.equalTo(viewHeader).offset(-30.0);
        make.height.mas_equalTo(hTextfield);
    }];
    tfSearch.returnKeyType = UIReturnKeyDone;
    tfSearch.delegate = self;
    
    UIImageView *imgSearch = [[UIImageView alloc] init];
    imgSearch.image = [UIImage imageNamed:@"ic_search"];
    [tfSearch addSubview: imgSearch];
    [imgSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tfSearch.mas_centerY);
        make.left.equalTo(tfSearch).offset(8.0);
        make.width.height.mas_equalTo(17.0);
    }];
    
    iconClear.backgroundColor = UIColor.clearColor;
    iconClear.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [iconClear mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(tfSearch);
        make.width.mas_equalTo(hTextfield);
    }];
    
    //  table contact
    [tbContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    
    tbContacts.delegate = self;
    tbContacts.dataSource = self;
    tbContacts.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([tbContacts respondsToSelector:@selector(setSectionIndexColor:)]) {
        [tbContacts setSectionIndexColor: [UIColor grayColor]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            [tbContacts setSectionIndexBackgroundColor:[UIColor whiteColor]];
        }
    }
    
    lbNoContact.textColor = UIColor.darkGrayColor;
    lbNoContact.font = appDelegate.fontLarge;
    [lbNoContact mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    
    hCell = 60.0;
    hSection = 35.0;
}

- (void)whenTextFieldDidChange: (UITextField *)textField {
    if (textField.text.length == 0) {
        isSearching = FALSE;
        iconClear.hidden = TRUE;
        
        [tbContacts reloadData];
    }else{
        isSearching = TRUE;
        iconClear.hidden = FALSE;
        
        [searchTimer invalidate];
        searchTimer = nil;
        searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                     selector:@selector(startSearchPhoneBook)
                                                     userInfo:nil repeats:NO];
    }
}

- (void)startSearchPhoneBook {
    [searchs removeAllObjects];
    
    NSString *strSearch = tfSearch.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self searchPhoneBook: strSearch];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [tbContacts reloadData];
        });
    });
}

- (void)searchPhoneBook: (NSString *)strSearch
{
    ABAddressBookRef addressListBook = ABAddressBookCreate();
    NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressListBook);
    for (int i=0; i<[arrayOfAllPeople count]; i++ )
    {
        ABRecordRef person = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:i];
        
        NSString *fullname = [ContactsUtil getFullNameFromContact: person];
        NSString *convertName = [AppUtil convertUTF8CharacterToCharacter: fullname];
        
        if ([convertName rangeOfString: strSearch options: NSCaseInsensitiveSearch].location != NSNotFound) {
            [searchs addObject: (__bridge id _Nonnull)(person)];
            continue;
        }
        
        ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneNumberCount = ABMultiValueGetCount( phoneNumbers );
        
        for (int k=0; k<phoneNumberCount; k++ )
        {
            CFStringRef phoneNumberValue = ABMultiValueCopyValueAtIndex( phoneNumbers, k );
            NSString *phoneNumber = (__bridge NSString *)phoneNumberValue;
            phoneNumber = [AppUtil removeAllSpecialInString: phoneNumber];
            if ([phoneNumber containsString: strSearch]) {
                [searchs addObject: (__bridge id _Nonnull)(person)];
                break;
            }
        }
    }
}

- (void)getSectionsForContactsList: (NSMutableArray *)contactList {
    [contactsInfo removeAllObjects];
    
    // Loop through the books and create our keys
    for (int index=0; index<contactList.count; index++) {
        ABRecordRef person = (__bridge ABRecordRef)[contactList objectAtIndex: index];
        NSString *fullname = [ContactsUtil getFullNameFromContact: person];
        
        NSString *c = @"";
        if (fullname.length > 1) {
            c = [[fullname substringToIndex: 1] uppercaseString];
            c = [AppUtil convertUTF8StringToString: c];
        }
        
        if (![listCharacter containsObject:c]) {
            c = @"z#";
        }
        
        if (![[contactsInfo allKeys] containsObject: c]) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [list addObject: (__bridge id _Nonnull)(person)];
            [contactsInfo setObject:list forKey:c];
            
        }else{
            NSMutableArray *list = [contactsInfo objectForKey: c];
            [list addObject: (__bridge id _Nonnull)(person)];
            [contactsInfo setObject:list forKey:c];
        }
    }
}

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isSearching) {
        [self getSectionsForContactsList: searchs];
    }else{
        [self getSectionsForContactsList: appDelegate.contacts];
    }
    return [contactsInfo allKeys].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[[contactsInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    return [[contactsInfo objectForKey:key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [[[contactsInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
    ABRecordRef person = (__bridge ABRecordRef)[[contactsInfo objectForKey: key] objectAtIndex:indexPath.row];
    
    
    static NSString *identifier = @"ContactCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *fullname = [ContactsUtil getFullNameFromContact: person];
    cell.name.text = fullname;
    
    UIImage *avatar = [ContactsUtil getAvatarFromContact: person];
    cell.image.image = avatar;
    
    NSString *firstPhone = [ContactsUtil getFirstPhoneFromContact: person];
    cell.phone.text = firstPhone;
    cell.icCall.hidden = TRUE;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [[[contactsInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
    ABRecordRef person = (__bridge ABRecordRef)[[contactsInfo objectForKey: key] objectAtIndex:indexPath.row];
    int contactId = ABRecordGetRecordID(person);
    
    NSNumber *pbxIdContact = [[NSUserDefaults standardUserDefaults] objectForKey: PBX_ID_CONTACT];
    if (pbxIdContact != nil && [pbxIdContact intValue] == contactId) {
        return;
    }
    
    EditContactViewController *editVC = [[EditContactViewController alloc] initWithNibName:@"EditContactViewController" bundle:nil];
    editVC.idContact = contactId;
    editVC.curPhoneNumber = phoneNumber;
    [self.navigationController pushViewController:editVC animated:TRUE];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return hSection;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *key = [[[contactsInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35.0)];
    headerView.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1.0];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width-20, headerView.frame.size.height)];
    descLabel.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0) blue:(50/255.0) alpha:1.0];
    if ([key isEqualToString:@"z#"]) {
        descLabel.text = @"#";
    }else{
        descLabel.text = key;
    }
    descLabel.backgroundColor = UIColor.clearColor;
    descLabel.font = appDelegate.fontLargeBold;
    [headerView addSubview: descLabel];
    return headerView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithArray: [[contactsInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    int iCount = 0;
    while (iCount < tmpArr.count) {
        NSString *title = [tmpArr objectAtIndex: iCount];
        if ([title isEqualToString:@"z#"]) {
            [tmpArr replaceObjectAtIndex:iCount withObject:@"#"];
            break;
        }
        iCount++;
    }
    return tmpArr;
}

#pragma mark - UITextfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == tfSearch) {
        [tfSearch resignFirstResponder];
    }
    return TRUE;
}

@end
