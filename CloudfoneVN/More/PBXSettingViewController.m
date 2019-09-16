//
//  PBXSettingViewController.m
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "PBXSettingViewController.h"
#import "CustomSwitchButton.h"
#import "WebServices.h"
#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface PBXSettingViewController ()<WebServicesDelegate, CustomSwitchButtonDelegate, UITextFieldDelegate, QRCodeReaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    AppDelegate *appDelegate;
    CustomSwitchButton *swAccount;
    WebServices *webService;
    NSString *domainValue;
    NSString *portValue;
    
    QRCodeReaderViewController *scanQRCodeVC;
    UIButton *btnScanFromPhoto;
    UIColor *bgClear;
    UIColor *bgSave;
    
    BOOL turningOffAcc;
    BOOL turningOnAcc;
}

@end

@implementation PBXSettingViewController
@synthesize scvContent, lbTitle, lbSepa, lbServerID, tfServerID, lbAccount, tfAccount, lbPassword, tfPassword, btnSave, btnClear, icShowPass;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self autoLayoutForMainView];
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer: tapOnScreen];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    self.navigationController.navigationBarHidden = FALSE;
    [self addRightBarButtonForNavigationBar];
    [self showContentForView];
    
    turningOnAcc = turningOffAcc = FALSE;
    
    if (webService == nil) {
        webService = [[WebServices alloc] init];
        webService.delegate = self;
    }
    [self showSIPAccountInformations];
    
    [self registerObservers];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenClearSIPAccountSuccessfully)
                                                 name:clearSIPAccountSuccessfully object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)registerObserverForSIPStateChange: (BOOL)registerObserver {
    if (registerObserver) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationStateChanged:)
                                                     name:notifRegistrationStateChange object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:notifRegistrationStateChange object:nil];
    }
}

- (void)dismissKeyboard {
    [self.view endEditing: TRUE];
}

- (void)keyboardWillShow:(NSNotification *)notif {
    float keyboardHeight = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [scvContent mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-keyboardHeight);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

//  Ẩn bàn phím
- (void)keyboardDidHide: (NSNotification *) notif{
    [scvContent mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)showSIPAccountInformations {
    NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
    tfServerID.text = (![AppUtil isNullOrEmpty: server]) ? server : @"";
    
    tfAccount.text = (![AppUtil isNullOrEmpty: USERNAME]) ? USERNAME : @"";
    tfPassword.text = (![AppUtil isNullOrEmpty: PASSWORD]) ? PASSWORD : @"";
}

- (void)showContentForView {
    self.title = [appDelegate.localization localizedStringForKey:@"PBX account"];
    
    lbTitle.text = [appDelegate.localization localizedStringForKey:@"PBX"];
    lbServerID.text = [appDelegate.localization localizedStringForKey:@"Server ID"];
    lbAccount.text = [appDelegate.localization localizedStringForKey:@"Account"];
    lbPassword.text = [appDelegate.localization localizedStringForKey:@"Password"];
    
    [btnClear setTitle:[appDelegate.localization localizedStringForKey:@"Clear"]
               forState:UIControlStateNormal];
    [btnSave setTitle:[appDelegate.localization localizedStringForKey:@"Save"]
              forState:UIControlStateNormal];
}

- (void)addRightBarButtonForNavigationBar {
    UIView *viewQR = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    viewQR.backgroundColor = UIColor.clearColor;
    
    UIButton *btnQR =  [UIButton buttonWithType:UIButtonTypeCustom];
    btnQR.imageEdgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
    btnQR.frame = CGRectMake(15, 0, 45, 45);
    btnQR.backgroundColor = UIColor.clearColor;
    [btnQR setImage:[UIImage imageNamed:@"qr-code-scan"] forState:UIControlStateNormal];
    [btnQR addTarget:self action:@selector(buttonQRCodeScanPress) forControlEvents:UIControlEventTouchUpInside];
    [viewQR addSubview: btnQR];
    
    UIBarButtonItem *btnQRBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: viewQR];
    self.navigationItem.rightBarButtonItem =  btnQRBarButtonItem;
    
    self.navigationItem.rightBarButtonItems = @[btnQRBarButtonItem];
}

- (void)autoLayoutForMainView
{
    //  [Khai le - 22/10/2018]: detect with iPhone 5, 5s, 5c and SE
    //  self.view.backgroundColor = GRAY_230;
    
    float hLabel = 35.0;
    float hButton = 45.0;
    float mTop = 15.0;
    float hTextfield = 40.0;
    if (SCREEN_WIDTH == 320) {
        hTextfield = 35.0;
        hLabel = 30.0;
    }
    
    float marginX = 10.0;
    float hContent = 60.0 + 1.0 + (mTop + hLabel + hTextfield) + (mTop + hLabel + hTextfield) + (mTop + hLabel + hTextfield) + (2*mTop + hButton + 2*mTop);
    scvContent.contentSize = CGSizeMake(SCREEN_WIDTH, hContent);
    
    [scvContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    lbTitle.textColor = [UIColor colorWithRed:(80/255.0) green:(80/255.0) blue:(80/255.0) alpha:1.0];
    [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(scvContent);
        make.left.equalTo(scvContent).offset(marginX);
        make.width.mas_equalTo(SCREEN_WIDTH-2*marginX);
        make.height.mas_equalTo(60.0);
    }];
    
    BOOL state = FALSE;
    BOOL isEnabled;
    AccountState accState = [appDelegate checkSipStateOfAccount];
    if (accState == eAccountOn) {
        isEnabled = TRUE;
        state = TRUE;
    }else if (accState == eAccountOff){
        isEnabled = TRUE;
        state = FALSE;
    }else{
        isEnabled = FALSE;
        state = FALSE;
    }
    
    float tmpWidth = 70.0;
    swAccount = [[CustomSwitchButton alloc] initWithState:state frame:CGRectMake(SCREEN_WIDTH-marginX-tmpWidth, (60.0-31.0)/2, tmpWidth, 31.0)];
    swAccount.delegate = self;
    [self.view addSubview: swAccount];
    
    lbSepa.backgroundColor = GRAY_230;
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbTitle.mas_bottom);
        make.left.right.equalTo(lbTitle);
        make.height.mas_equalTo(1.0);
    }];
    
    //  server ID
    lbServerID.textColor = lbTitle.textColor;
    [lbServerID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbSepa.mas_bottom).offset(mTop);
        make.left.right.equalTo(lbSepa);
        make.height.mas_equalTo(hLabel);
    }];
    
    tfServerID.delegate = tfAccount.delegate = tfPassword.delegate = self;
    tfServerID.returnKeyType = UIReturnKeyNext;
    
    tfServerID.borderStyle = UITextBorderStyleNone;
    tfServerID.layer.cornerRadius = 3.0;
    tfServerID.layer.borderWidth = 1.0;
    tfServerID.layer.borderColor = lbSepa.backgroundColor.CGColor;
    tfServerID.font = appDelegate.fontNormalBold;
    [tfServerID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbServerID.mas_bottom);
        make.left.right.equalTo(lbServerID);
        make.height.mas_equalTo(hTextfield);
    }];
    
    tfServerID.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, hTextfield)];
    tfServerID.leftViewMode = UITextFieldViewModeAlways;
    
    //  account
    lbAccount.textColor = lbTitle.textColor;
    [lbAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfServerID.mas_bottom).offset(mTop);
        make.left.right.equalTo(tfServerID);
        make.height.mas_equalTo(lbServerID.mas_height);
    }];
    
    tfAccount.returnKeyType = UIReturnKeyNext;
    tfAccount.borderStyle = UITextBorderStyleNone;
    tfAccount.layer.cornerRadius = 3.0;
    tfAccount.layer.borderWidth = 1.0;
    tfAccount.layer.borderColor = lbSepa.backgroundColor.CGColor;
    tfAccount.font = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
    [tfAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbAccount.mas_bottom);
        make.left.right.equalTo(lbAccount);
        make.height.equalTo(tfServerID.mas_height);
    }];
    tfAccount.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, hTextfield)];
    tfAccount.leftViewMode = UITextFieldViewModeAlways;
    
    //  password
    lbPassword.textColor = lbTitle.textColor;
    [lbPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfAccount.mas_bottom).offset(mTop);
        make.left.right.equalTo(tfAccount);
        make.height.mas_equalTo(lbServerID.mas_height);
    }];
    
    tfPassword.returnKeyType = UIReturnKeyDone;
    tfPassword.borderStyle = UITextBorderStyleNone;
    tfPassword.layer.cornerRadius = 3.0;
    tfPassword.layer.borderWidth = 1.0;
    tfPassword.layer.borderColor = lbSepa.backgroundColor.CGColor;
    tfPassword.font = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
    [tfPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbPassword.mas_bottom);
        make.left.right.equalTo(lbPassword);
        make.height.equalTo(tfServerID.mas_height);
    }];
    tfPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, hTextfield)];
    tfPassword.leftViewMode = UITextFieldViewModeAlways;
    
    icShowPass.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [icShowPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(tfPassword);
        make.width.mas_equalTo(hTextfield);
    }];
    
    //  footer button
    bgClear = [UIColor colorWithRed:(248/255.0) green:(83/255.0) blue:(86/255.0) alpha:1.0];
    btnClear.clipsToBounds = TRUE;
    btnClear.layer.cornerRadius = hButton/2;
    [btnClear setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnClear.titleLabel.font = appDelegate.fontNormal;
    btnClear.layer.borderWidth = 1.0;
    btnClear.layer.borderColor = bgClear.CGColor;
    btnClear.backgroundColor = bgClear;
    [btnClear mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfPassword.mas_bottom).offset(mTop);
        make.left.equalTo(tfPassword);
        make.right.equalTo(lbTitle.mas_centerX).offset(-20);
        make.height.mas_equalTo(hButton);
    }];
    
    //  save button
    bgSave = [UIColor colorWithRed:(27/255.0) green:(104/255.0) blue:(213/255.0) alpha:1.0];
    btnSave.clipsToBounds = TRUE;
    btnSave.layer.cornerRadius = hButton/2;
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSave.layer.borderColor = bgSave.CGColor;
    btnSave.backgroundColor = bgSave;
    btnSave.titleLabel.font = appDelegate.fontNormal;
    [btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(btnClear);
        make.left.equalTo(lbTitle.mas_centerX).offset(20);
        make.right.equalTo(tfPassword.mas_right);
    }];
}

- (IBAction)buttonClearPress:(UIButton *)sender {
    sender.backgroundColor = UIColor.whiteColor;
    [sender setTitleColor:bgClear forState:UIControlStateNormal];
    [self performSelector:@selector(checkToClearSIPAccount) withObject:nil afterDelay:0.1];
}

- (IBAction)buttonSavePress:(UIButton *)sender {
    [self.view endEditing: TRUE];
    
    sender.backgroundColor = UIColor.whiteColor;
    [sender setTitleColor:bgSave forState:UIControlStateNormal];
    [self performSelector:@selector(checkToSaveSIPAccount) withObject:nil afterDelay:0.1];
}

- (IBAction)icShowPassClick:(UIButton *)sender {
    if (tfPassword.secureTextEntry) {
        tfPassword.secureTextEntry = FALSE;
        [icShowPass setImage:[UIImage imageNamed:@"hide_pass"] forState:UIControlStateNormal];
    }else{
        tfPassword.secureTextEntry = TRUE;
        [icShowPass setImage:[UIImage imageNamed:@"show_pass"] forState:UIControlStateNormal];
    }
}

- (void)checkToSaveSIPAccount {
    btnSave.backgroundColor = bgSave;
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    BOOL networkReady = [DeviceUtil checkNetworkAvailable];
    if (!networkReady) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    if ([tfServerID.text isEqualToString:@""]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please enter server ID"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    if ([tfAccount.text isEqualToString:@""]){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please enter account ID"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    if ([tfPassword.text isEqualToString:@""]){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please enter password"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    //  start register sip account
    AccountState curState = [appDelegate checkSipStateOfAccount];
    if (curState == eAccountOn && [USERNAME isEqualToString: tfAccount.text]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"This accout is being used"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    [ProgressHUD backgroundColor: ProgressHUD_BG];
    [ProgressHUD show:[appDelegate.localization localizedStringForKey:@"Please wait..."] Interaction:NO];
    
    BOOL result = [appDelegate deleteSIPAccountDefault];
    if (result) {
        [self getInfoForPBXWithServerName: tfServerID.text];
        
    }else{
        [self.view makeToast:@"Can not remove current account. Please try again!" duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
    }
}

- (void)checkToClearSIPAccount {
    btnClear.backgroundColor = bgClear;
    [btnClear setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    AccountState sipState = [appDelegate checkSipStateOfAccount];
    if (sipState == eAccountNone) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"You have not signed your account yet"] duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
        return;
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:[appDelegate.localization localizedStringForKey:@"You will not receive any call until re-setup your account again. Are you sure?"]];
    [attrTitle addAttribute:NSFontAttributeName value:appDelegate.fontLarge range:NSMakeRange(0, attrTitle.string.length)];
    [alertVC setValue:attrTitle forKey:@"attributedTitle"];
    
    UIAlertAction *btnClose = [UIAlertAction actionWithTitle:[appDelegate.localization localizedStringForKey:@"Close"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    [btnClose setValue:BLUE_COLOR forKey:@"titleTextColor"];
    
    UIAlertAction *btnClear = [UIAlertAction actionWithTitle:[appDelegate.localization localizedStringForKey:@"Clear"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                               {
                                   [ProgressHUD backgroundColor: ProgressHUD_BG];
                                   [ProgressHUD show:[appDelegate.localization localizedStringForKey:@"Clearing account..."] Interaction:NO];
                                   
                                   appDelegate.clearingSIP = TRUE;
                                   [appDelegate deleteSIPAccountDefault];
                               }];
    [btnClear setValue:UIColor.redColor forKey:@"titleTextColor"];
    [alertVC addAction:btnClose];
    [alertVC addAction:btnClear];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)registrationStateChanged: (NSNotification *)notif {
    NSNumber *object = notif.object;
    if ([object isKindOfClass:[NSNumber class]]) {
        int registrationCode = [object intValue];
        if (object.intValue == 200) {
            //  Remove observer để tránh trường hợp refresh register mà show thông báo
            [self registerObserverForSIPStateChange: FALSE];
            
            //  registration successfully
            if (![AppUtil isNullOrEmpty: appDelegate.deviceToken] && ![tfServerID.text isEqualToString:@""] && ![tfAccount.text isEqualToString:@""]) {
                [self updateCustomerTokenIOSForPBX: tfServerID.text andUsername: tfAccount.text withTokenValue:appDelegate.deviceToken];
            }else{
                if (turningOnAcc) {
                    [self whenTurnOnPBXSuccessfully];
                }else{
                    [self whenRegisterPBXSuccessfully];
                }
            }
            
        }else{
            //  Remove observer để tránh trường hợp refresh register mà show thông báo
            [self registerObserverForSIPStateChange: FALSE];
            
            [ProgressHUD dismiss];
            [appDelegate deleteSIPAccountDefault];
            
            if (registrationCode == 401) {
                //  PJSIP_SC_UNAUTHORIZED
                [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your account is incorrect. Please check again!"] duration:3.0 position:CSToastPositionCenter];
            }else if (registrationCode == 408) {
                [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Registration timeout!"] duration:3.0 position:CSToastPositionCenter];
            }
            else{
                [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Failed to login. Please check again!"] duration:3.0 position:CSToastPositionCenter];
            }
            //  registration failed
            [self failedToRegisterToSIPAccount];
        }
    }
}

- (void)failedToRegisterToSIPAccount {
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_SERVER];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_ID];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_PORT];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_login];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_password];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)whenRegisterPBXSuccessfully
{
    [ProgressHUD dismiss];
    
    [[NSUserDefaults standardUserDefaults] setObject:tfServerID.text forKey:PBX_SERVER];
    [[NSUserDefaults standardUserDefaults] setObject:domainValue forKey:PBX_ID];
    [[NSUserDefaults standardUserDefaults] setObject:portValue forKey:PBX_PORT];
    [[NSUserDefaults standardUserDefaults] setObject:tfAccount.text forKey:key_login];
    [[NSUserDefaults standardUserDefaults] setObject:tfPassword.text forKey:key_password];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [swAccount setUIForEnableStateWithActionTarget: FALSE];
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your account was registered successful."] duration:2.0 position:CSToastPositionCenter];
    [self performSelector:@selector(dismissCurrentView) withObject:nil afterDelay:2.0];
    
    [[Crashlytics sharedInstance] setUserName: tfAccount.text];
}

- (void)dismissCurrentView {
    [self.navigationController popViewControllerAnimated: TRUE];
}

- (void)getQRCodeContentFromImage: (UIImage *)image {
    NSArray *qrcodeContent = [self detectQRCode: image];
    if (qrcodeContent != nil && qrcodeContent.count > 0) {
        for (CIQRCodeFeature* qrFeature in qrcodeContent)
        {
            [ProgressHUD backgroundColor: ProgressHUD_BG];
            [ProgressHUD show:[appDelegate.localization localizedStringForKey:@"Please wait..."] Interaction:NO];
            
            [self getPBXInformationWithHashString: qrFeature.messageString];
            break;
        }
    }else{
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"QRCode image is invalid"] duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
    }
}

- (NSArray *)detectQRCode:(UIImage *) image
{
    @autoreleasepool {
        CIImage* ciImage = [[CIImage alloc] initWithCGImage: image.CGImage]; // to use if the underlying data is a CGImage
        NSDictionary* options;
        CIContext* context = [CIContext context];
        options = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh }; // Slow but thorough
        //options = @{ CIDetectorAccuracy : CIDetectorAccuracyLow}; // Fast but superficial
        
        CIDetector* qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                    context:context
                                                    options:options];
        if ([[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation] == nil) {
            options = @{ CIDetectorImageOrientation : @1};
        } else {
            options = @{ CIDetectorImageOrientation : [[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation]};
        }
        NSArray * features = [qrDetector featuresInImage:ciImage
                                                 options:options];
        return features;
    }
}

#pragma mark - Webservice Delegate

- (void)getInfoForPBXWithServerName: (NSString *)serverName
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:serverName forKey:@"ServerName"];
    [webService callWebServiceWithLink:getServerInfoFunc withParams:jsonDict];
}

- (void)updateCustomerTokenIOSForPBX: (NSString *)pbxService andUsername: (NSString *)pbxUsername withTokenValue: (NSString *)tokenValue
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:@"" forKey:@"UserName"];
    [jsonDict setObject:tokenValue forKey:@"IOSToken"];
    [jsonDict setObject:pbxService forKey:@"PBXID"];
    [jsonDict setObject:pbxUsername forKey:@"PBXExt"];
    
    [webService callWebServiceWithLink:ChangeCustomerIOSToken withParams:jsonDict];
}

- (void)getPBXInformationWithHashString: (NSString *)hashString
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:hashString forKey:@"HashString"];
    
    [webService callWebServiceWithLink:DecryptRSA withParams:jsonDict];
}

- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error
{
    [ProgressHUD dismiss];
    
    if ([link isEqualToString:getServerInfoFunc]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Can not get sign in informations. Please try again!"] duration:2.0 position:CSToastPositionCenter];
        
    }else if ([link isEqualToString: ChangeCustomerIOSToken]){
        if (appDelegate.clearingSIP) {
            [self finishClearSIPAccountSuccessfully];
            
        }else if (turningOffAcc) {
            [self whenTurnOffPBXSuccessfully];
            
        }else if (turningOnAcc) {
            [self whenTurnOnPBXSuccessfully];
            
        }else{
            [self whenRegisterPBXSuccessfully];
        }
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data
{
    if ([link isEqualToString:getServerInfoFunc]) {
        [self startLoginPBXWithInfo: data];
        
    }else if ([link isEqualToString: ChangeCustomerIOSToken]){
        if (appDelegate.clearingSIP) {
            [self finishClearSIPAccountSuccessfully];
            
        }else if (turningOffAcc) {
            [self whenTurnOffPBXSuccessfully];
            
        }else if (turningOnAcc) {
            [self whenTurnOnPBXSuccessfully];
            
        }else{
            [self whenRegisterPBXSuccessfully];
        }
    }else if ([link isEqualToString: DecryptRSA]) {
        [self receiveDataFromQRCode: data];
    }
}

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    NSLog(@"%d", responeCode);
}

- (void)startLoginPBXWithInfo: (NSDictionary *)info
{
    domainValue = [info objectForKey:@"ipAddress"];
    portValue = [info objectForKey:@"port"];
    NSString *server = [info objectForKey:@"serverName"];
    
    if (![AppUtil isNullOrEmpty: domainValue] && ![AppUtil isNullOrEmpty: portValue] && ![AppUtil isNullOrEmpty: server])
    {
        [self registerObserverForSIPStateChange: TRUE];
        //  Nếu port của tài khoản hiện tại khác port mới thì cần start lại pjsua
        NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
        if (![AppUtil isNullOrEmpty: port] && [port isEqualToString: portValue]) {
            [[NSUserDefaults standardUserDefaults] setObject:portValue forKey:PBX_PORT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [appDelegate restartPjsuaIfNeed];
        }
        
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:domainValue, @"domain", tfAccount.text, @"account", tfPassword.text, @"password", portValue, @"port", nil];
        [appDelegate registerSIPAccountWithInfo:info];
        
    }else{
        [ProgressHUD dismiss];
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your information again!"] duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)receiveDataFromQRCode: (NSDictionary *)data
{
    if (data != nil) {
        NSString *result = [data objectForKey:@"result"];
        if (result != nil && [result isEqualToString:@"success"]) {
            NSString *message = [data objectForKey:@"message"];
            [self loginPBXFromStringHashCodeResult: message];
        }else{
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"QRCode image is invalid"] duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
        }
        return;
    }
    [ProgressHUD dismiss];
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"QRCode image is invalid"] duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
}

- (void)loginPBXFromStringHashCodeResult: (NSString *)message {
    NSArray *tmpArr = [message componentsSeparatedByString:@"/"];
    if (tmpArr.count == 3)
    {
        NSString *server = [tmpArr objectAtIndex: 0];
        NSString *account = [tmpArr objectAtIndex: 1];
        NSString *password = [tmpArr objectAtIndex: 2];
        
        if (![AppUtil isNullOrEmpty: server] && ![AppUtil isNullOrEmpty: account] && ![AppUtil isNullOrEmpty: password])
        {
            //  start register sip account
            AccountState curState = [appDelegate checkSipStateOfAccount];
            if (curState == eAccountOn && [USERNAME isEqualToString: account]) {
                [self.view makeToast:[appDelegate.localization localizedStringForKey:@"This accout is being used"] duration:2.0 position:CSToastPositionCenter];
                return;
            }
            
            tfAccount.text = account;
            tfServerID.text = server;
            tfPassword.text = password;
            
            BOOL result = [appDelegate deleteSIPAccountDefault];
            if (result) {
                [self getInfoForPBXWithServerName: server];
                
            }else{
                [self.view makeToast:@"Can not remove current account. Please try again!" duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
            }
        }
    }else{
        [ProgressHUD dismiss];
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"QRCode image is invalid"] duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
    }
}

- (void)whenClearSIPAccountSuccessfully {
    //  clear token sau khi đã remove SIP ACCOUNT
    NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
    if (![AppUtil isNullOrEmpty: server] && ![AppUtil isNullOrEmpty: USERNAME]) {
        [self updateCustomerTokenIOSForPBX:server andUsername:USERNAME withTokenValue:@""];
        
    }else{
        [self finishClearSIPAccountSuccessfully];
    }
}

- (void)finishClearSIPAccountSuccessfully {
    appDelegate.clearingSIP = FALSE;
    [ProgressHUD dismiss];
    
    tfAccount.text = tfPassword.text = tfServerID.text = @"";
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_SERVER];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_ID];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_PORT];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_login];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_password];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [swAccount setUIForDisableStateWithActionTarget: NO];
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your account was removed"] duration:2.0 position:CSToastPositionCenter];
    [self performSelector:@selector(dismissCurrentView) withObject:nil afterDelay:2.0];
}

#pragma mark - UITextfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == tfServerID) {
        [tfAccount becomeFirstResponder];

    }else if (textField == tfAccount) {
        [tfPassword becomeFirstResponder];

    }else{
        [self.view endEditing: TRUE];
    }
    return TRUE;
}

#pragma mark - QRCode delegate and functions
- (void)buttonQRCodeScanPress {
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        scanQRCodeVC = [QRCodeReaderViewController readerWithCancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
        scanQRCodeVC.modalPresentationStyle = UIModalPresentationFormSheet;
        scanQRCodeVC.delegate = self;
        
        float hBTN = 38.0;
        btnScanFromPhoto = [UIButton buttonWithType: UIButtonTypeCustom];
        btnScanFromPhoto.backgroundColor = [UIColor colorWithRed:(2/255.0) green:(164/255.0)
                                                            blue:(247/255.0) alpha:1.0];
        [btnScanFromPhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnScanFromPhoto.layer.cornerRadius = hBTN/2;
        btnScanFromPhoto.layer.borderColor = btnScanFromPhoto.backgroundColor.CGColor;
        btnScanFromPhoto.layer.borderWidth = 1.0;
        [btnScanFromPhoto setTitle:[appDelegate.localization localizedStringForKey:@"SCAN FROM PHOTO"]
                          forState:UIControlStateNormal];
        btnScanFromPhoto.titleLabel.font = appDelegate.fontNormal;
        [btnScanFromPhoto addTarget:self
                             action:@selector(btnScanFromPhotoPressed)
                   forControlEvents:UIControlEventTouchUpInside];
        
        [scanQRCodeVC.view addSubview: btnScanFromPhoto];
        [btnScanFromPhoto mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(scanQRCodeVC.view.mas_centerX);
            make.bottom.equalTo(scanQRCodeVC.view).offset(-60.0);
            make.width.mas_equalTo(250.0);
            make.height.mas_equalTo(hBTN);
        }];
        
        [scanQRCodeVC setCompletionWithBlock:^(NSString *resultAsString) {
            NSLog(@"Completion with result: %@", resultAsString);
        }];
        [self presentViewController:scanQRCodeVC animated:YES completion:NULL];
        
    }else {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"This device not support scan QRCode"] duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
    }
}

- (void)btnScanFromPhotoPressed {
    [appDelegate enableSizeForBarButtonItem: TRUE];
    
    btnScanFromPhoto.backgroundColor = UIColor.whiteColor;
    [btnScanFromPhoto setTitleColor:[UIColor colorWithRed:(2/255.0) green:(164/255.0)
                                                     blue:(247/255.0) alpha:1.0]
                           forState:UIControlStateNormal];
    [self performSelector:@selector(choosePictureForScanQRCode) withObject:nil afterDelay:0.05];
}

- (void)choosePictureForScanQRCode {
    btnScanFromPhoto.backgroundColor = [UIColor colorWithRed:(2/255.0) green:(164/255.0)
                                                        blue:(247/255.0) alpha:1.0];
    [btnScanFromPhoto setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    [scanQRCodeVC presentViewController:pickerController animated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [appDelegate enableSizeForBarButtonItem: FALSE];
    [picker dismissViewControllerAnimated:TRUE completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:NULL];
        
        BOOL networkReady = [DeviceUtil checkNetworkAvailable];
        if (!networkReady) {
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
            return;
        }
        
        NSString* type = [info objectForKey:UIImagePickerControllerMediaType];
        if ([type isEqualToString: (NSString*)kUTTypeImage] ) {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            [self getQRCodeContentFromImage: image];
        }
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader {
    [self dismissViewControllerAnimated:TRUE completion:NULL];
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result {
    [reader stopScanning];
    
    [self dismissViewControllerAnimated:YES completion:^{
        BOOL networkReady = [DeviceUtil checkNetworkAvailable];
        if (!networkReady) {
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
            return;
        }
        
        [ProgressHUD backgroundColor: ProgressHUD_BG];
        [ProgressHUD show:[appDelegate.localization localizedStringForKey:@"Please wait..."] Interaction:NO];
        [self getPBXInformationWithHashString: result];
    }];
}

#pragma mark - Switch Custom Delegate
- (void)switchButtonEnabled
{
    [self.view endEditing: TRUE];
    //  set lại info nếu user change thông tin và bấm turn off account
    //  [self showPBXAccountInformation];
    
    BOOL networkReady = [DeviceUtil checkNetworkAvailable];
    if (!networkReady) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    [ProgressHUD backgroundColor: ProgressHUD_BG];
    [ProgressHUD show:[appDelegate.localization localizedStringForKey:@"Please wait..."] Interaction:NO];
    
    NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
    NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
    
    if (![AppUtil isNullOrEmpty: domain] && ![AppUtil isNullOrEmpty: port] && ![AppUtil isNullOrEmpty: USERNAME] && ![AppUtil isNullOrEmpty: PASSWORD])
    {
        [self registerObserverForSIPStateChange: TRUE];
        
        turningOnAcc = TRUE;
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:domain, @"domain", USERNAME, @"account", PASSWORD, @"password", port, @"port", nil];
        [appDelegate registerSIPAccountWithInfo: info];
    }else{
        [ProgressHUD dismiss];
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Not enough informations to enable your account"] duration:3.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
    }
}

- (void)switchButtonDisabled
{
    [self.view endEditing: TRUE];
    
    BOOL networkReady = [DeviceUtil checkNetworkAvailable];
    if (!networkReady) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    AccountState state = [appDelegate checkSipStateOfAccount];
    if (state == eAccountNone) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"You have not signed your account yet"] duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
        return;
    }
    
    [ProgressHUD backgroundColor: ProgressHUD_BG];
    [ProgressHUD show:[appDelegate.localization localizedStringForKey:@"Please wait..."] Interaction:NO];
    
    BOOL success = [appDelegate deleteSIPAccountDefault];
    if (success) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:TURN_OFF_ACC];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        turningOffAcc = TRUE;
        NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
        if (![AppUtil isNullOrEmpty: server] && ![AppUtil isNullOrEmpty: USERNAME]) {
            [self updateCustomerTokenIOSForPBX:server andUsername:USERNAME withTokenValue:@""];
        }else{
            [self whenTurnOffPBXSuccessfully];
        }
    }else{
        [ProgressHUD dismiss];
    }
}

- (void)whenTurnOffPBXSuccessfully {
    [ProgressHUD dismiss];
    
    turningOffAcc = FALSE;
    
    [swAccount setUIForDisableStateWithActionTarget: NO];
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your account was disabled successful"]
                duration:2.0 position:CSToastPositionCenter];
}

- (void)whenTurnOnPBXSuccessfully {
    [ProgressHUD dismiss];
    
    turningOnAcc = FALSE;
    [swAccount setUIForEnableStateWithActionTarget: FALSE];
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your account was enabled successful"]
                duration:2.0 position:CSToastPositionCenter];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: TURN_OFF_ACC];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
