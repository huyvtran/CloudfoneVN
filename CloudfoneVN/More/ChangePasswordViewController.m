//
//  ChangePasswordViewController.m
//  CloudfoneVN
//
//  Created by OS on 8/26/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "WebServices.h"

@interface ChangePasswordViewController ()<WebServicesDelegate, UITextFieldDelegate>{
    AppDelegate *appDelegate;
    WebServices *webService;
    NSString *serverID;
}
@end

@implementation ChangePasswordViewController
@synthesize lbCurrentPass, tfCurrentPass, lbNewPass, tfNewPass, lbConfirmPass, tfConfirmPass, lbDesc, btnReset, btnChangePass, icShowCurrentPass, icShowNewPass, icShowConfirmPass;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.view addGestureRecognizer: tapOnScreen];
    
    [self autoLayoutForMainView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    tfCurrentPass.text = tfNewPass.text = tfConfirmPass.text = @"";
    
    [self showContentForView];
    [self registerObservers];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (IBAction)buttonChangePassPress:(UIButton *)sender {
    [self.view endEditing: TRUE];
    
    NSString *curPass = tfCurrentPass.text;
    NSString *newPass = tfNewPass.text;
    NSString *confirmPass = tfConfirmPass.text;
    
    if ([AppUtil isNullOrEmpty: curPass] || [AppUtil isNullOrEmpty: newPass] || [AppUtil isNullOrEmpty: confirmPass]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please fill full informations!"] duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
        return;
    }
    
    if (![curPass isEqualToString: PASSWORD]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Current password is incorrect!"] duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
        return;
    }
    
    if (![newPass isEqualToString: confirmPass]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Confirm password is incorrect!"] duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
        return;
    }
    
    [ProgressHUD backgroundColor: ProgressHUD_BG];
    [ProgressHUD show:[appDelegate.localization localizedStringForKey:@"Please wait..."] Interaction:NO];
    
    [self changePasswordForUserWithNewPass: newPass];
}

- (IBAction)buttonResetPress:(UIButton *)sender {
    [self.view endEditing: TRUE];
    tfCurrentPass.text = tfNewPass.text = tfConfirmPass.text = @"";
}

- (IBAction)icShowConfirmPassPress:(UIButton *)sender {
    if (tfConfirmPass.secureTextEntry) {
        tfConfirmPass.secureTextEntry = FALSE;
        [sender setImage:[UIImage imageNamed:@"hide_pass"] forState:UIControlStateNormal];
    }else{
        tfConfirmPass.secureTextEntry = TRUE;
        [sender setImage:[UIImage imageNamed:@"show_pass"] forState:UIControlStateNormal];
    }
}

- (IBAction)icShowNewPassPress:(UIButton *)sender {
    if (tfNewPass.secureTextEntry) {
        tfNewPass.secureTextEntry = FALSE;
        [sender setImage:[UIImage imageNamed:@"hide_pass"] forState:UIControlStateNormal];
    }else{
        tfNewPass.secureTextEntry = TRUE;
        [sender setImage:[UIImage imageNamed:@"show_pass"] forState:UIControlStateNormal];
    }
}

- (IBAction)icShowPassPress:(UIButton *)sender {
    if (tfCurrentPass.secureTextEntry) {
        tfCurrentPass.secureTextEntry = FALSE;
        [sender setImage:[UIImage imageNamed:@"hide_pass"] forState:UIControlStateNormal];
    }else{
        tfCurrentPass.secureTextEntry = TRUE;
        [sender setImage:[UIImage imageNamed:@"show_pass"] forState:UIControlStateNormal];
    }
}

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationStateChanged:)
                                                 name:notifRegistrationStateChange object:nil];
}

- (void)closeKeyboard {
    [self.view endEditing: TRUE];
}

- (void)registrationStateChanged: (NSNotification *)notif {
    NSNumber *object = notif.object;
    if ([object isKindOfClass:[NSNumber class]]) {
        int registrationCode = [object intValue];
        if (registrationCode == 200) {
            NSLog(@"registrationCode = 200");
        }else{
            NSLog(@"can not re-registration");
        }
    }
}

- (void)showContentForView {
    self.title = [appDelegate.localization localizedStringForKey:@"Change password"];
    
    lbCurrentPass.text = [appDelegate.localization localizedStringForKey:@"Current password"];
    lbNewPass.text = [appDelegate.localization localizedStringForKey:@"New password"];
    lbConfirmPass.text = [appDelegate.localization localizedStringForKey:@"Confirm password"];
    lbDesc.text = [appDelegate.localization localizedStringForKey:@"Password are at least 6 characters long"];
    
    tfCurrentPass.placeholder = [appDelegate.localization localizedStringForKey:@"Enter current password"];
    tfNewPass.placeholder = [appDelegate.localization localizedStringForKey:@"Enter new password"];
    tfConfirmPass.placeholder = [appDelegate.localization localizedStringForKey:@"Enter confirm password"];
    
    [btnReset setTitle:[appDelegate.localization localizedStringForKey:@"Reset"]
              forState:UIControlStateNormal];
    [btnChangePass setTitle:[appDelegate.localization localizedStringForKey:@"Change password"]
                   forState:UIControlStateNormal];
}

- (void)autoLayoutForMainView {
    float marginX = 20.0;
    float hTextfield = 40.0;
    float hBTN = 45.0;
    
    //  Current password
    lbCurrentPass.textColor = lbNewPass.textColor = lbConfirmPass.textColor = [UIColor colorWithRed:(80/255.0) green:(80/255.0) blue:(80/255.0) alpha:1.0];
    lbCurrentPass.font = tfCurrentPass.font = lbNewPass.font = tfNewPass.font = lbConfirmPass.font = tfConfirmPass.font = appDelegate.fontNormal;
    
    [lbCurrentPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.equalTo(self.view).offset(marginX);
        make.right.equalTo(self.view).offset(-marginX);
        make.height.mas_equalTo(35.0);
    }];
    
    tfCurrentPass.borderStyle = tfNewPass.borderStyle = tfConfirmPass.borderStyle = UITextBorderStyleNone;
    tfCurrentPass.layer.cornerRadius = tfNewPass.layer.cornerRadius = tfConfirmPass.layer.cornerRadius = 3.0;
    tfCurrentPass.layer.borderWidth = tfNewPass.layer.borderWidth = tfConfirmPass.layer.borderWidth = 1.0;
    tfCurrentPass.layer.borderColor = tfNewPass.layer.borderColor = tfConfirmPass.layer.borderColor = GRAY_230.CGColor;
    tfCurrentPass.delegate = tfNewPass.delegate = tfConfirmPass.delegate = self;
    
    tfCurrentPass.returnKeyType = UIReturnKeyNext;
    [tfCurrentPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbCurrentPass.mas_bottom);
        make.left.right.equalTo(lbCurrentPass);
        make.height.mas_equalTo(hTextfield);
    }];
    tfCurrentPass.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, hTextfield)];
    tfCurrentPass.leftViewMode = UITextFieldViewModeAlways;
    
    icShowCurrentPass.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [icShowCurrentPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(tfCurrentPass);
        make.width.mas_equalTo(hTextfield);
    }];
    
    //  New password
    [lbNewPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfCurrentPass.mas_bottom).offset(15);
        make.left.right.equalTo(tfCurrentPass);
        make.height.equalTo(lbCurrentPass.mas_height);
    }];
    
    tfNewPass.returnKeyType = UIReturnKeyNext;
    [tfNewPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbNewPass.mas_bottom);
        make.left.right.equalTo(lbNewPass);
        make.height.equalTo(tfCurrentPass.mas_height);
    }];
    tfNewPass.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, hTextfield)];
    tfNewPass.leftViewMode = UITextFieldViewModeAlways;
    
    icShowNewPass.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [icShowNewPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(tfNewPass);
        make.width.mas_equalTo(hTextfield);
    }];
    
    //  Confirm password
    [lbConfirmPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfNewPass.mas_bottom).offset(15);
        make.left.right.equalTo(tfNewPass);
        make.height.equalTo(lbCurrentPass.mas_height);
    }];
    
    tfConfirmPass.returnKeyType = UIReturnKeyDone;
    [tfConfirmPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbConfirmPass.mas_bottom);
        make.left.right.equalTo(lbConfirmPass);
        make.height.equalTo(tfNewPass.mas_height);
    }];
    tfConfirmPass.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, hTextfield)];
    tfConfirmPass.leftViewMode = UITextFieldViewModeAlways;
    
    icShowConfirmPass.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [icShowConfirmPass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(tfConfirmPass);
        make.width.mas_equalTo(hTextfield);
    }];
    
    lbDesc.font = appDelegate.fontDesc;
    [lbDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfConfirmPass.mas_bottom);
        make.left.right.equalTo(tfConfirmPass);
        make.height.equalTo(lbConfirmPass.mas_height);
    }];
    
    //  footer button
    [btnReset setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnReset.backgroundColor = [UIColor colorWithRed:(248/255.0) green:(83/255.0) blue:(86/255.0) alpha:1.0];
    [btnReset mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-40.0);
        make.left.equalTo(lbDesc);
        make.right.equalTo(self.view.mas_centerX).offset(-20);
        make.height.mas_equalTo(hBTN);
    }];
    
    [btnChangePass setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnChangePass setBackgroundImage:[UIImage imageNamed:@"bg_button.png"] forState:UIControlStateNormal];
    [btnChangePass mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(btnReset);
        make.left.equalTo(self.view.mas_centerX).offset(20);
        make.right.equalTo(tfConfirmPass.mas_right);
    }];
    
    btnReset.clipsToBounds = btnChangePass.clipsToBounds = TRUE;
    btnReset.layer.cornerRadius = btnChangePass.layer.cornerRadius = hBTN/2;
    btnReset.titleLabel.font = btnChangePass.titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
}

- (void)changePasswordForUserWithNewPass: (NSString *)newPassword {
    serverID = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
    if (![AppUtil isNullOrEmpty: serverID]) {
        [self changePasswordForUser:USERNAME server:serverID password:newPassword];
    }
}

- (void)registerPBXAfterChangePasswordSuccess
{
    [appDelegate tryToReRegisterToSIP];
    [self updatePasswordSuccesful];
    [self performSelector:@selector(dismissCurrentView) withObject:nil afterDelay:2.0];
}

- (void)updatePasswordSuccesful
{
    [ProgressHUD dismiss];
    tfCurrentPass.text = tfNewPass.text = tfConfirmPass.text = @"";
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your password has been updated successful"] duration:2.0 position:CSToastPositionCenter];
}

- (void)dismissCurrentView {
    [self.navigationController popViewControllerAnimated: TRUE];
}

#pragma mark - Web service

- (void)changePasswordForUser: (NSString *)UserExt server: (NSString *)server password: (NSString *)newPassword
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:UserExt forKey:@"UserExt"];
    [jsonDict setObject:server forKey:@"ServerName"];
    [jsonDict setObject:PASSWORD forKey:@"PasswordOld"];
    [jsonDict setObject:newPassword forKey:@"PasswordNew"];
    
    [webService callWebServiceWithLink:ChangeExtPass withParams:jsonDict];
}

- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    [ProgressHUD dismiss];
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Failed to change password. Please try later!"] duration:2.0 position:CSToastPositionCenter style:appDelegate.errorStyle];
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    if ([link isEqualToString:ChangeExtPass]) {
        [[NSUserDefaults standardUserDefaults] setObject:tfNewPass.text forKey:key_password];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [appDelegate deleteSIPAccountDefault];
        [self registerPBXAfterChangePasswordSuccess];
        
    }
}

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    NSLog(@"%d", responeCode);
}

#pragma mark - UItextfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == tfCurrentPass) {
        [tfNewPass becomeFirstResponder];
        
    }else if (textField == tfNewPass) {
        [tfConfirmPass becomeFirstResponder];
        
    }else{
        [self.view endEditing: TRUE];
    }
    return TRUE;
}

@end
