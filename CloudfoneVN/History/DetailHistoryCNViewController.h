//
//  DetailHistoryCNViewController.h
//  linphone
//
//  Created by user on 18/3/14.
//
//

#import <UIKit/UIKit.h>

@interface DetailHistoryCNViewController : UIViewController<NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate >

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (retain, nonatomic) IBOutlet UILabel *_lbHeader;
@property (weak, nonatomic) IBOutlet UIButton *icDelete;

@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;

@property (weak, nonatomic) IBOutlet UITableView *_tbHistory;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;

- (IBAction)_iconBackClicked:(UIButton *)sender;
- (IBAction)icDeleteClick:(UIButton *)sender;

@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, strong) NSString *onDate;
@property (nonatomic, assign) BOOL onlyMissedCall;

- (IBAction)btnCallPressed:(UIButton *)sender;

@end
