//
//  MenuCell.m
//  linphone
//
//  Created by Apple on 4/26/17.
//
//

#import "MenuCell.h"

@implementation MenuCell
@synthesize _iconImage, _lbTitle, _lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.contentView.backgroundColor = UIColor.whiteColor;
    
    _lbTitle.font = [AppDelegate sharedInstance].fontNormal;
    
    float size = 22.0;
    if (IS_IPHONE || IS_IPOD) {
        if (SCREEN_WIDTH >= SCREEN_WIDTH_IPHONE_6PLUS) {
            size = 26.0;
        }
    }
    
    [_iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(size);
    }];
    
    _lbTitle.textColor = UIColor.darkGrayColor;
    _lbTitle.font = [AppDelegate sharedInstance].fontNormal;
    [_lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImage.mas_right).offset(10);
        make.right.equalTo(self).offset(-20);
        make.top.bottom.equalTo(self);
    }];
    
    _lbSepa.backgroundColor = GRAY_240;
    if (IS_IPHONE || IS_IPOD) {
        [_lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconImage);
            make.bottom.right.equalTo(self);
            make.height.mas_equalTo(1.0);
        }];
    }else{
        [_lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.bottom.right.equalTo(self);
            make.height.mas_equalTo(1.0);
        }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                blue:(240/255.0) alpha:1.0];
    }else{
        self.backgroundColor = UIColor.clearColor;
    }
}

@end
