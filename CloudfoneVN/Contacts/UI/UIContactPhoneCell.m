//
//  UIContactPhoneCell.m
//  linphone
//
//  Created by lam quang quan on 10/10/18.
//

#import "UIContactPhoneCell.h"

@implementation UIContactPhoneCell
@synthesize lbTitle, lbPhone, icCall, lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.backgroundColor = UIColor.whiteColor;
    lbTitle.font = lbPhone.font = [AppDelegate sharedInstance].fontNormal;
    
    float sizeIcon = 32.0;
    if (IS_IPHONE || IS_IPOD) {
        if (SCREEN_WIDTH >= SCREEN_WIDTH_IPHONE_6PLUS) {
            sizeIcon = 36.0;
        }
    }
    
    [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(100);
    }];
    lbTitle.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0) blue:(50/255.0) alpha:1.0];
    
    [icCall setTitleColor:UIColor.clearColor forState:UIControlStateNormal];
    icCall.clipsToBounds = YES;
    icCall.layer.borderColor = GRAY_230.CGColor;
    icCall.layer.borderWidth = 3.0;
    icCall.layer.cornerRadius = sizeIcon/2;
    [icCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(sizeIcon);
    }];
    
    [lbPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbTitle.mas_right).offset(5);
        make.right.equalTo(icCall.mas_left).offset(-10);
        make.top.bottom.equalTo(self);
    }];
    lbPhone.textColor = lbTitle.textColor;
    
    if (IS_IPOD || IS_IPHONE) {
        [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lbTitle);
            make.right.bottom.equalTo(self);
            make.height.mas_equalTo(1.0);
        }];
    }else{
        [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(1.0);
        }];
    }
    
    lbSepa.backgroundColor = GRAY_235;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
