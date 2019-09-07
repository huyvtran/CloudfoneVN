//
//  ChangePasswordViewController.h
//  CloudfoneVN
//
//  Created by OS on 8/26/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChangePasswordViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lbCurrentPass;
@property (weak, nonatomic) IBOutlet UITextField *tfCurrentPass;

@property (weak, nonatomic) IBOutlet UILabel *lbNewPass;
@property (weak, nonatomic) IBOutlet UITextField *tfNewPass;

@property (weak, nonatomic) IBOutlet UILabel *lbConfirmPass;
@property (weak, nonatomic) IBOutlet UITextField *tfConfirmPass;
@property (weak, nonatomic) IBOutlet UILabel *lbDesc;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet UIButton *btnChangePass;
@property (weak, nonatomic) IBOutlet UIButton *icShowCurrentPass;
@property (weak, nonatomic) IBOutlet UIButton *icShowNewPass;
@property (weak, nonatomic) IBOutlet UIButton *icShowConfirmPass;

- (IBAction)buttonChangePassPress:(UIButton *)sender;
- (IBAction)buttonResetPress:(UIButton *)sender;
- (IBAction)icShowConfirmPassPress:(UIButton *)sender;
- (IBAction)icShowNewPassPress:(UIButton *)sender;
- (IBAction)icShowPassPress:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
