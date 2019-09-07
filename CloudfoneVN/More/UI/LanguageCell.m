//
//  LanguageCell.m
//  linphone
//
//  Created by Apple on 5/10/17.
//
//

#import "LanguageCell.h"

@implementation LanguageCell
@synthesize _lbTitle, _imgSelect, _lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.contentView.backgroundColor = UIColor.whiteColor;
    
    [_imgSelect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10.0);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(24.0);
    }];
    
    _lbTitle.font = [AppDelegate sharedInstance].fontNormal;
    [_lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20.0);
        make.top.bottom.equalTo(self);
        make.right.equalTo(_imgSelect.mas_left).offset(-10);
    }];
    
    _lbSepa.backgroundColor = GRAY_235;
    [_lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
