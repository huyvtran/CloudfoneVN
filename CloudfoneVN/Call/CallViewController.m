//
//  CallViewController.m
//  NhanHoa
//
//  Created by Khai Leo on 7/23/19.
//  Copyright © 2019 Nhan Hoa. All rights reserved.
//

#import "CallViewController.h"
#import "DialerViewController.h"
#import "UIMiniKeypad.h"
#import "NSData+Base64.h"

#define kMaxRadius 200
#define kMaxDuration 10

@interface CallViewController (){
    AppDelegate *appDelegate;
    NSTimer *durationTimer;
    NSString *callDicrection;
    float marginTopAvatar;
    NSTimer *timerHangupCall;
}

@end

@implementation CallViewController
@synthesize viewCall, bgCall, lbName, lbDuration, lbCallState, lbSubName, imgAvatar, icMute, lbMute, icSpeaker, lbSpeaker, icHangup, icHoldCall, lbHoldCall, icMiniKeypad, lbKeypad, icAddCall, lbAddCall, icTransfer, lbTransfer;
@synthesize remoteNumber, callDirection, halo, displayName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setupUIForView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self showLanguageContentForView];
    [self registerObserveres];
    
    //  set remote name
    if ([remoteNumber isEqualToString: hotline]) {
        if ([remoteNumber isEqualToString:hotline]) {
            imgAvatar.image = [UIImage imageNamed:@"hotline_avatar.png"];
        }
        displayName = text_hotline;
        lbSubName.hidden = TRUE;
    }else{
        [self showCallContactInformation];
        lbSubName.hidden = FALSE;
    }
    
    if ([AppUtil isNullOrEmpty: displayName]) {
        if (callDirection == IncomingCall) {
            NSArray *nameInfo = [appDelegate getContactNameOfRemoteForCall];
            if (nameInfo != nil) {
                displayName = [nameInfo objectAtIndex: 0];
            }
        }
    }
    if ([AppUtil isNullOrEmpty: displayName]) {
        displayName = [appDelegate.localization localizedStringForKey:@"Unknown"];
    }
    
    //  show calling animation for avatar
    if (callDirection == OutgoingCall) {
        if (self.halo == nil) {
            [self addAnimationForOutgoingCall];
        }
        self.halo.hidden = TRUE;
        [self.halo start];
        
        lbCallState.text = [appDelegate.localization localizedStringForKey:@"Calling"];
        lbDuration.hidden = TRUE;
        [self updateButtonsWithCallState: CALL_INV_STATE_CALLING];
        
    }else{
        //  Hiển thị duration nếu khi vào màn hình call và cuộc gọi đã được kết nối thành công
        if ([appDelegate isCallWasConnected]) {
            lbCallState.hidden = TRUE;
            [self startToUpdateDurationForCall];
        }
    }
    
    lbName.text = displayName;
    lbSubName.text = remoteNumber;
    
    [self showSpeakerButtonWithCurrentRouteState];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(audioRouteChangeListenerCallback:)
                                               name:AVAudioSessionRouteChangeNotification object:nil];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.halo.position = imgAvatar.center;
    if (imgAvatar.frame.origin.y == marginTopAvatar) {
        self.halo.hidden = FALSE;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [self requestAccessToMicroIfNot];
    
    if (callDirection == OutgoingCall) {
        NSString *callState = [appDelegate getCallStateOfCurrentCall];
        if ([AppUtil isNullOrEmpty: callState])
        {
            NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
            NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];

            NSString *stringForCall = SFM(@"sip:%@@%@:%@", remoteNumber, domain, port);
            [appDelegate makeCallTo: stringForCall];
            
            [appDelegate playRingbackTone];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)showLanguageContentForView {
    lbMute.text = [appDelegate.localization localizedStringForKey:@"Mute"];
    lbKeypad.text = [appDelegate.localization localizedStringForKey:@"Keypad"];
    lbSpeaker.text = [appDelegate.localization localizedStringForKey:@"Speaker"];
    lbAddCall.text = [appDelegate.localization localizedStringForKey:@"Add call"];
    lbHoldCall.text = [appDelegate.localization localizedStringForKey:@"Hold"];
    lbTransfer.text = [appDelegate.localization localizedStringForKey:@"Transfer"];
}

- (void)showCallContactInformation {
    PhoneObject *contact = [ContactsUtil getContactPhoneObjectWithNumber: remoteNumber];
    if (contact != nil) {
        if ([AppUtil isNullOrEmpty: contact.avatar]) {
            imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
        }else{
            imgAvatar.image = [UIImage imageWithData:[NSData base64DataFromString: contact.avatar]];
        }
        displayName = contact.name;
    }else{
        imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }
}

- (void)addAnimationForOutgoingCall {
    NSString *callState = [appDelegate getCallStateOfCurrentCall];
    if (callDirection == OutgoingCall && ![callState isEqualToString: CALL_INV_STATE_CONFIRMED]) {
        // basic setup
        PulsingHaloLayer *layer = [PulsingHaloLayer layer];
        self.halo = layer;
        [imgAvatar.superview.layer insertSublayer:self.halo below:imgAvatar.layer];
        [self setupInitialValuesWithNumLayer:5 radius:0.8 duration:0.45
                                       color:[UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:0.7]];
    }
}

- (void)setupInitialValuesWithNumLayer: (int)numLayer radius: (float)radius duration: (float)duration color: (UIColor *)color
{
    self.halo.haloLayerNumber = numLayer;
    self.halo.radius = radius * kMaxRadius;
    self.halo.animationDuration = duration * kMaxDuration;
    [self.halo setBackgroundColor:color.CGColor];
}

- (void)stopCallingAnimation {
    if (self.halo) {
        //  Stop halo waiting
        self.halo.hidden = TRUE;
        [self.halo start];
        self.halo = nil;
        [self.halo removeFromSuperlayer];
    }
}

- (void)requestAccessToMicroIfNot
{
    //show warning Microphone
    if (IS_IOS7) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){
            if (granted) {
                NSLog(@"granted");
            } else {
                [appDelegate hangupAllCall];
            }
        }];
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
            if (granted) {
                NSLog(@"granted");
            } else {
                [appDelegate hangupAllCall];
            }
        }];
    }
}

- (void)registerObserveres {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallStateChanged:)
                                                 name:notifCallStateChanged object:nil];
}

- (void)showSpeakerButtonWithCurrentRouteState {
    TypeOutputRoute curRoute = [DeviceUtil getCurrentRouteForCall];
    if (curRoute == eEarphone) {
        if (icSpeaker.enabled) {
            [icSpeaker setImage:[UIImage imageNamed:@"ic_speaker_ble_def"]
                       forState:UIControlStateNormal];
        }else{
            [icSpeaker setImage:[UIImage imageNamed:@"ic_speaker_ble_dis"]
                       forState:UIControlStateNormal];
        }
    }else if (curRoute == eSpeaker){
        if ([DeviceUtil isConnectedEarPhone]) {
            [icSpeaker setImage:[UIImage imageNamed:@"ic_speaker_ble_act"]
                       forState:UIControlStateNormal];
        }else{
            [icSpeaker setImage:[UIImage imageNamed:@"ic_speaker_act"]
                       forState:UIControlStateNormal];
        }
    }else{
        [icSpeaker setImage:[UIImage imageNamed:@"ic_speaker_def"]
                   forState:UIControlStateNormal];
    }
}

- (void)setupUIForView
{
    marginTopAvatar = 40.0;
    
    float marginIcon;
    float wSmallIcon;
    float wAvatar = 120.0;
    float hLabel = 25.0;
    float marginY = 15.0;
    
    if (IS_IPHONE || IS_IPOD) {
        NSString *deviceMode = [DeviceUtil getModelsOfCurrentDevice];
        if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
        {
            //  Screen width: 320.000000 - Screen height: 667.000000
            wAvatar = 100.0;
            wSmallIcon = 60.0;
            marginTopAvatar = 25.0;
            
        }else if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2])
        {
            //  Screen width: 375.000000 - Screen height: 667.000000
            wAvatar = 120.0;
            wSmallIcon = 70.0;
            
        }else if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2])
        {
            //  Screen width: 414.000000 - Screen height: 736.000000
            wAvatar = 130.0;
            wSmallIcon = 60.0;
            
        }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2] || [deviceMode isEqualToString: simulator]){
            //  Screen width: 375.000000 - Screen height: 812.000000
            wAvatar = 150.0;
            wSmallIcon = 58.0;
            
        }else{
            wAvatar = 130.0;
            wSmallIcon = 60.0;
        }
        
    }else{
        wAvatar = 180.0;
        wSmallIcon = 60.0;
    }
    marginIcon = (SCREEN_WIDTH - 3*wSmallIcon)/4;
    
    [viewCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    [bgCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewCall);
    }];
    
    [icHangup setImage:[UIImage imageNamed:@"decline_call_hover"] forState:UIControlStateHighlighted];
    [icHangup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewCall.mas_centerX);
        make.bottom.equalTo(viewCall).offset(-20.0);
        make.width.height.mas_equalTo(wSmallIcon);
    }];
    
    //  mini keypad
    [icMiniKeypad setBackgroundImage:[UIImage imageNamed:@"ic_keypad_def.png"] forState:UIControlStateNormal];
    [icMiniKeypad setBackgroundImage:[UIImage imageNamed:@"ic_keypad_act.png"] forState:UIControlStateSelected];
    [icMiniKeypad setBackgroundImage:[UIImage imageNamed:@"ic_keypad_dis.png"] forState:UIControlStateDisabled];
    [icMiniKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewCall.mas_centerY);
        make.centerX.equalTo(viewCall.mas_centerX);
        make.width.height.mas_equalTo(wSmallIcon);
    }];
    
    [lbKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(icMiniKeypad.mas_bottom);
        make.centerX.equalTo(icMiniKeypad.mas_centerX);
        make.width.mas_equalTo(100.0);
        make.height.mas_equalTo(hLabel);
    }];
    
    //  mute
    [icMute setImage:[UIImage imageNamed:@"ic_mute_def.png"] forState:UIControlStateNormal];
    [icMute setImage:[UIImage imageNamed:@"ic_mute_dis.png"] forState:UIControlStateDisabled];
    [icMute mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(icMiniKeypad);
        make.right.equalTo(icMiniKeypad.mas_left).offset(-marginIcon);
        make.width.mas_equalTo(wSmallIcon);
    }];
    
    [lbMute mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(lbKeypad);
        make.centerX.equalTo(icMute.mas_centerX);
        make.width.equalTo(lbKeypad.mas_width);
    }];
    
    //  speaker
    [icSpeaker setImage:[UIImage imageNamed:@"ic_speaker_def.png"] forState:UIControlStateNormal];
    [icSpeaker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(icMiniKeypad);
        make.left.equalTo(icMiniKeypad.mas_right).offset(marginIcon);
        make.width.mas_equalTo(wSmallIcon);
    }];
    
    [lbSpeaker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(lbKeypad);
        make.centerX.equalTo(icSpeaker.mas_centerX);
        make.width.equalTo(lbKeypad.mas_width);
    }];
    
    //  add call
    [icAddCall setImage:[UIImage imageNamed:@"ic_addcall_def.png"] forState:UIControlStateNormal];
    [icAddCall setImage:[UIImage imageNamed:@"ic_addcall_act.png"] forState:UIControlStateSelected];
    [icAddCall setImage:[UIImage imageNamed:@"ic_addcall_dis.png"] forState:UIControlStateDisabled];
    [icAddCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(icMute);
        make.top.equalTo(lbMute.mas_bottom).offset(marginY);
        make.height.mas_equalTo(wSmallIcon);
    }];
    
    [lbAddCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lbMute);
        make.top.equalTo(icAddCall.mas_bottom);
        make.height.mas_equalTo(hLabel);
    }];
    
    //  hold call
    [icHoldCall setImage:[UIImage imageNamed:@"ic_pause_def.png"] forState:UIControlStateNormal];
    [icHoldCall setImage:[UIImage imageNamed:@"ic_pause_act.png"] forState:UIControlStateSelected];
    [icHoldCall setImage:[UIImage imageNamed:@"ic_pause_dis.png"] forState:UIControlStateDisabled];
    [icHoldCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(icMiniKeypad);
        make.top.bottom.equalTo(icAddCall);
    }];
    
    [lbHoldCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lbKeypad);
        make.top.bottom.equalTo(lbAddCall);
    }];
    
    //  transfer
    [icTransfer setBackgroundImage:[UIImage imageNamed:@"ic_transfer_def.png"] forState:UIControlStateNormal];
    [icTransfer setBackgroundImage:[UIImage imageNamed:@"ic_transfer_act.png"] forState:UIControlStateSelected];
    [icTransfer setBackgroundImage:[UIImage imageNamed:@"ic_transfer_dis.png"] forState:UIControlStateDisabled];
    [icTransfer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(icSpeaker);
        make.top.bottom.equalTo(icHoldCall);
    }];
    
    [lbTransfer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lbSpeaker);
        make.top.bottom.equalTo(lbHoldCall);
    }];
    
    //  avatar
    imgAvatar.backgroundColor = UIColor.clearColor;
    [imgAvatar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewCall).offset(marginTopAvatar);
        make.centerX.equalTo(viewCall.mas_centerX);
        make.width.height.mas_equalTo(wAvatar);
    }];
    imgAvatar.clipsToBounds = TRUE;
    imgAvatar.layer.borderColor = UIColor.whiteColor.CGColor;
    imgAvatar.layer.borderWidth = 2.0;
    imgAvatar.layer.cornerRadius = wAvatar/2;
    
    //  name
    lbName.font = [UIFont fontWithName:MYRIADPRO_BOLD size:26.0];
    lbName.textColor = UIColor.whiteColor;
    [lbName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewCall).offset(5.0);
        make.right.equalTo(viewCall).offset(-5.0);
        make.top.equalTo(imgAvatar.mas_bottom);
        make.height.mas_equalTo(45.0);
    }];
    
    //  number
    lbSubName.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    [lbSubName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbName.mas_bottom);
        make.left.right.equalTo(lbName);
        make.height.mas_equalTo(25.0);
    }];
    
    lbCallState.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:25.0];
    [lbCallState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbSubName.mas_bottom).offset(10.0);
        make.left.right.equalTo(lbSubName);
        make.height.mas_equalTo(30);
    }];
    
    lbDuration.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:40.0];
    lbDuration.textColor = UIColor.greenColor;
    [lbDuration mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(lbCallState);
        make.height.mas_equalTo(40.0);
    }];
}

- (void)onCallStateChanged: (NSNotification *)notif
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *info = [notif object];
        if ([info isKindOfClass:[NSDictionary class]]) {
            NSString *state = [info objectForKey:@"state"];
            NSString *last_status = [info objectForKey:@"last_status"];
            NSLog(@"state is: %@", state);
            
            //  show state of buttons
            [self updateButtonsWithCallState: state];
            
            if ([state isEqualToString: CALL_INV_STATE_CALLING]) {
                lbCallState.text = [appDelegate.localization localizedStringForKey:@"Calling"];
                
            }else if ([state isEqualToString: CALL_INV_STATE_EARLY]) {
                lbCallState.text = [appDelegate.localization localizedStringForKey:@"Ringing"];

            }else if ([state isEqualToString: CALL_INV_STATE_CONNECTING]) {
                lbCallState.text = SFM(@"%@...", [appDelegate.localization localizedStringForKey:@"Connecting"]);

            }else if ([state isEqualToString: CALL_INV_STATE_CONFIRMED]) {
                lbCallState.text = [appDelegate.localization localizedStringForKey:@"Connected"];
                
                lbDuration.hidden = FALSE;
                lbCallState.hidden = TRUE;
                
                //  Update duration for call
                [self startToUpdateDurationForCall];
                
                [self stopCallingAnimation];
                
            }else if ([state isEqualToString: CALL_INV_STATE_DISCONNECTED])
            {
                [self stopCallingAnimation];
                
                NSString *content = [appDelegate.localization localizedStringForKey:@"Call terminated"];
                
                if ([last_status isEqualToString:@"503"] || [last_status isEqualToString:@"603"]) {
                    content = [appDelegate.localization localizedStringForKey:@"The user is busy"];
                }
                lbCallState.text = content;
                lbCallState.hidden = FALSE;
                lbDuration.hidden = TRUE;
                
                int duration = 0;
                NSNumber *call_duration = [info objectForKey:@"call_duration"];
                if (call_duration != nil) {
                    duration = [call_duration intValue];
                }
                NSTimeInterval timeInt = [[NSDate date] timeIntervalSince1970];
                timeInt = timeInt - duration;
                
                [self performSelector:@selector(dismissCallView) withObject:nil afterDelay:2.0];

                NSString *callID = [AppUtil randomStringWithLength: 12];
                NSString *date = [AppUtil getDateFromTimeInterval: timeInt];
                NSString *time = [AppUtil getCurrentTimeStampFromTimeInterval: timeInt];
                
                NSString *callStatus;
                if ([last_status isEqualToString:@"200"]) {
                    callStatus = success_call;
                    
                }else if ([last_status isEqualToString:@"487"]) {
                    callStatus = aborted_call;
                    
                }else if ([last_status isEqualToString:@"503"]) {
                    callStatus = declined_call;
                    
                }else if ([last_status isEqualToString:@"603"]) {
                    callStatus = not_answer_call;
                }
                
                NSString *strAddress = remoteNumber;

                NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
                NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
                if (![AppUtil isNullOrEmpty: domain] && ![AppUtil isNullOrEmpty: port]) {
                    strAddress = SFM(@"sip:%@@%@:%@", remoteNumber, domain, port);
                }
                
                NSString *direction = (callDirection == IncomingCall) ? incomming_call : outgoing_call;
                [DatabaseUtil InsertHistory:callID status:callStatus phoneNumber:remoteNumber callDirection:direction recordFiles:@"" duration:duration date:date time:time time_int:timeInt callType:AUDIO_CALL_TYPE sipURI:strAddress MySip:USERNAME kCallId:@"" andFlag:1 andUnread:0];
                
                //  clear timer
                [durationTimer invalidate];
                durationTimer = nil;
                [self hideMiniKeypad];
                [appDelegate hideTransferCallView];
            }

            if ([state isEqualToString: CALL_INV_STATE_CONNECTING] || [state isEqualToString: CALL_INV_STATE_CONFIRMED] || [state isEqualToString: CALL_INV_STATE_DISCONNECTED]) {
                [appDelegate stopRingbackTone];
            }
        }
    });
}

- (void)updateButtonsWithCallState: (NSString *)call_state {
    if ([call_state isEqualToString: CALL_INV_STATE_CALLING] || [call_state isEqualToString: CALL_INV_STATE_DISCONNECTED]) {
        icMute.enabled = icMiniKeypad.enabled = icSpeaker.enabled = icAddCall.enabled = icHoldCall.enabled = icTransfer.enabled = FALSE;
        
    }else if ([call_state isEqualToString: CALL_INV_STATE_EARLY]) {
        icMute.enabled = icSpeaker.enabled = TRUE;
        icMiniKeypad.enabled = icAddCall.enabled = icHoldCall.enabled = icTransfer.enabled = FALSE;
        
        [self showSpeakerButtonWithCurrentRouteState];
    }else if ([call_state isEqualToString: CALL_INV_STATE_CONFIRMED]){
        icMute.enabled = icMiniKeypad.enabled = icSpeaker.enabled = icAddCall.enabled = icHoldCall.enabled = icTransfer.enabled = TRUE;
        
        [self showSpeakerButtonWithCurrentRouteState];
    }
}


- (void)dismissCallView {
    if (timerHangupCall) {
        [timerHangupCall invalidate];
        timerHangupCall = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:reloadHistoryCall object:nil];
    
    [self.navigationController popViewControllerAnimated: TRUE];
    [appDelegate hideCallView];
}

- (IBAction)icMuteClick:(UIButton *)sender {
    BOOL isMuted = [appDelegate checkMicrophoneWasMuted];
    if (isMuted) {
        BOOL result = [appDelegate muteMicrophone: FALSE];
        if (result) {
            [sender setImage:[UIImage imageNamed:@"ic_mute_def"] forState:UIControlStateNormal];
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Microphone is on"] duration:1.0 position:CSToastPositionCenter];
        }else{
            [sender setImage:[UIImage imageNamed:@"ic_mute_act"] forState:UIControlStateNormal];
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Failed"] duration:1.0 position:CSToastPositionCenter];
        }
    }else {
        BOOL result = [[AppDelegate sharedInstance] muteMicrophone: TRUE];
        if (result) {
            [sender setImage:[UIImage imageNamed:@"ic_mute_act"] forState:UIControlStateNormal];
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Microphone is off"] duration:1.0 position:CSToastPositionCenter];
        }else{
            [sender setImage:[UIImage imageNamed:@"ic_mute_def"] forState:UIControlStateNormal];
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Failed"] duration:1.0 position:CSToastPositionCenter];
        }
    }
}

- (IBAction)icSpeakerClick:(UIButton *)sender {
    if ([DeviceUtil isConnectedEarPhone]) {
        TypeOutputRoute curRoute = [DeviceUtil getCurrentRouteForCall];
        if (curRoute == eEarphone) {
            BOOL result = [DeviceUtil tryToEnableSpeakerWithEarphone];
            if (!result) {
                [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Failed"] duration:1.0 position:CSToastPositionCenter];
                return;
            }
            [sender setImage:[UIImage imageNamed:@"ic_speaker_act"] forState:UIControlStateNormal];
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Speaker is on"] duration:1.0 position:CSToastPositionCenter];
        }else{
            BOOL result = [DeviceUtil tryToConnectToEarphone];
            if (!result) {
                [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Failed"] duration:1.0 position:CSToastPositionCenter];
                return;
            }
            [sender setImage:[UIImage imageNamed:@"ic_speaker_ble_act"] forState:UIControlStateNormal];
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Speaker is off"] duration:1.0 position:CSToastPositionCenter];
        }
    }else{
        TypeOutputRoute curRoute = [DeviceUtil getCurrentRouteForCall];
        if (curRoute == eReceiver) {
            BOOL result = [DeviceUtil enableSpeakerForCall: TRUE];
            if (!result) {
                [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Failed"] duration:1.0 position:CSToastPositionCenter];
                return;
            }
            [sender setImage:[UIImage imageNamed:@"ic_speaker_act"] forState:UIControlStateNormal];
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Speaker is on"] duration:1.0 position:CSToastPositionCenter];
            
        }else{
            BOOL result = [DeviceUtil enableSpeakerForCall: FALSE];
            if (!result) {
                [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Failed"] duration:1.0 position:CSToastPositionCenter];
                return;
            }
            [sender setImage:[UIImage imageNamed:@"ic_speaker_def"] forState:UIControlStateNormal];
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Speaker is off"] duration:1.0 position:CSToastPositionCenter];
        }
    }
}

- (IBAction)icHangupClick:(UIButton *)sender {
    [appDelegate hangupAllCall];
    
    if (timerHangupCall) {
        [timerHangupCall invalidate];
        timerHangupCall = nil;
    }
    timerHangupCall = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(dismissCallView) userInfo:nil repeats:FALSE];
}

- (IBAction)icHoldCallClick:(UIButton *)sender {
    BOOL holing = [appDelegate checkCurrentCallWasHold];
    if (holing) {
        [appDelegate holdCurrentCall: FALSE];
        [icHoldCall setImage:[UIImage imageNamed:@"ic_pause_def"] forState:UIControlStateNormal];
    }else{
        [appDelegate holdCurrentCall: TRUE];
        [icHoldCall setImage:[UIImage imageNamed:@"ic_pause_act"] forState:UIControlStateNormal];
    }
}

- (IBAction)icMiniKeypadClick:(UIButton *)sender {
    [self showMiniKeypadOnView: self.view];
}

- (IBAction)icAddCallPress:(UIButton *)sender {
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"This feature have not supported yet. Please try later!"] duration:2.0 position:CSToastPositionCenter];
    return;
}

- (IBAction)icTransferPress:(UIButton *)sender {
    [appDelegate showTransferCallView];
}

- (void)startToUpdateDurationForCall {
    if (durationTimer) {
        [durationTimer invalidate];
        durationTimer = nil;
    }

    [self resetDurationValueForCall];
    durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(resetDurationValueForCall) userInfo:nil repeats:TRUE];
}

- (void)resetDurationValueForCall
{
    long duration = [appDelegate getDurationForCurrentCall];
    NSString *strDuration = [AppUtil durationToString: (int)duration];
    lbDuration.text = strDuration;
}

- (void)showMiniKeypadOnView: (UIView *)aview
{
    NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"UIMiniKeypad" owner:nil options:nil];
    UIMiniKeypad *viewKeypad;
    for(id currentObject in toplevelObject){
        if ([currentObject isKindOfClass:[UIMiniKeypad class]]) {
            viewKeypad = (UIMiniKeypad *) currentObject;
            break;
        }
    }
    [viewKeypad.iconBack addTarget:self
                            action:@selector(hideMiniKeypad)
                  forControlEvents:UIControlEventTouchUpInside];
    [aview addSubview:viewKeypad];
    [viewKeypad.iconMiniKeypadEndCall addTarget:self
                                         action:@selector(endCallFromMiniKeypad)
                               forControlEvents:UIControlEventTouchUpInside];

    [viewKeypad mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(aview);
    }];
    [viewKeypad setupUIForView];

    viewKeypad.tag = 10;
    [self fadeIn:viewKeypad];
}

- (void)endCallFromMiniKeypad {
    [self hideMiniKeypad];
    [appDelegate hangupAllCall];
}

//  Hide keypad mini
- (void)hideMiniKeypad{
    for (UIView *subView in self.view.subviews) {
        if (subView.tag == 10) {
            [UIView animateWithDuration:.35 animations:^{
                subView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                subView.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (finished) {
                    [subView removeFromSuperview];
                }
            }];
        }
    }
}

- (void)fadeIn :(UIView*)view{
    view.transform = CGAffineTransformMakeScale(1.3, 1.3);
    view.alpha = 0.0;
    [UIView animateWithDuration:.35 animations:^{
        view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        view.alpha = 1.0;
    }];
}

- (void)audioRouteChangeListenerCallback:(NSNotification *)notif {
    if (!IS_IPHONE && !IS_IPOD) {
        return;
    }

    // there is at least one bug when you disconnect an audio bluetooth headset
    // since we only get notification of route having changed, we cannot tell if that is due to:
    // -bluetooth headset disconnected or
    // -user wanted to use earpiece
    // the only thing we can assume is that when we lost a device, it must be a bluetooth one (strong hypothesis though)
    if ([[notif.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue] ==
        AVAudioSessionRouteChangeReasonOldDeviceUnavailable)
    {
        NSLog(@"_bluetoothAvailable = NO;");
    }

    AVAudioSessionRouteDescription *newRoute = [AVAudioSession sharedInstance].currentRoute;
    if (newRoute && (unsigned long)newRoute.outputs.count > 0) {
        NSString *route = newRoute.outputs[0].portType;

        NSLog(@"Detect BLE: newRoute = %@", route);

        BOOL _speakerEnabled = [route isEqualToString:AVAudioSessionPortBuiltInSpeaker];
        if (notif.userInfo != nil) {
            NSDictionary *info = notif.userInfo;
            id headphonesObj = [info objectForKey:@"AVAudioSessionRouteChangeReasonKey"];
            if (headphonesObj != nil && [headphonesObj isKindOfClass:[NSNumber class]]) {
                [self headsetPluginChangedWithReason: headphonesObj];
            }
        }

        //  [Khai Le - 23/03/2019]
        if (([[DeviceUtil bluetoothRoutes] containsObject:route]) && !_speakerEnabled) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"bluetoothEnabled" object:nil];

        }else if ([[route lowercaseString] containsString:@"speaker"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"speakerEnabled" object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"iPhoneReceiverEnabled" object:nil];
        }
    }
}


- (void)headsetPluginChangedWithReason: (NSNumber *)reason {
    if (reason != nil && [reason isKindOfClass:[NSNumber class]]) {
        int routeChangeReason = [reason intValue];
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //  Tai nghe bị rút ra
                NSLog(@"OldDeviceUnavailable");
                TypeOutputRoute curRoute = [DeviceUtil getCurrentRouteForCall];
                if (curRoute == eSpeaker) {
                    [icSpeaker setImage:[UIImage imageNamed:@"ic_speaker_act"] forState:UIControlStateNormal];
                    
                }else if (curRoute == eReceiver) {
                    [icSpeaker setImage:[UIImage imageNamed:@"ic_speaker_def"] forState:UIControlStateNormal];
                }
            });
        }
        if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //  Khi cắm tai nghe vào, chuyển audio vào tai nghe, set lại giá trị cho button
                NSLog(@"NewDeviceAvailable");
                [icSpeaker setImage:[UIImage imageNamed:@"ic_speaker_def"] forState:UIControlStateNormal];
            });
        }
    }
}

@end
