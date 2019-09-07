//
//  UIMiniKeypad.h
//  linphone
//
//  Created by user on 18/12/13.
//
//

#import <UIKit/UIKit.h>

@interface UIMiniKeypad : UIView

@property (weak, nonatomic) IBOutlet UIImageView *bgCall;
@property (nonatomic, retain) IBOutlet UIButton* oneButton;
@property (nonatomic, retain) IBOutlet UIButton* twoButton;
@property (nonatomic, retain) IBOutlet UIButton* threeButton;
@property (nonatomic, retain) IBOutlet UIButton* fourButton;
@property (nonatomic, retain) IBOutlet UIButton* fiveButton;
@property (nonatomic, retain) IBOutlet UIButton* sixButton;
@property (nonatomic, retain) IBOutlet UIButton* sevenButton;
@property (nonatomic, retain) IBOutlet UIButton* eightButton;
@property (nonatomic, retain) IBOutlet UIButton* nineButton;
@property (nonatomic, retain) IBOutlet UIButton* starButton;
@property (nonatomic, retain) IBOutlet UIButton* zeroButton;
@property (nonatomic, retain) IBOutlet UIButton* sharpButton;
@property (weak, nonatomic) IBOutlet UIButton *iconBack;
@property (weak, nonatomic) IBOutlet UIButton *iconMiniKeypadEndCall;
@property (weak, nonatomic) IBOutlet UITextField *tfNumber;
@property (weak, nonatomic) IBOutlet UIView *viewKeypad;

- (void)setupUIForView;
- (IBAction)onDigitPress:(UIButton *)sender;
- (IBAction)icHangupCallClick:(UIButton *)sender;

@end
