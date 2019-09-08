//
//  ProviderDelegate.m
//  linphone
//
//  Created by REIS Benjamin on 29/11/2016.
//
//

#import "ProviderDelegate.h"
#import <AVFoundation/AVAudioSession.h>
#import <Foundation/Foundation.h>

@implementation ProviderDelegate

- (instancetype)init {
	self = [super init];
	self.calls = [[NSMutableDictionary alloc] init];
	self.uuids = [[NSMutableDictionary alloc] init];
	self.pendingCallVideo = FALSE;
	CXCallController *callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
	[callController.callObserver setDelegate:self queue:dispatch_get_main_queue()];
	self.controller = callController;
	self.callKitCalls = 0;
    
	if (!self) {
        NSLog(@"ProviderDelegate not initialized...");
	}
    
	return self;
}

- (void)config {
	CXProviderConfiguration *config = [[CXProviderConfiguration alloc]
		initWithLocalizedName:[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
    config.ringtoneSound = @"";
	config.supportsVideo = TRUE;
	config.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"callkit_logo"]);
    config.supportedHandleTypes = [NSSet setWithObjects:@(CXHandleTypePhoneNumber), @(CXHandleTypeGeneric), @(CXHandleTypeEmailAddress), nil];
    
	NSArray *ar = @[ [NSNumber numberWithInt:(int)CXHandleTypeGeneric], [NSNumber numberWithInt:(int)CXHandleTypePhoneNumber], [NSNumber numberWithInt:(int)CXHandleTypeEmailAddress]];
	NSSet *handleTypes = [[NSSet alloc] initWithArray:ar];
	[config setSupportedHandleTypes:handleTypes];
	[config setMaximumCallGroups:2];
	[config setMaximumCallsPerCallGroup:1];
	self.provider = [[CXProvider alloc] initWithConfiguration:config];
	[self.provider setDelegate:self queue:dispatch_get_main_queue()];
}

- (void)configAudioSession:(AVAudioSession *)audioSession {
	[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
				  withOptions:AVAudioSessionCategoryOptionAllowBluetooth
						error:nil];
	[audioSession setMode:AVAudioSessionModeVoiceChat error:nil];
	double sampleRate = 16000.0;
	[audioSession setPreferredSampleRate:sampleRate error:nil];
    
    NSTimeInterval bufferDuration = .005;
    [audioSession setPreferredIOBufferDuration:bufferDuration error: nil];
}

- (void)reportIncomingCallwithUUID:(NSUUID *)uuid handle:(NSString *)handle caller_name: (NSString *)caller_name video:(BOOL)video {
	// Create update to describe the incoming call and caller
	CXCallUpdate *update = [[CXCallUpdate alloc] init];
    //  [Khai Le - 16/12/2018]
	//  update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:handle];
    NSString *value = SFM(@"%@|||%@", caller_name, handle);
    if ([AppUtil isNullOrEmpty: caller_name]) {
        value = handle;
    }
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:value];
    
    if ([AppUtil isNullOrEmpty: caller_name]) {
        caller_name = value;
    }else{
        caller_name = SFM(@"%@ - %@", caller_name, handle);
    }
    
    update.localizedCallerName = caller_name;
	update.supportsDTMF = TRUE;
	update.supportsHolding = TRUE;
	update.supportsGrouping = TRUE;
	update.supportsUngrouping = TRUE;
	update.hasVideo = video;
    
	// Report incoming call to system
	NSLog(@"CallKit: report new incoming call");
	[self.provider reportNewIncomingCallWithUUID:uuid
										  update:update
									  completion:^(NSError *error) {
									  }];
}

#pragma mark - CXProdiverDelegate Protocol

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action
{
    self.callKitCalls++;
	[self configAudioSession:[AVAudioSession sharedInstance]];
	[action fulfill];
	NSUUID *uuid = action.callUUID;

	NSString *callID = [self.calls objectForKey:uuid]; // first, make sure this callid is not already involved in a call
    if (callID != nil) {
        self.pendingCallID = [callID intValue];
        return;
    }
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
	// To restart Audio Unit
	[self configAudioSession:[AVAudioSession sharedInstance]];
	[action fulfill];
	NSUUID *uuid = action.callUUID;

	NSString *callID = [self.calls objectForKey:uuid]; // first, make sure this callid is not already involved in a call
    NSLog(@"%@", callID);
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
	self.callKitCalls--;
	[action fulfill];
    
    [[AppDelegate sharedInstance] hangupAllCall];
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(nonnull CXSetMutedCallAction *)action {
	[action fulfill];
	NSLog(@"---------performSetMutedCallAction");
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(nonnull CXSetHeldCallAction *)action {
	[action fulfill];
    NSLog(@"---------performSetHeldCallAction");
    
	NSUUID *uuid = action.callUUID;
	NSString *callID = [self.calls objectForKey:uuid];
	if (!callID) {
		return;
	}
}

- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action {
	[action fulfill];
	NSUUID *call_uuid = action.callUUID;
	NSString *callID = [self.calls objectForKey:call_uuid];
    NSLog(@"---------performPlayDTMFCallAction");
    
	//  char digit = action.digits.UTF8String[0];
    //  LinphoneCall *call = [LinphoneManager.instance callByCallId:callID];
	//  linphone_call_send_dtmf((LinphoneCall *)call, digit);
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
	// Now we can (re)start the call
    NSLog(@"---------didActivateAudioSession");
    
	if (self.pendingCallID != -1) {
        [[AppDelegate sharedInstance] answerCallWithCallID: self.pendingCallID];
	} else {
		
	}
    self.pendingCallID = -1;
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(nonnull AVAudioSession *)audioSession {
    NSLog(@"---------didDeactivateAudioSession");
    /*
	_pendingCall = NULL;
	_pendingAddr = NULL;
	_pendingCallVideo = FALSE;
    */
}

- (void)providerDidReset:(CXProvider *)provider {
    NSLog(@"---------providerDidReset");
    /*
	LinphoneManager.instance.conf = TRUE;
	linphone_core_terminate_all_calls(LC);
    */
    [self.calls removeAllObjects];
    [self.uuids removeAllObjects];
}

#pragma mark - CXCallObserverDelegate Protocol

- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    NSLog(@"---------callChanged");
}

@end
