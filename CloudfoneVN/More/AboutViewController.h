//
//  AboutViewController.h
//  linphone
//
//  Created by lam quang quan on 10/26/18.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imgAppLogo;
@property (weak, nonatomic) IBOutlet UILabel *lbVersion;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckForUpdate;

- (IBAction)btnCheckForUpdatePress:(UIButton *)sender;

@end
