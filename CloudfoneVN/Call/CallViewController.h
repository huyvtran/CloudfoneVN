//
//  CallViewController.h
//  NhanHoa
//
//  Created by Khai Leo on 7/23/19.
//  Copyright © 2019 Nhan Hoa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PulsingHaloLayer.h"

typedef enum CallDirection{
    OutgoingCall,
    IncomingCall,
}CallDirection;

NS_ASSUME_NONNULL_BEGIN

@interface CallViewController : UIViewController

//  call view
@property (weak, nonatomic) IBOutlet UIView *viewCall;
@property (weak, nonatomic) IBOutlet UIImageView *bgCall;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbSubName;
@property (weak, nonatomic) IBOutlet UILabel *lbDuration;
@property (weak, nonatomic) IBOutlet UILabel *lbCallState;

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UIButton *icMute;
@property (weak, nonatomic) IBOutlet UILabel *lbMute;
@property (weak, nonatomic) IBOutlet UIButton *icSpeaker;
@property (weak, nonatomic) IBOutlet UILabel *lbSpeaker;
@property (weak, nonatomic) IBOutlet UIButton *icAddCall;
@property (weak, nonatomic) IBOutlet UILabel *lbAddCall;
@property (weak, nonatomic) IBOutlet UIButton *icTransfer;
@property (weak, nonatomic) IBOutlet UILabel *lbTransfer;
@property (weak, nonatomic) IBOutlet UIButton *icHangup;
@property (weak, nonatomic) IBOutlet UIButton *icHoldCall;
@property (weak, nonatomic) IBOutlet UILabel *lbHoldCall;
@property (weak, nonatomic) IBOutlet UIButton *icMiniKeypad;
@property (weak, nonatomic) IBOutlet UILabel *lbKeypad;

- (IBAction)icMuteClick:(UIButton *)sender;
- (IBAction)icSpeakerClick:(UIButton *)sender;
- (IBAction)icHangupClick:(UIButton *)sender;
- (IBAction)icHoldCallClick:(UIButton *)sender;
- (IBAction)icMiniKeypadClick:(UIButton *)sender;
- (IBAction)icAddCallPress:(UIButton *)sender;
- (IBAction)icTransferPress:(UIButton *)sender;

@property (nonatomic, strong) NSString *remoteNumber;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, assign) CallDirection callDirection;
@property (nonatomic, weak) PulsingHaloLayer *halo;

@end

NS_ASSUME_NONNULL_END
