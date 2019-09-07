//
//  SendLogsViewController.h
//  linphone
//
//  Created by lam quang quan on 11/27/18.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SendLogsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tbLogs;

@end
