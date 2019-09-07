//
//  TypePhoneCell.m
//  linphone
//
//  Created by Ei Captain on 4/3/17.
//
//

#import "TypePhoneCell.h"

@implementation TypePhoneCell
@synthesize _imgType, _lbType, _lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _lbType.textColor = UIColor.darkGrayColor;
    _lbSepa.backgroundColor = GRAY_230;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setupUIForCell {
    _imgType.frame = CGRectMake((self.frame.size.height-25)/2, self.frame.size.height/6, self.frame.size.height*2/3, self.frame.size.height*2/3);
    _lbType.frame = CGRectMake(_imgType.frame.origin.x+_imgType.frame.size.width+5, _imgType.frame.origin.y, self.frame.size.width-(_imgType.frame.origin.x*2+5+_imgType.frame.size.width), _imgType.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

@end
