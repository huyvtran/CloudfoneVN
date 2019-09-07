//
//  UIMiniKeypad.m
//  linphone
//
//  Created by user on 18/12/13.
//
//

#import "UIMiniKeypad.h"

@implementation UIMiniKeypad
@synthesize oneButton;
@synthesize twoButton;
@synthesize threeButton;
@synthesize fourButton;
@synthesize fiveButton;
@synthesize sevenButton;
@synthesize sixButton;
@synthesize eightButton;
@synthesize nineButton;
@synthesize zeroButton;
@synthesize sharpButton;
@synthesize starButton;
@synthesize iconBack, iconMiniKeypadEndCall, tfNumber, viewKeypad, bgCall;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setupUIForView {
    self.backgroundColor = UIColor.whiteColor;
    
    //  Number keypad
    NSString *modelName = [DeviceUtil getModelsOfCurrentDevice];
    float wIcon = [DeviceUtil getSizeOfKeypadButtonForDevice: modelName];
    float spaceMarginY = [DeviceUtil getSpaceYBetweenKeypadButtonsForDevice: modelName];
    float spaceMarginX = [DeviceUtil getSpaceXBetweenKeypadButtonsForDevice: modelName];
    
    [bgCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    iconBack.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset([AppDelegate sharedInstance].hStatus);
        make.left.equalTo(self);
        make.width.height.mas_equalTo(40.0);
    }];
    
    [tfNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconBack.mas_bottom).offset(20);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.mas_equalTo(60.0);
    }];
    tfNumber.keyboardType = UIKeyboardTypePhonePad;
    tfNumber.enabled = NO;
    tfNumber.textAlignment = NSTextAlignmentCenter;
    tfNumber.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:45.0];
    tfNumber.adjustsFontSizeToFitWidth = YES;
    tfNumber.backgroundColor = UIColor.clearColor;
    tfNumber.textColor = UIColor.whiteColor;
    [tfNumber setBorderStyle: UITextBorderStyleNone];
    
    [viewKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(tfNumber.mas_bottom);
    }];
    
    //  7   8   9
    eightButton.tag = 8;
    [eightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(viewKeypad.mas_centerY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    sevenButton.tag = 7;
    [sevenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton);
        make.right.equalTo(eightButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    nineButton.tag = 9;
    [nineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton);
        make.left.equalTo(eightButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  4   5   6
    fiveButton.tag = 5;
    [fiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.bottom.equalTo(eightButton.mas_top).offset(-spaceMarginY);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    fourButton.tag = 4;
    [fourButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton);
        make.right.equalTo(fiveButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    sixButton.tag = 6;
    [sixButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton);
        make.left.equalTo(fiveButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  1   2   3
    twoButton.tag = 2;
    [twoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(fiveButton.mas_top).offset(-spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    oneButton.tag = 1;
    [oneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoButton);
        make.right.equalTo(twoButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    threeButton.tag = 3;
    [threeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoButton);
        make.left.equalTo(twoButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  *   0   #
    zeroButton.tag = 0;
    [zeroButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    starButton.tag = 10;
    [starButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton);
        make.right.equalTo(zeroButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    sharpButton.tag = 11;
    [sharpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton);
        make.left.equalTo(zeroButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    [iconMiniKeypadEndCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.top.equalTo(zeroButton.mas_bottom).offset(spaceMarginY);
        make.width.height.mas_equalTo(wIcon);
    }];
}

- (IBAction)onDigitPress:(UIButton *)sender {
    [[AppDelegate sharedInstance] playBeepSound];
    
    NSString *value = @"";
    if (sender.tag == 10) {
        value = @"*";
    }else if (sender.tag == 11) {
        value = @"#";
    }else{
        value = SFM(@"%d", (int)sender.tag);
    }
    tfNumber.text = SFM(@"%@%@", tfNumber.text, value);
    BOOL result = [[AppDelegate sharedInstance] sendDtmfWithValue: value];
    if (!result) {
        [self makeToast:[[AppDelegate sharedInstance].localization localizedStringForKey:@"Failed"] duration:1.0 position:CSToastPositionCenter];
    }
}

- (IBAction)icHangupCallClick:(UIButton *)sender {
    
}

@end
