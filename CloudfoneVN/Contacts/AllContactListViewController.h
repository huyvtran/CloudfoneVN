//
//  AllContactListViewController.h
//  linphone
//
//  Created by admin on 1/29/18.
//

#import <UIKit/UIKit.h>

@interface AllContactListViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *iconBack;
@property (weak, nonatomic) IBOutlet UILabel *lbHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;


@property (weak, nonatomic) IBOutlet UITextField *tfSearch;
@property (weak, nonatomic) IBOutlet UIButton *iconClear;
@property (weak, nonatomic) IBOutlet UITableView *tbContacts;
@property (weak, nonatomic) IBOutlet UILabel *lbNoContact;

- (IBAction)iconBackClicked:(UIButton *)sender;
- (IBAction)iconCloseClicked:(UIButton *)sender;

@property (nonatomic, strong) NSString *phoneNumber;

@end
