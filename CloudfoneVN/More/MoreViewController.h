//
//  MoreViewController.h
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import <UIKit/UIKit.h>

enum moreValue{
    eSettingsAccount,
    eSettings,
    eFeedback,
    ePolicy,
    eIntroduce,
    eSendLogs,
    eAbout,
};

NS_ASSUME_NONNULL_BEGIN

@interface MoreViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lbFullname;
@property (weak, nonatomic) IBOutlet UILabel *lbAccID;
@property (weak, nonatomic) IBOutlet UIButton *icEdit;
@property (weak, nonatomic) IBOutlet UILabel *lbNoAccount;
@property (weak, nonatomic) IBOutlet UITableView *tbContent;

@end

NS_ASSUME_NONNULL_END
