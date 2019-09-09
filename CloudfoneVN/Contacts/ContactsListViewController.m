//
//  ContactsListViewController.m
//  CloudfoneVN
//
//  Created by OS on 8/27/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "ContactsListViewController.h"
#import "NewContactViewController.h"
#import "PhoneBookDetailViewController.h"
#import "WebServices.h"
#import "PBXContact.h"
#import "PBXContactTableCell.h"
#import "ContactCell.h"

@interface ContactsListViewController ()<UITextFieldDelegate, WebServicesDelegate, UITableViewDelegate, UITableViewDataSource>{
    AppDelegate *appDelegate;
    int currentView;
    float hIcon;
    WebServices *webService;
    
    NSArray *listCharacter;
    NSMutableDictionary *pbxSections;
    NSMutableDictionary *allSections;
    float hSection;
    float hCell;
    
    NSTimer *searchTimer;
    BOOL searching;
    NSMutableArray *pbxListSearch;
    NSMutableArray *allListSearch;
}
@end

@implementation ContactsListViewController
@synthesize viewHeader, bgHeader, icAdd, icSync, btnAll, btnPBX, tfSearch, icClear, tbPBXContacts, tbAllContacts, lbNoAllContacts, lbNoPBXContacts;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    listCharacter = [[NSArray alloc] initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F",
                     @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    [self autoLayoutForMainView];
    
    currentView = eContactPBX;
    [self updateStateIconWithView: currentView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = TRUE;
    
    if (webService == nil) {
        webService = [[WebServices alloc] init];
        webService.delegate = self;
    }
    
    if (![tfSearch.text isEqualToString:@""]) {
        icClear.hidden = FALSE;
    }else{
        icClear.hidden = TRUE;
    }
    
    //  check to show icon sync
    [self checkToShowSyncPBXContacts];
    
    [self registerObservers];
    
    if (currentView == eContactPBX) {
        tbAllContacts.hidden = lbNoAllContacts.hidden = TRUE;
        if (appDelegate.pbxContacts.count > 0) {
            lbNoPBXContacts.hidden = TRUE;
            tbPBXContacts.hidden = FALSE;
            [tbPBXContacts reloadData];
        }else{
            lbNoPBXContacts.hidden = FALSE;
            tbPBXContacts.hidden = TRUE;
        }
    }else{
        tbPBXContacts.hidden = lbNoPBXContacts.hidden = TRUE;
        if (appDelegate.contacts.count > 0) {
            lbNoAllContacts.hidden = TRUE;
            tbAllContacts.hidden = FALSE;
            [tbAllContacts reloadData];
        }else{
            lbNoAllContacts.hidden = FALSE;
            tbAllContacts.hidden = TRUE;
        }
    }
    
    lbNoPBXContacts.text = lbNoAllContacts.text = [appDelegate.localization localizedStringForKey:@"No contacts"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [AppUtil addCornerRadiusTopLeftAndBottomLeftForButton:btnPBX radius:(hIcon-10)/2
                                                withColor:SELECT_TAB_BG_COLOR border:2.0];
    
    [AppUtil addCornerRadiusTopRightAndBottomRightForButton:btnAll radius:(hIcon-10)/2
                                                  withColor:SELECT_TAB_BG_COLOR border:2.0];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [self.view endEditing: TRUE];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (IBAction)iconSyncPress:(UIButton *)sender {
    [self startSyncPBXContactsForAccount];
}

- (IBAction)iconAddPress:(UIButton *)sender {
    NewContactViewController *addContactVC = [[NewContactViewController alloc] initWithNibName:@"NewContactViewController" bundle:nil];
    addContactVC.hidesBottomBarWhenPushed = TRUE;
    [self.navigationController pushViewController:addContactVC animated:TRUE];
}

- (IBAction)iconClearPress:(UIButton *)sender {
    [self.view endEditing: TRUE];
    
    tfSearch.text = @"";
    searching = FALSE;
    icClear.hidden = TRUE;
    
    if (currentView == eContactAll) {
        if (appDelegate.contacts.count > 0) {
            lbNoAllContacts.hidden = TRUE;
            tbAllContacts.hidden = FALSE;
            [tbAllContacts reloadData];
        }else{
            lbNoAllContacts.hidden = FALSE;
            tbAllContacts.hidden = TRUE;
        }
    }else{
        if (appDelegate.pbxContacts.count > 0) {
            lbNoPBXContacts.hidden = TRUE;
            tbPBXContacts.hidden = FALSE;
            [tbPBXContacts reloadData];
        }else{
            lbNoPBXContacts.hidden = FALSE;
            tbPBXContacts.hidden = TRUE;
        }
    }
}

- (IBAction)btnAllContactsPress:(UIButton *)sender {
    searching = FALSE;
    
    currentView = eContactAll;
    [self updateStateIconWithView:currentView];
    tfSearch.text = @"";
    icClear.hidden = tbPBXContacts.hidden = TRUE;
    tbAllContacts.hidden = FALSE;
    
    if (!appDelegate.contactLoaded) {
        tbAllContacts.hidden = TRUE;
        lbNoAllContacts.hidden = FALSE;
        lbNoAllContacts.text = [appDelegate.localization localizedStringForKey:@"Loading contacts..."];
    }else{
        if (appDelegate.contacts.count > 0) {
            lbNoAllContacts.hidden = TRUE;
            tbAllContacts.hidden = FALSE;
        }else{
            lbNoAllContacts.hidden = FALSE;
            tbAllContacts.hidden = TRUE;
            lbNoAllContacts.text = [appDelegate.localization localizedStringForKey:@"No contacts"];
        }
    }
}

- (IBAction)btnPBXContactsPress:(UIButton *)sender {
    searching = FALSE;
    
    currentView = eContactPBX;
    [self updateStateIconWithView:currentView];
    tfSearch.text = @"";
    icClear.hidden = tbAllContacts.hidden = TRUE;
    tbPBXContacts.hidden = FALSE;
    
    [self checkToShowSyncPBXContacts];
    
    if (appDelegate.pbxContacts.count > 0) {
        lbNoPBXContacts.hidden = TRUE;
        tbPBXContacts.hidden = FALSE;
    }else{
        lbNoPBXContacts.hidden = FALSE;
        tbPBXContacts.hidden = TRUE;
    }
}

- (void)checkToShowSyncPBXContacts {
    if ([appDelegate checkSipStateOfAccount] == eAccountNone) {
        icSync.hidden = TRUE;
    }else{
        icSync.hidden = (currentView == eContactPBX) ? FALSE : TRUE;
    }
}

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterFinishGetPBXContactsList)
                                                 name:finishGetPBXContacts object:nil];
}

- (void)afterFinishGetPBXContactsList {
    if (currentView == eContactPBX) {
        if (appDelegate.pbxContacts.count > 0) {
            lbNoPBXContacts.hidden = TRUE;
            tbPBXContacts.hidden = FALSE;
            [tbPBXContacts reloadData];
        }else{
            lbNoPBXContacts.hidden = FALSE;
            tbPBXContacts.hidden = TRUE;
        }
    }
}

- (void)updateStateIconWithView: (int)view
{
    if (view == eContactAll){
        icSync.hidden = TRUE;
        icAdd.hidden = FALSE;
        [AppUtil setSelected: TRUE forButton: btnAll];
        [AppUtil setSelected: FALSE forButton: btnPBX];
    }else{
        icSync.hidden = FALSE;
        icAdd.hidden = TRUE;
        [AppUtil setSelected: FALSE forButton: btnAll];
        [AppUtil setSelected: TRUE forButton: btnPBX];
    }
}

- (void)autoLayoutForMainView {
    float marginX = 10.0;
    float hTextfield = 32.0;
    hIcon = 35.0;
    hSection = 35.0;
    hCell = 60.0;
    if (IS_IPHONE || IS_IPOD) {
        NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
        if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2] || [deviceMode isEqualToString: simulator]) {
            hCell = 70.0;
        }
    }
    
    self.view.backgroundColor = UIColor.whiteColor;
    float hHeader = appDelegate.hStatus + appDelegate.hNav + 50.0;
    
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    float originY = appDelegate.hStatus + (appDelegate.hNav - hIcon)/2;
    
    btnPBX.backgroundColor = SELECT_TAB_BG_COLOR;
    [btnPBX setTitle:[appDelegate.localization localizedStringForKey:@"PBX"] forState:UIControlStateNormal];
    [btnPBX setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnPBX mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(viewHeader.mas_centerX);
        make.top.equalTo(viewHeader).offset(originY);
        make.height.mas_equalTo(hIcon);
        make.width.mas_equalTo(SCREEN_WIDTH/4);
    }];
    
    btnAll.backgroundColor = UIColor.clearColor;
    [btnAll setTitle:[appDelegate.localization localizedStringForKey:@"Contacts"] forState:UIControlStateNormal];
    [btnAll setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader.mas_centerX);
        make.top.bottom.equalTo(btnPBX);
        make.width.equalTo(btnPBX.mas_width);
    }];
    
    icSync.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [icSync mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader).offset(marginX);
        make.centerY.equalTo(btnPBX.mas_centerY);
        make.width.height.mas_equalTo(hIcon);
    }];
    
    icAdd.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [icAdd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(viewHeader.mas_right).offset(-marginX);
        make.top.bottom.equalTo(icSync);
        make.width.equalTo(icSync.mas_width);
    }];
    
    tfSearch.backgroundColor = [UIColor colorWithRed:(16/255.0) green:(59/255.0)
                                                blue:(123/255.0) alpha:0.8];
    tfSearch.font = appDelegate.fontNormal;
    tfSearch.borderStyle = UITextBorderStyleNone;
    tfSearch.layer.cornerRadius = hTextfield/2;
    tfSearch.clipsToBounds = TRUE;
    tfSearch.textColor = UIColor.whiteColor;
    if ([tfSearch respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        tfSearch.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[appDelegate.localization localizedStringForKey:@"Search..."] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:1.0]}];
    } else {
        tfSearch.placeholder = [appDelegate.localization localizedStringForKey:@"Search..."];
    }
    [tfSearch addTarget:self
                 action:@selector(onSearchContactChange:)
       forControlEvents:UIControlEventEditingChanged];
    
    UIView *pLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hTextfield, hTextfield)];
    tfSearch.leftView = pLeft;
    tfSearch.leftViewMode = UITextFieldViewModeAlways;
    
    [tfSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(viewHeader).offset(-(50.0 - hTextfield)/2);
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
    
    icClear.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [icClear mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(tfSearch);
        make.width.mas_equalTo(hTextfield);
    }];
    
    [tbPBXContacts registerNib:[UINib nibWithNibName:@"PBXContactTableCell" bundle:nil] forCellReuseIdentifier:@"PBXContactTableCell"];
    tbPBXContacts.delegate = self;
    tbPBXContacts.dataSource = self;
    tbPBXContacts.separatorStyle = UITableViewCellSelectionStyleNone;
    [tbPBXContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-self.tabBarController.tabBar.frame.size.height);
    }];
    
    lbNoPBXContacts.hidden = TRUE;
    lbNoPBXContacts.font = appDelegate.fontLarge;
    lbNoPBXContacts.textColor = UIColor.darkGrayColor;
    [lbNoPBXContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(tbPBXContacts);
    }];
    
    [tbAllContacts registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    tbAllContacts.delegate = self;
    tbAllContacts.dataSource = self;
    tbAllContacts.separatorStyle = UITableViewCellSelectionStyleNone;
    [tbAllContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-self.tabBarController.tabBar.frame.size.height);
    }];
    
    lbNoAllContacts.hidden = TRUE;
    lbNoAllContacts.font = appDelegate.fontLarge;
    lbNoAllContacts.textColor = UIColor.darkGrayColor;
    [lbNoAllContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(tbAllContacts);
    }];
}

- (void)onSearchContactChange: (UITextField *)textField {
    if (![textField.text isEqualToString:@""]) {
        icClear.hidden = FALSE;
    }else{
        icClear.hidden = TRUE;
    }
    
    if (searchTimer) {
        [searchTimer invalidate];
        searchTimer = nil;
    }
    searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                 selector:@selector(startSearchPhoneBook)
                                                 userInfo:nil repeats:NO];
}

//  Added by Khai Le on 04/10/2018
- (void)startSearchPhoneBook {
    
    NSString *search = tfSearch.text;
    if ([search isEqualToString:@""]) {
        searching = FALSE;
        
        if (currentView == eContactAll) {
            [tbAllContacts reloadData];
        }else{
            [tbPBXContacts reloadData];
        }
    }else{
        searching = TRUE;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (currentView == eContactPBX) {
                [self startSearchPBXContactsWithContent: search];
            }else{
                [self startSearchAllContactsWithContent: search];
            }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                if (currentView == eContactPBX) {
                    if (pbxListSearch.count > 0) {
                        lbNoPBXContacts.hidden = TRUE;
                        tbPBXContacts.hidden = FALSE;
                        [tbPBXContacts reloadData];
                    }else{
                        lbNoPBXContacts.hidden = FALSE;
                        tbPBXContacts.hidden = TRUE;
                    }
                }else{
                    if (allListSearch.count > 0) {
                        lbNoAllContacts.hidden = TRUE;
                        tbAllContacts.hidden = FALSE;
                        [tbAllContacts reloadData];
                    }else{
                        lbNoAllContacts.hidden = FALSE;
                        tbAllContacts.hidden = TRUE;
                    }
                }
            });
        });
    }
}

- (void)startSearchPBXContactsWithContent: (NSString *)content
{
    if (pbxListSearch == nil) {
        pbxListSearch = [[NSMutableArray alloc] init];
    }
    [pbxListSearch removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_name CONTAINS[cd] %@ OR _number CONTAINS[cd] %@", content, content];
    NSArray *filter = [appDelegate.pbxContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [pbxListSearch addObjectsFromArray: filter];
    }
}

- (void)startSearchAllContactsWithContent: (NSString *)content
{
    if (allListSearch == nil) {
        allListSearch = [[NSMutableArray alloc] init];
    }
    [allListSearch removeAllObjects];
    
    ABAddressBookRef addressListBook = ABAddressBookCreate();
    NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressListBook);
    for (int i=0; i<[arrayOfAllPeople count]; i++ )
    {
        ABRecordRef person = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:i];
        
        NSString *fullname = [ContactsUtil getFullNameFromContact: person];
        NSString *convertName = [AppUtil convertUTF8CharacterToCharacter: fullname];
        
        if ([convertName rangeOfString: content options: NSCaseInsensitiveSearch].location != NSNotFound) {
            [allListSearch addObject: (__bridge id _Nonnull)(person)];
            continue;
        }
        
        ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneNumberCount = ABMultiValueGetCount( phoneNumbers );
        
        for (int k=0; k<phoneNumberCount; k++ )
        {
            CFStringRef phoneNumberValue = ABMultiValueCopyValueAtIndex( phoneNumbers, k );
            NSString *phoneNumber = (__bridge NSString *)phoneNumberValue;
            phoneNumber = [AppUtil removeAllSpecialInString: phoneNumber];
            if ([phoneNumber containsString: content]) {
                [allListSearch addObject: (__bridge id _Nonnull)(person)];
                break;
            }
        }
    }
}

- (void)startSyncPBXContactsForAccount
{
    BOOL networkReady = [DeviceUtil checkNetworkAvailable];
    if (!networkReady) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    if (appDelegate.isSyncing) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"PBX contacts is being synchronized!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }else{
        NSString *service = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
        if ([service isKindOfClass:[NSNull class]] || service == nil || [service isEqualToString: @""]) {
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"No account"] duration:2.0 position:CSToastPositionCenter];
            return;
        }
        
        [ProgressHUD backgroundColor: ProgressHUD_BG];
        [ProgressHUD show:[appDelegate.localization localizedStringForKey:@"Please wait..."] Interaction:NO];
        
        appDelegate.isSyncing = TRUE;
        [self startAnimationForSyncButton: icSync];
        
        [self getPBXContactsWithServerName: service];
    }
}

- (void)startAnimationForSyncButton: (UIButton *)sender {
    CABasicAnimation *spin;
    spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [spin setFromValue:@0.0f];
    [spin setToValue:@(2*M_PI)];
    [spin setDuration:2.5];
    [spin setRepeatCount: HUGE_VALF];   // HUGE_VALF means infinite repeatCount
    
    [sender.layer addAnimation:spin forKey:@"Spin"];
}

- (void)getPBXContactsWithServerName: (NSString *)serverName
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:serverName forKey:@"ServerName"];
    [webService callWebServiceWithLink:getServerContacts withParams:jsonDict];
}

- (void)whenStartSyncPBXContacts: (NSArray *)data
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self savePBXContactInPhoneBook: data];
        [self getListPBXPhoneNumber: data];
        
        [self getListPhoneWithCurrentContactPBX];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self syncContactsSuccessfully];
        });
    });
}

- (void)getListPhoneWithCurrentContactPBX
{
    ABAddressBookRef addressListBook = ABAddressBookCreate();
    NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressListBook);
    for (int peopleCounter = (int)arrayOfAllPeople.count-1; peopleCounter >= 0; peopleCounter--)
    {
        ABRecordRef aPerson = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:peopleCounter];
        NSString *sipNumber = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNamePhoneticProperty);
        if (sipNumber != nil && [sipNumber isEqualToString: keySyncPBX])
        {
            ABRecordID idContact = ABRecordGetRecordID(aPerson);
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:idContact]
                                                      forKey:PBX_ID_CONTACT];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

//  Thông báo kết thúc sync contacts
- (void)syncContactsSuccessfully
{
    if (appDelegate.pbxContacts.count > 0) {
        [tbPBXContacts reloadData];
        tbPBXContacts.hidden = FALSE;
    }else{
        lbNoPBXContacts.hidden = TRUE;
    }
    
    [ProgressHUD dismiss];
    appDelegate.isSyncing = FALSE;
    [icSync.layer removeAllAnimations];
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Contacts have been successfully synchronized"] duration:2.0 position:CSToastPositionCenter];
}

- (void)savePBXContactInPhoneBook: (NSArray *)pbxData
{
    NSString *pbxContactName = @"";
    
    ABAddressBookRef addressListBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    NSArray *arrayOfAllPeople = (__bridge  NSArray *)ABAddressBookCopyArrayOfAllPeople(addressListBook);
    NSUInteger peopleCounter = 0;
    
    BOOL exists = NO;
    
    for (peopleCounter = 0; peopleCounter < [arrayOfAllPeople count]; peopleCounter++)
    {
        ABRecordRef aPerson = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:peopleCounter];
        NSString *sipNumber = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNamePhoneticProperty);
        if (sipNumber != nil && [sipNumber isEqualToString: keySyncPBX]) {
            pbxContactName = [AppUtil getNameOfContact: aPerson];
            exists = YES;
            
            ABRecordSetValue(aPerson, kABPersonPhoneProperty, nil, nil);
            BOOL isSaved = ABAddressBookSave (addressListBook, nil);
            if (isSaved) {
                NSLog(@"Update thanh cong");
            }
            // Phone number
            ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            for (int iCount=0; iCount<pbxData.count; iCount++) {
                NSDictionary *dict = [pbxData objectAtIndex: iCount];
                NSString *name = [dict objectForKey:@"name"];
                NSString *number = [dict objectForKey:@"number"];
                
                ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(number), (__bridge  CFStringRef)name, NULL);
            }
            
            ABRecordSetValue(aPerson, kABPersonPhoneProperty, multiPhone,nil);
            isSaved = ABAddressBookSave (addressListBook, nil);
            if (isSaved) {
                NSLog(@"Update thanh cong");
            }
        }
    }
    if (!exists) {
        [self addContactsWithData:pbxData withContactName:nameContactSyncPBX andCompany:nameSyncCompany];
    }
}

- (void)addContactsWithData: (NSArray *)pbxData withContactName: (NSString *)contactName andCompany: (NSString *)company
{
    NSString *strEmail = @"";
    
    NSString *strAvatar = @"";
    UIImage *logoImage = [UIImage imageNamed:@"logo"];
    NSData *avatarData = UIImagePNGRepresentation(logoImage);
    if (avatarData != nil) {
        strAvatar = [avatarData base64EncodedStringWithOptions: 0];
    }
    
    ABRecordRef aRecord = ABPersonCreate();
    CFErrorRef  anError = NULL;
    
    // Lưu thông tin
    ABRecordSetValue(aRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)(contactName), &anError);
    ABRecordSetValue(aRecord, kABPersonLastNameProperty, (__bridge CFTypeRef)(@""), &anError);
    ABRecordSetValue(aRecord, kABPersonOrganizationProperty, (__bridge CFTypeRef)(company), &anError);
    ABRecordSetValue(aRecord, kABPersonFirstNamePhoneticProperty, (__bridge CFTypeRef)(keySyncPBX), &anError);
    
    ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(email, (__bridge CFTypeRef)(strEmail), CFSTR("email"), NULL);
    ABRecordSetValue(aRecord, kABPersonEmailProperty, email, &anError);
    
    if (avatarData != nil) {
        CFDataRef cfdata = CFDataCreate(NULL,[avatarData bytes], [avatarData length]);
        ABPersonSetImageData(aRecord, cfdata, &anError);
    }
    
    // Phone number
    //  NSMutableArray *listPhone = [[NSMutableArray alloc] init];
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    for (int iCount=0; iCount<pbxData.count; iCount++) {
        NSDictionary *dict = [pbxData objectAtIndex: iCount];
        NSString *name = [dict objectForKey:@"name"];
        NSString *number = [dict objectForKey:@"number"];
        
        ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(number), (__bridge  CFStringRef)name, NULL);
    }
    
    ABRecordSetValue(aRecord, kABPersonPhoneProperty, multiPhone,nil);
    CFRelease(multiPhone);
    
    // Instant Message
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"SIP", (NSString*)kABPersonInstantMessageServiceKey,
                                @"", (NSString*)kABPersonInstantMessageUsernameKey, nil];
    CFStringRef label = NULL; // in this case 'IM' will be set. But you could use something like = CFSTR("Personal IM");
    CFErrorRef errorf = NULL;
    ABMutableMultiValueRef values =  ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    BOOL didAdd = ABMultiValueAddValueAndLabel(values, (__bridge CFTypeRef)(dictionary), label, NULL);
    BOOL didSet = ABRecordSetValue(aRecord, kABPersonInstantMessageProperty, values, &errorf);
    if (!didAdd || !didSet) {
        CFStringRef errorDescription = CFErrorCopyDescription(errorf);
        NSLog(@"%s error %@ while inserting multi dictionary property %@ into ABRecordRef", __FUNCTION__, dictionary, errorDescription);
        CFRelease(errorDescription);
    }
    CFRelease(values);
    
    //Address
    ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    NSMutableDictionary *addressDict = [[NSMutableDictionary alloc] init];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressStreetKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressZIPKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressStateKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressCityKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressCountryKey];
    ABMultiValueAddValueAndLabel(address, (__bridge CFTypeRef)(addressDict), kABWorkLabel, NULL);
    ABRecordSetValue(aRecord, kABPersonAddressProperty, address, &anError);
    
    if (anError != NULL) {
        NSLog(@"error while creating..");
    }
    
    ABAddressBookRef addressBook;
    CFErrorRef error = NULL;
    addressBook = ABAddressBookCreateWithOptions(nil, &error);
    
    BOOL isAdded = ABAddressBookAddRecord (addressBook,aRecord,&error);
    
    if(isAdded){
        NSLog(@"added..");
    }
    if (error != NULL) {
        NSLog(@"ABAddressBookAddRecord %@", error);
    }
    error = NULL;
    
    BOOL isSaved = ABAddressBookSave (addressBook,&error);
    if(isSaved){
        NSLog(@"saved..");
    }
    
    if (error != NULL) {
        NSLog(@"ABAddressBookSave %@", error);
    }
}

- (void)getListPBXPhoneNumber: (NSArray *)saveList
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i=0; i<saveList.count; i++) {
        NSDictionary *info = [saveList objectAtIndex: i];
        NSString *name = [info objectForKey:@"name"];
        NSString *number = [info objectForKey:@"number"];
        
        PBXContact *pbxContact = [[PBXContact alloc] init];
        pbxContact._name = name;
        pbxContact._number = number;
        
        NSString *convertName = [AppUtil convertUTF8CharacterToCharacter: name];
        NSString *nameForSearch = [AppUtil getNameForSearchOfConvertName: convertName];
        pbxContact._nameForSearch = nameForSearch;
        
        [result addObject: pbxContact];
    }
    
    [appDelegate.pbxContacts removeAllObjects];
    [appDelegate.pbxContacts addObjectsFromArray: result];
}

#pragma mark - WebServices delegate
- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    [ProgressHUD dismiss];
    if ([link isEqualToString:getServerContacts]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Failed to sync pbx contacts!"] duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data
{
    if ([link isEqualToString:getServerContacts]) {
        if (data != nil && [data isKindOfClass:[NSArray class]]) {
            [self whenStartSyncPBXContacts: (NSArray *)data];
        }
    }
}

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    
}
#pragma mark - UITableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == tbPBXContacts) {
        if (searching) {
            [self getSectionsForPBXContactsList: pbxListSearch];
        }else{
            [self getSectionsForPBXContactsList: appDelegate.pbxContacts];
        }
        return [[pbxSections allKeys] count];
    }else{
        if (searching) {
            [self getSectionsForContactsList: allListSearch];
        }else{
            [self getSectionsForContactsList: appDelegate.contacts];
        }
        return [allSections allKeys].count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == tbPBXContacts) {
        NSString *str = [[[pbxSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
        return [[pbxSections objectForKey:str] count];
    }else{
        NSString *str = [[[allSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
        return [[allSections objectForKey:str] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tbPBXContacts) {
        PBXContactTableCell *cell = (PBXContactTableCell *)[tableView dequeueReusableCellWithIdentifier: @"PBXContactTableCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *key = [[[pbxSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
        PBXContact *contact = [[pbxSections objectForKey: key] objectAtIndex:indexPath.row];
        
        // Tên contact
        if (contact._name != nil && ![contact._name isKindOfClass:[NSNull class]]) {
            cell._lbName.text = contact._name;
        }else{
            cell._lbName.text = @"";
        }
        
        if (contact._number != nil && ![contact._number isKindOfClass:[NSNull class]]) {
            cell._lbPhone.text = contact._number;
            cell.icCall.hidden = NO;
            [cell.icCall setTitle:contact._number forState:UIControlStateNormal];
            [cell.icCall addTarget:self
                            action:@selector(onIconCallClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
                NSString *avatarName = SFM(@"%@_%@.png", pbxServer, contact._number);
                NSString *localFile = SFM(@"/avatars/%@", avatarName);
                NSData *avatarData = [AppUtil getFileDataFromDirectoryWithFileName:localFile];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    if (avatarData != nil) {
                        cell._imgAvatar.image = [UIImage imageWithData: avatarData];
                    }else{
                        cell._imgAvatar.image = [UIImage imageNamed:@"no_avatar"];
                    }
                });
            });
        }else{
            cell._lbPhone.text = @"";
            cell.icCall.hidden = YES;
        }
        
        if ([contact._name isEqualToString:@""]) {
            cell._imgAvatar.image = [UIImage imageNamed:@"no_avatar"];
        }
        
        int count = (int)[[pbxSections objectForKey:key] count];
        if (indexPath.row == count-1) {
            cell._lbSepa.hidden = TRUE;
        }else{
            cell._lbSepa.hidden = FALSE;
        }
        
        return cell;
        
    }else{
        ContactCell *cell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier: @"ContactCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *key = [[[allSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
        ABRecordRef person = (__bridge ABRecordRef)[[allSections objectForKey: key] objectAtIndex:indexPath.row];
        
        NSString *fullname = [ContactsUtil getFullNameFromContact: person];
        if (fullname != nil && ![fullname isEqualToString:@""] ) {
            cell.name.text = fullname;
        }else{
            
        }
        
        UIImage *avatar = [ContactsUtil getAvatarFromContact: person];
        cell.image.image = avatar;
        
        NSString *firstPhone = [ContactsUtil getFirstPhoneFromContact: person];
        cell.phone.text = firstPhone;
        if (firstPhone != nil && ![firstPhone isEqualToString:@""]) {
            cell.icCall.hidden = FALSE;
            [cell.icCall setTitle:firstPhone forState:UIControlStateNormal];
            [cell.icCall addTarget:self
                            action:@selector(onIconCallClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
        }else{
            cell.icCall.hidden = TRUE;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == tbAllContacts) {
        NSString *key = [[[allSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
        ABRecordRef person = (__bridge ABRecordRef)[[allSections objectForKey: key] objectAtIndex:indexPath.row];
        int contactId = ABRecordGetRecordID(person);
        NSNumber *pbxIdContact = [[NSUserDefaults standardUserDefaults] objectForKey: PBX_ID_CONTACT];
        if (pbxIdContact != nil && [pbxIdContact intValue] == contactId) {
            return;
        }
        
        PhoneBookDetailViewController *contactDetailVC = [[PhoneBookDetailViewController alloc] initWithNibName:@"PhoneBookDetailViewController" bundle:nil];
        contactDetailVC.idContact = contactId;
        [self.navigationController pushViewController:contactDetailVC animated:TRUE];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return hSection;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, hSection)];
    headerView.backgroundColor = GRAY_240;
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, hSection)];
    descLabel.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0) blue:(50/255.0) alpha:1.0];
    descLabel.font = appDelegate.fontLargeBold;
    descLabel.backgroundColor = UIColor.clearColor;
    [headerView addSubview: descLabel];
    
    NSString *title;
    if (tableView == tbPBXContacts) {
        title = [[[pbxSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];;
    }else{
        title = [[[allSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];;
    }
    
    if ([title isEqualToString:@"z#"]) {
        descLabel.text = @"#";
    }else{
        descLabel.text = title;
    }
    
    return headerView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *tmpArr;
    if (tableView == tbPBXContacts) {
        tmpArr = [[NSMutableArray alloc] initWithArray: [[pbxSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }else{
        tmpArr = [[NSMutableArray alloc] initWithArray: [[allSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
    int index = 0;
    while (index < tmpArr.count) {
        NSString *title = [tmpArr objectAtIndex: index];
        if ([title isEqualToString:@"z#"]) {
            [tmpArr replaceObjectAtIndex:index withObject:@"#"];
            break;
        }
        index++;
    }
    return tmpArr;
}

- (void)onIconCallClicked: (UIButton *)sender
{
    [SipUtil makeCallToPhoneNumber: sender.currentTitle displayName:@""];
}

- (void)getSectionsForPBXContactsList: (NSMutableArray *)contactList {
    if (pbxSections == nil) {
        pbxSections = [[NSMutableDictionary alloc] init];
    }
    [pbxSections removeAllObjects];
    
    // Loop through the books and create our keys
    for (PBXContact *contactItem in contactList){
        NSString *c = @"";
        if (contactItem._name.length > 1) {
            c = [[contactItem._name substringToIndex: 1] uppercaseString];
            c = [AppUtil convertUTF8StringToString: c];
        }
        
        if (![listCharacter containsObject:c]) {
            c = @"z#";
        }
        
        if (![[pbxSections allKeys] containsObject: c]) {
            [pbxSections setObject:[[NSMutableArray alloc] init] forKey:c];
        }
    }
    
    // Loop again and sort the books into their respective keys
    for (PBXContact *contactItem in contactList){
        NSString *c = @"";
        if (contactItem._name.length > 1) {
            c = [[contactItem._name substringToIndex: 1] uppercaseString];
            c = [AppUtil convertUTF8StringToString: c];
        }
        if (![listCharacter containsObject:c]) {
            c = @"z#";
        }
        if (contactItem != nil) {
            [[pbxSections objectForKey: c] addObject:contactItem];
        }
    }
    // Sort each section array
    for (NSString *key in [pbxSections allKeys]){
        [[pbxSections objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"_name" ascending:YES]]];
    }
}

- (void)getSectionsForContactsList: (NSMutableArray *)contactList {
    if (allSections == nil) {
        allSections = [[NSMutableDictionary alloc] init];
    }
    [allSections removeAllObjects];
    
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
        
        if (![[allSections allKeys] containsObject: c]) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [list addObject: (__bridge id _Nonnull)(person)];
            [allSections setObject:list forKey:c];
        }else{
            NSMutableArray *list = [allSections objectForKey: c];
            [list addObject: (__bridge id _Nonnull)(person)];
            [allSections setObject:list forKey:c];
        }
    }
}

#pragma mark - UITextfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == tfSearch) {
        [self.view endEditing: TRUE];
    }
    return TRUE;
}

@end
