//
//  DialerViewController.h
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAddressTextField.h"

NS_ASSUME_NONNULL_BEGIN

@interface DialerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UIImageView *bgTop;
@property (weak, nonatomic) IBOutlet UIImageView *imgTopLogo;
@property (weak, nonatomic) IBOutlet UILabel *lbAccID;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;

@property (weak, nonatomic) IBOutlet UIView *viewNumber;
@property (weak, nonatomic) IBOutlet UIButton *icAddContact;
@property (weak, nonatomic) IBOutlet UIAddressTextField *tfAddress;

@property (weak, nonatomic) IBOutlet UIView *viewKeypad;
@property (weak, nonatomic) IBOutlet UIButton *btnOne;
@property (weak, nonatomic) IBOutlet UIButton *btnTwo;
@property (weak, nonatomic) IBOutlet UIButton *btnThree;
@property (weak, nonatomic) IBOutlet UIButton *btnFour;
@property (weak, nonatomic) IBOutlet UIButton *btnFive;
@property (weak, nonatomic) IBOutlet UIButton *btnSix;
@property (weak, nonatomic) IBOutlet UIButton *btnSeven;
@property (weak, nonatomic) IBOutlet UIButton *btnEight;
@property (weak, nonatomic) IBOutlet UIButton *btnNine;
@property (weak, nonatomic) IBOutlet UIButton *btnZero;
@property (weak, nonatomic) IBOutlet UIButton *btnSharp;
@property (weak, nonatomic) IBOutlet UIButton *btnStar;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnTransfer;
@property (weak, nonatomic) IBOutlet UIButton *btnAddCall;
@property (weak, nonatomic) IBOutlet UIButton *btnHotline;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnBackspace;

- (IBAction)buttonNumberPress:(UIButton *)sender;
- (IBAction)buttonCallPress:(UIButton *)sender;
- (IBAction)buttonTransferPress:(UIButton *)sender;
- (IBAction)buttonAddCallPress:(UIButton *)sender;
- (IBAction)buttonHotlinePress:(UIButton *)sender;
- (IBAction)buttonBackspacePress:(UIButton *)sender;
- (IBAction)buttonBackCallPress:(UIButton *)sender;
- (IBAction)icAddContactClick:(UIButton *)sender;

@property (nonatomic, assign) BOOL isTransferCall;

@end

NS_ASSUME_NONNULL_END
