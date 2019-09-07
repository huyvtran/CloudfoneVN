//
//  ContactsListViewController.h
//  CloudfoneVN
//
//  Created by OS on 8/27/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactsListViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UIButton *icAdd;
@property (weak, nonatomic) IBOutlet UIButton *icSync;
@property (weak, nonatomic) IBOutlet UIButton *btnPBX;
@property (weak, nonatomic) IBOutlet UIButton *btnAll;
@property (weak, nonatomic) IBOutlet UITextField *tfSearch;
@property (weak, nonatomic) IBOutlet UIButton *icClear;
@property (weak, nonatomic) IBOutlet UITableView *tbAllContacts;
@property (weak, nonatomic) IBOutlet UILabel *lbNoAllContacts;


@property (weak, nonatomic) IBOutlet UITableView *tbPBXContacts;
@property (weak, nonatomic) IBOutlet UILabel *lbNoPBXContacts;

- (IBAction)iconSyncPress:(UIButton *)sender;
- (IBAction)iconAddPress:(UIButton *)sender;
- (IBAction)iconClearPress:(UIButton *)sender;
- (IBAction)btnAllContactsPress:(UIButton *)sender;
- (IBAction)btnPBXContactsPress:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
