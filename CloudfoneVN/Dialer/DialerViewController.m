//
//  DialerViewController.m
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "DialerViewController.h"
#import "NewContactViewController.h"
#import "AllContactListViewController.h"
#import "PBXSettingViewController.h"
#import "SearchContactPopupView.h"

@interface DialerViewController ()<UITextViewDelegate, SearchContactPopupViewDelegate>{
    AppDelegate *appDelegate;
    NSMutableArray *listPhoneSearched;
    UITextView *tvSearchResult;
    
    float hStatus;
    float padding;
    float hTabbar;
    
    NSTimer *pressTimer;
    SearchContactPopupView *popupSearchContacts;
    BOOL turningOnAcc;
}

@end

@implementation DialerViewController
@synthesize viewTop, bgTop, imgTopLogo, lbAccID, lbStatus;
@synthesize viewNumber, icAddContact, tfAddress;
@synthesize viewKeypad, btnOne, btnTwo, btnThree, btnFour, btnFive, btnSix, btnSeven, btnEight, btnNine, btnZero, btnStar, btnSharp, btnCall, btnTransfer, btnAddCall, btnBack, btnHotline, btnBackspace, isTransferCall;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.hNav == 0) {
        appDelegate.hNav = self.navigationController.navigationBar.frame.size.height;
    }
    
    [self autoLayoutForView];
    
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    [viewKeypad addGestureRecognizer: tapOnScreen];
    
    lbStatus.text = @"";
    
    if (![AppUtil isNullOrEmpty:USERNAME]) {
        [[Crashlytics sharedInstance] setUserName: USERNAME];
    }
    
//    UIButton *test = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 100, 40)];
//    test.backgroundColor = UIColor.blackColor;
//    [self.view addSubview: test];
//    [test addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)testAction {
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:@"nhcla150", @"account", @"cloudcall123", @"password", @"nhanhoa1.vfone.vn", @"domain", @"51000", @"port", nil];
    [appDelegate registerSIPAccountWithInfo: info];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"nhcla150" forKey:key_login];
    [[NSUserDefaults standardUserDefaults] setObject:@"cloudcall123" forKey:key_password];
    [[NSUserDefaults standardUserDefaults] setObject:@"nhanhoa1.vfone.vn" forKey:PBX_ID];
    [[NSUserDefaults standardUserDefaults] setObject:@"51000" forKey:PBX_PORT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = TRUE;
    
    [self registerObservers];
    //  [self checkToRegisterSIPAccountForApp];
    [self checkAccountStateForApp];
    
    // invisible icon add contact & icon delete address
    icAddContact.hidden = TRUE;
    tfAddress.text = @"";
    [self showUIWithTransferState: isTransferCall];
    
    //  update token of device if not yet
    if (!appDelegate.updateTokenSuccess && ![AppUtil isNullOrEmpty: appDelegate.deviceToken]) {
        [appDelegate updateCustomerTokenIOS];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    isTransferCall = FALSE;
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (IBAction)buttonNumberPress:(UIButton *)sender {
    [self.view endEditing: TRUE];
    
    if (sender.tag == TAG_STAR_BUTTON) {
        tfAddress.text = SFM(@"%@*", tfAddress.text);
    }else if (sender.tag == TAG_HASH_BUTTON) {
        tfAddress.text = SFM(@"%@#", tfAddress.text);
    }else{
        tfAddress.text = SFM(@"%@%d", tfAddress.text, (int)sender.tag);
    }
    
    //  Show or hide "add contact" button when textfield address changed
    if (tfAddress.text.length > 0){
        icAddContact.hidden = FALSE;
    }else{
        icAddContact.hidden = TRUE;
    }
}

- (IBAction)buttonCallPress:(UIButton *)sender {
    if (tfAddress.text.length == 0) {
        NSString *phoneNumber = [DatabaseUtil getLastCallOfUser];
        if (![AppUtil isNullOrEmpty: phoneNumber])
        {
            if ([phoneNumber isEqualToString: hotline]) {
                tfAddress.text = text_hotline;
            }else{
                tfAddress.text = phoneNumber;
            }
        }
        return;
    }
    [SipUtil makeCallToPhoneNumber: tfAddress.text displayName:@""];
}

- (IBAction)buttonTransferPress:(UIButton *)sender {
    NSString *number = tfAddress.text;
    number =  [AppUtil removeAllSpecialInString: number];
    if ([AppUtil isNullOrEmpty: number]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Phone number can not empty!"] duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
        return;
    }
    [appDelegate transferCallToUserWithNumber: number];
    [appDelegate hideTransferCallView];
}

- (IBAction)buttonAddCallPress:(UIButton *)sender
{
}

- (IBAction)buttonHotlinePress:(UIButton *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:[appDelegate.localization localizedStringForKey:@"Do you want to call to hotline for assistance?"]];
    [attrTitle addAttribute:NSFontAttributeName value:[AppDelegate sharedInstance].fontNormal range:NSMakeRange(0, attrTitle.string.length)];
    [alertVC setValue:attrTitle forKey:@"attributedTitle"];
    
    UIAlertAction *btnClose = [UIAlertAction actionWithTitle:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Close"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [btnClose setValue:UIColor.redColor forKey:@"titleTextColor"];
    
    UIAlertAction *btnCall = [UIAlertAction actionWithTitle:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Call"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                {
                                    [SipUtil makeCallToPhoneNumber: hotline displayName:@""];
                                }];
    [btnCall setValue:BLUE_COLOR forKey:@"titleTextColor"];
    [alertVC addAction:btnClose];
    [alertVC addAction:btnCall];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (IBAction)buttonBackspacePress:(UIButton *)sender {
    if (tfAddress.text.length > 0) {
        tfAddress.text = [tfAddress.text substringToIndex:[tfAddress.text length] - 1];
    }
}

- (IBAction)buttonBackCallPress:(UIButton *)sender {
    [appDelegate hideTransferCallView];
}

- (IBAction)icAddContactClick:(UIButton *)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:[appDelegate.localization localizedStringForKey:@"Close"] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:TRUE completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:[appDelegate.localization localizedStringForKey:@"Create new contact"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                            {
                                [self addNewContactFromDialerView];
                            }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:[appDelegate.localization localizedStringForKey:@"Add to existing contact"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                            {
                                [self addContactToExistsContact];
                            }]];
    
    // Present action sheet.
    [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
    
    UIPopoverPresentationController *popPresenter = [actionSheet popoverPresentationController];
    popPresenter.sourceView = sender;
    popPresenter.sourceRect = sender.bounds;
    [self presentViewController:actionSheet animated:TRUE completion:nil];
}

- (void)addNewContactFromDialerView {
    NewContactViewController *newContactVC = [[NewContactViewController alloc] initWithNibName:@"NewContactViewController" bundle:nil];
    newContactVC.currentPhoneNumber = tfAddress.text;
    newContactVC.currentName = @"";
    newContactVC.hidesBottomBarWhenPushed = TRUE;
    [self hideSearchView];
    [self.navigationController pushViewController:newContactVC animated:TRUE];
}

- (void)addContactToExistsContact {
    AllContactListViewController *contactsVC = [[AllContactListViewController alloc] initWithNibName:@"AllContactListViewController" bundle:nil];
    contactsVC.phoneNumber = tfAddress.text;
    contactsVC.hidesBottomBarWhenPushed = TRUE;
    [self hideSearchView];
    [self.navigationController pushViewController:contactsVC animated:TRUE];
}

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationStateChanged:)
                                                 name:notifRegistrationStateChange object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenNetworkChanged)
                                                 name:networkChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTextForConnectingSIPAccount)
                                                 name:@"changeTextForConnectingSIPAccount" object:nil];
    
}

- (void)registrationStateChanged: (NSNotification *)notif {
    NSNumber *object = notif.object;
    if (object != nil && [object isKindOfClass:[NSNumber class]]) {
        int registrationCode = [object intValue];
        if (registrationCode == 200) {
            lbStatus.textColor = UIColor.greenColor;
            lbStatus.text = [appDelegate.localization localizedStringForKey:@"Online"];
            
            if (turningOnAcc) {
                [self progessSomethingsWhenEnableAccountSuccessfully];
            }
        }else{
            lbStatus.text = [appDelegate.localization localizedStringForKey:@"Offline"];
            lbStatus.textColor = UIColor.orangeColor;
        }
    }
}

- (void)whenNetworkChanged {
    NetworkStatus internetStatus = [appDelegate.internetReachable currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        lbStatus.text = [appDelegate.localization localizedStringForKey:@"No network"];
        lbStatus.textColor = UIColor.orangeColor;
    }else{
        //  [self checkAccountStateForApp];
    }
}

- (void)changeTextForConnectingSIPAccount {
    lbStatus.text = [appDelegate.localization localizedStringForKey:@"Connecting"];
    lbStatus.textColor = UIColor.whiteColor;
}

- (void)checkAccountStateForApp
{
    NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
    NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
    
    if (![AppUtil isNullOrEmpty: domain] && ![AppUtil isNullOrEmpty: port] && ![AppUtil isNullOrEmpty: USERNAME] && ![AppUtil isNullOrEmpty: PASSWORD])
    {
        lbAccID.text = USERNAME;
        NSString *turnOff = [[NSUserDefaults standardUserDefaults] objectForKey:TURN_OFF_ACC];
        if (![AppUtil isNullOrEmpty: turnOff] && [turnOff isEqualToString:@"1"]) {
            lbStatus.text = [appDelegate.localization localizedStringForKey:@"Disabled"];
            lbStatus.textColor = UIColor.orangeColor;
        }else{
            AccountState curState = [appDelegate checkSipStateOfAccount];
            if (curState == eAccountOn) {
                lbStatus.textColor = UIColor.greenColor;
                lbStatus.text = [appDelegate.localization localizedStringForKey:@"Online"];
            }else {
                lbStatus.text = [appDelegate.localization localizedStringForKey:@"Connecting"];
                lbStatus.textColor = UIColor.whiteColor;
            }
        }
    }else{
        lbAccID.text = @"";
        lbStatus.text = [appDelegate.localization localizedStringForKey:@"No account"];
        lbStatus.textColor = UIColor.orangeColor;
    }
}

- (void)checkToRegisterSIPAccountForApp {
    NSString *account = USERNAME;
    NSString *password = PASSWORD;
    NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
    NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
    
    if (![AppUtil isNullOrEmpty: account] && ![AppUtil isNullOrEmpty: password] && ![AppUtil isNullOrEmpty: domain] && ![AppUtil isNullOrEmpty: port])
    {
        AccountState curState = [appDelegate checkSipStateOfAccount];
        if (curState == eAccountOff) {
            lbStatus.text = [appDelegate.localization localizedStringForKey:@"Disabled"];
            lbStatus.textColor = UIColor.orangeColor;
            
        }else if (curState != eAccountOn) {
            lbStatus.text = [appDelegate.localization localizedStringForKey:@"Connecting"];
            lbStatus.textColor = UIColor.whiteColor;
            
            NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:domain, @"domain", account, @"account", password, @"password", port, @"port", nil];
            NSLog(@"-------start registration");
            [appDelegate registerSIPAccountWithInfo: info];
        }
    }
}

- (void)progessSomethingsWhenEnableAccountSuccessfully {
    //  update token of device if not yet
    if (![AppUtil isNullOrEmpty: appDelegate.deviceToken]) {
        [appDelegate updateCustomerTokenIOS];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TURN_OFF_ACC];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    turningOnAcc = FALSE;
    [ProgressHUD dismiss];
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your account was enabled successful"]
                duration:2.0 position:CSToastPositionCenter];
}

- (void)autoLayoutForView
{
    padding = 10.0;
    
    NSString *modelName = [DeviceUtil getModelsOfCurrentDevice];
    hStatus = [UIApplication sharedApplication].statusBarFrame.size.height;
    hTabbar = self.tabBarController.tabBar.frame.size.height;
    
    self.view.backgroundColor = UIColor.whiteColor;
    //  view status
    viewTop.backgroundColor = [UIColor colorWithRed:(21/255.0) green:(41/255.0) blue:(52/255.0) alpha:1.0];
    [viewTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(appDelegate.hNav + hStatus);
    }];
    
    [bgTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewTop);
    }];
    
    lbAccID.font = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
    [lbAccID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewTop).offset(hStatus);
        make.bottom.equalTo(viewTop);
        make.centerX.equalTo(viewTop.mas_centerX);
        make.width.mas_equalTo(120);
    }];
    
    [imgTopLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewTop).offset(padding);
        make.centerY.equalTo(lbAccID.mas_centerY);
        make.width.height.mas_equalTo(30.0);
    }];

    //  status label
    lbStatus.font = appDelegate.fontNormal;
    [lbStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(lbAccID);
        make.left.equalTo(lbAccID.mas_right);
        make.right.equalTo(viewTop).offset(-padding);
    }];
    UITapGestureRecognizer *tapOnStatus = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTappedOnStatusAccount)];
    lbStatus.userInteractionEnabled = TRUE;
    [lbStatus addGestureRecognizer: tapOnStatus];

    //  Number view
    float hNumber = 100.0;
    float hTextField = 60.0;
    if ([modelName isEqualToString: IphoneX_1] || [modelName isEqualToString: IphoneX_2] || [modelName isEqualToString: IphoneXR] || [modelName isEqualToString: IphoneXS] || [modelName isEqualToString: IphoneXS_Max1] || [modelName isEqualToString: IphoneXS_Max2] || [modelName isEqualToString: simulator])
    {
        hNumber = 120.0;
        hTextField = 80.0;
    }

    [viewNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(viewTop.mas_bottom);
        make.height.mas_equalTo(hNumber);
    }];

    tfAddress.adjustsFontSizeToFitWidth = TRUE;
    [tfAddress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewNumber).offset(10);
        make.left.equalTo(self.view).offset(80);
        make.right.equalTo(self.view).offset(-80);
        make.height.mas_equalTo(hTextField);
    }];
    tfAddress.keyboardType = UIKeyboardTypePhonePad;
    tfAddress.enabled = YES;
    tfAddress.textAlignment = NSTextAlignmentCenter;
    tfAddress.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:45.0];
    tfAddress.adjustsFontSizeToFitWidth = TRUE;
    [tfAddress addTarget:self
                      action:@selector(addressfieldDidChanged:)
            forControlEvents:UIControlEventEditingChanged];

    tvSearchResult = [[UITextView alloc] init];
    tvSearchResult.backgroundColor = UIColor.clearColor;
    tvSearchResult.editable = NO;
    tvSearchResult.hidden = YES;
    tvSearchResult.delegate = self;
    [viewNumber addSubview: tvSearchResult];

    [tvSearchResult mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewNumber).offset(10.0);
        make.right.equalTo(viewNumber).offset(-10.0);
        make.top.equalTo(tfAddress.mas_bottom);
        make.height.mas_equalTo(30.0);
    }];
    //  tvSearchResult.linkTextAttributes = @{NSUnderlineStyleAttributeName: NSUnderlineStyleNone};

    [icAddContact mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewNumber).offset(10.0);
        make.centerY.equalTo(tfAddress.mas_centerY).offset(-3);
        make.width.height.mas_equalTo(40.0);
    }];


    //  Number keypad
    float wIcon = [DeviceUtil getSizeOfKeypadButtonForDevice: modelName];
    float spaceMarginY = [DeviceUtil getSpaceYBetweenKeypadButtonsForDevice: modelName];
    float spaceMarginX = [DeviceUtil getSpaceXBetweenKeypadButtonsForDevice: modelName];

    [viewKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewNumber.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-hTabbar);
    }];

    //  7, 8, 9
    btnOne.layer.cornerRadius = btnTwo.layer.cornerRadius = btnThree.layer.cornerRadius = btnFour.layer.cornerRadius = btnFive.layer.cornerRadius = btnSix.layer.cornerRadius = btnSeven.layer.cornerRadius = btnEight.layer.cornerRadius = btnNine.layer.cornerRadius = btnZero.layer.cornerRadius = btnStar.layer.cornerRadius = btnSharp.layer.cornerRadius = btnCall.layer.cornerRadius = btnTransfer.layer.cornerRadius = btnAddCall.layer.cornerRadius = btnHotline.layer.cornerRadius = btnBack.layer.cornerRadius = btnBackspace.layer.cornerRadius = wIcon/2;
    
    btnOne.clipsToBounds = btnTwo.clipsToBounds = btnThree.clipsToBounds = btnFour.clipsToBounds = btnFive.clipsToBounds = btnSix.clipsToBounds = btnSeven.clipsToBounds = btnEight.clipsToBounds = btnNine.clipsToBounds = btnZero.clipsToBounds =  btnStar.clipsToBounds = btnSharp.clipsToBounds = btnCall.clipsToBounds = btnTransfer.clipsToBounds = btnAddCall.clipsToBounds = btnHotline.clipsToBounds = btnBack.clipsToBounds = btnBackspace.clipsToBounds = TRUE;
    
    [btnEight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.centerY.equalTo(viewKeypad.mas_centerY);
        make.width.height.mas_equalTo(wIcon);
    }];

    [btnSeven mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnEight.mas_top);
        make.right.equalTo(btnEight.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];

    [btnNine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnEight.mas_top);
        make.left.equalTo(btnEight.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];

    //  4, 5, 6
    [btnFive mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnEight.mas_top).offset(-spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];

    [btnFour mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnFive.mas_top);
        make.right.equalTo(btnFive.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];

    [btnSix mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnFive.mas_top);
        make.left.equalTo(btnFive.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];

    //  1, 2, 3
    [btnTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnFive.mas_top).offset(-spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];

    [btnOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnTwo.mas_top);
        make.right.equalTo(btnTwo.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];

    [btnThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnTwo.mas_top);
        make.left.equalTo(btnTwo.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];

    //  *, 0, #
    [btnZero mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnEight.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];

    [btnStar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnZero.mas_top);
        make.right.equalTo(btnZero.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];

    [btnSharp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnZero.mas_top);
        make.left.equalTo(btnZero.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];

    //  fifth layer
    [btnCall setImage:[UIImage imageNamed:@"call_hover"] forState:UIControlStateHighlighted];
    [btnCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnZero.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];

    //  transfer button
    btnTransfer.hidden = TRUE;
    [btnTransfer setImage:[UIImage imageNamed:@"transfer_call_hover"] forState:UIControlStateHighlighted];
    btnTransfer.backgroundColor = GRAY_235;
    [btnTransfer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(btnCall);
    }];

    //  Add call button
    btnAddCall.hidden = TRUE;
    btnAddCall.backgroundColor = GRAY_235;
    [btnAddCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(btnCall);
    }];

    [btnHotline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCall.mas_top);
        make.right.equalTo(btnCall.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];

    [btnBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(btnHotline);
    }];

    [btnBackspace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCall.mas_top);
        make.left.equalTo(btnCall.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    UILongPressGestureRecognizer *backspaceLongGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onBackspaceLongClick:)];
    [btnBackspace addGestureRecognizer:backspaceLongGesture];
    
    UILongPressGestureRecognizer *zeroLongGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onZeroLongClick:)];
    [btnZero addGestureRecognizer:zeroLongGesture];
}

- (void)onZeroLongClick:(id)sender {
    // replace last character with a '+'
    NSString *newAddress = [[tfAddress.text substringToIndex:tfAddress.text.length - 1] stringByAppendingString:@"+"];
    tfAddress.text = newAddress;
}

- (void)onBackspaceLongClick:(id)sender {
    [self hideSearchView];
}

- (void)dismissKeyboards {
    [self.view endEditing: TRUE];
}

- (void)hideSearchView {
    tfAddress.text = @"";
    icAddContact.hidden = TRUE;
    tvSearchResult.hidden = TRUE;
}

- (void)searchPhoneBookWithThread {
    if (!appDelegate.contactLoaded) {
        return;
    }
    //  ----
    
    NSString *searchStr = tfAddress.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //  remove data before search
        if (listPhoneSearched == nil) {
            listPhoneSearched = [[NSMutableArray alloc] init];
        }
        [listPhoneSearched removeAllObjects];
        
        NSArray *searchArr = [self searchAllContactsWithString:searchStr inList:appDelegate.listInfoPhoneNumber];
        if (searchArr.count > 0) {
            [listPhoneSearched addObjectsFromArray: searchArr];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self searchContactDone];
        });
    });
}

- (NSArray *)searchAllContactsWithString: (NSString *)search inList: (NSArray *)list {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ OR number CONTAINS[cd] %@ OR nameForSearch CONTAINS[cd] %@", search, search, search];
    NSArray *filter = [list filteredArrayUsingPredicate: predicate];
    return filter;
}

- (void)searchContactDone
{
    if (tfAddress.text.length == 0) {
        icAddContact.hidden = TRUE;
    }else{
        icAddContact.hidden = FALSE;
        
        if (listPhoneSearched.count > 0) {
            tvSearchResult.hidden = FALSE;
            tvSearchResult.attributedText = [ContactsUtil getSearchValueFromResultForNewSearchMethod: listPhoneSearched];
        }else{
            tvSearchResult.hidden = TRUE;
        }
    }
}

- (void)addressfieldDidChanged: (UITextField *)textfield {
    if ([textfield.text isEqualToString:@""]) {
        icAddContact.hidden = TRUE;
        tvSearchResult.hidden = TRUE;
        
    }else{
        icAddContact.hidden = FALSE;
        
        [pressTimer invalidate];
        pressTimer = nil;
        pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                    selector:@selector(searchPhoneBookWithThread)
                                                    userInfo:nil repeats:false];
    }
}

- (void)showUIWithTransferState: (BOOL)forTransfer {
    if (forTransfer) {
        btnHotline.hidden = btnCall.hidden = TRUE;
        btnBack.hidden = btnTransfer.hidden = FALSE;
    }else{
        btnHotline.hidden = btnCall.hidden = FALSE;
        btnBack.hidden = btnTransfer.hidden = TRUE;
    }
}

- (void)whenTappedOnStatusAccount
{
    if (![DeviceUtil checkNetworkAvailable]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }

    //  Không cho refresh registration nếu đang trong cuộc gọi
    BOOL callIsConnected = [appDelegate isCallWasConnected];
    if (callIsConnected) {
        return;
    }
    
    AccountState curState = [appDelegate checkSipStateOfAccount];
    //  No account
    if (curState == eAccountNone) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];

        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:[appDelegate.localization localizedStringForKey:@"You have not set up an account yet. Do you want to setup now?"]];
        [attrTitle addAttribute:NSFontAttributeName value:appDelegate.fontLarge range:NSMakeRange(0, attrTitle.string.length)];
        [alertVC setValue:attrTitle forKey:@"attributedTitle"];

        UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
        [btnCancel setValue:UIColor.redColor forKey:@"titleTextColor"];

        UIAlertAction *btnGoSettings = [UIAlertAction actionWithTitle:[appDelegate.localization localizedStringForKey:@"Go to settings"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                   {
                                       [self goToSettingsAccountView];
                                   }];
        [btnGoSettings setValue:BLUE_COLOR forKey:@"titleTextColor"];
        [alertVC addAction:btnCancel];
        [alertVC addAction:btnGoSettings];
        [self presentViewController:alertVC animated:YES completion:nil];
        
        return;
    }
    
    //  account was disabled
    if (curState == eAccountDis) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];

        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:[appDelegate.localization localizedStringForKey:@"Do you want to enable this account?"]];
        [attrTitle addAttribute:NSFontAttributeName value:appDelegate.fontLarge range:NSMakeRange(0, attrTitle.string.length)];
        [alertVC setValue:attrTitle forKey:@"attributedTitle"];

        UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:[appDelegate.localization localizedStringForKey:@"No"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
        [btnCancel setValue:UIColor.redColor forKey:@"titleTextColor"];

        UIAlertAction *btnEnable = [UIAlertAction actionWithTitle:[appDelegate.localization localizedStringForKey:@"Yes"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                        {
                                            [self tryToEnableSIPAccount];
                                        }];
        [btnEnable setValue:BLUE_COLOR forKey:@"titleTextColor"];
        [alertVC addAction:btnCancel];
        [alertVC addAction:btnEnable];
        [self presentViewController:alertVC animated:YES completion:nil];
        
        return;
    }
    
    //  No account
    lbStatus.text = [appDelegate.localization localizedStringForKey:@"Connecting"];
    lbStatus.textColor = UIColor.whiteColor;
    
    [appDelegate refreshSIPRegistration];
}

- (void)goToSettingsAccountView {
    PBXSettingViewController *settingsAccVC = [[PBXSettingViewController alloc] initWithNibName:@"PBXSettingViewController" bundle:nil];
    settingsAccVC.hidesBottomBarWhenPushed = TRUE;
    [self.navigationController pushViewController:settingsAccVC animated:TRUE];
}

- (void)tryToEnableSIPAccount {
    [self.view endEditing: TRUE];
    
    BOOL networkReady = [DeviceUtil checkNetworkAvailable];
    if (!networkReady) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
    NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
    
    if (![AppUtil isNullOrEmpty: domain] && ![AppUtil isNullOrEmpty: port] && ![AppUtil isNullOrEmpty: USERNAME] && ![AppUtil isNullOrEmpty: PASSWORD])
    {
        [ProgressHUD backgroundColor: ProgressHUD_BG];
        [ProgressHUD show:[appDelegate.localization localizedStringForKey:@"Please wait..."] Interaction:NO];
        
        turningOnAcc = TRUE;
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:domain, @"domain", USERNAME, @"account", PASSWORD, @"password", port, @"port", nil];
        [appDelegate registerSIPAccountWithInfo: info];
    }else{
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Not enough informations to enable your account"] duration:3.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
    }
}

#pragma mark - UITextview delegate
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    // Call your method here.
    if (![URL.absoluteString containsString:@"others"]) {
        tfAddress.text = URL.absoluteString;
        tvSearchResult.hidden = YES;
    }else{
        float totalHeight = listPhoneSearched.count * 60.0;
        if (totalHeight > SCREEN_HEIGHT - 70.0*2) {
            totalHeight = SCREEN_HEIGHT - 70.0*2;
        }
        popupSearchContacts = [[SearchContactPopupView alloc] initWithFrame:CGRectMake(30.0, (SCREEN_HEIGHT-totalHeight)/2, SCREEN_WIDTH-60.0, totalHeight)];
        popupSearchContacts.contacts = listPhoneSearched;
        [popupSearchContacts.tbContacts reloadData];
        popupSearchContacts.delegate = self;
        [popupSearchContacts showInView:appDelegate.window animated:YES];
    }
    return NO;
}

- (void)selectContactFromSearchPopup:(NSString *)phoneNumber {
    tfAddress.text = phoneNumber;
    tvSearchResult.hidden = TRUE;
}

@end
