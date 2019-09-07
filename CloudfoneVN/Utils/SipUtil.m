//
//  SipUtil.m
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "SipUtil.h"
#import "AppDelegate.h"

AppDelegate *sipUtilAppDel;

@implementation SipUtil

+ (void)startSipUtil {
    sipUtilAppDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (BOOL)makeCallToPhoneNumber: (NSString *)phoneNumber displayName: (NSString *)displayName
{
    AccountState state = [sipUtilAppDel checkSipStateOfAccount];
    if (state == eAccountNone) {
        NSString *content = [sipUtilAppDel.localization localizedStringForKey:@"Can not make call now. Perhaps you have not signed your account yet!"];
        [sipUtilAppDel.window makeToast:content duration:3.0 position:CSToastPositionCenter];
        return FALSE;
    }
    
    //  [Khai Le - 27/12/2018]
    phoneNumber = [self makeValidPhoneNumber: phoneNumber];
    
    if (phoneNumber != nil && phoneNumber.length > 0)
    {
        BOOL networkReady = [DeviceUtil checkNetworkAvailable];
        if (!networkReady) {
            [sipUtilAppDel.window makeToast:[sipUtilAppDel.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
            return FALSE;
        }
        
        if ([phoneNumber isEqualToString: USERNAME]) {
            [sipUtilAppDel.window makeToast:[sipUtilAppDel.localization localizedStringForKey:@"Can not make call with yourself"] duration:2.0 position:CSToastPositionCenter];
            return FALSE;
        }
        
        NSString *domain = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
        NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
        if ([AppUtil isNullOrEmpty: domain] || [AppUtil isNullOrEmpty: port]) {
            [sipUtilAppDel.window makeToast:[sipUtilAppDel.localization localizedStringForKey:@"Can not get domain or port to make call"] duration:2.0 position:CSToastPositionCenter];
            return FALSE;
        }
//        NSString *stringForCall = SFM(@"sip:%@@%@:%@", phoneNumber, domain, port);
//        [sipUtilAppDel makeCallTo: stringForCall];
//        if ([DeviceUtil isConnectedEarPhone]) {
//            [DeviceUtil tryToConnectToEarphone];
//        }else{
//            [DeviceUtil enableSpeakerForCall: FALSE];
//        }
        [sipUtilAppDel showCallViewWithDirection:OutgoingCall remote:phoneNumber displayName:displayName];
        
        return TRUE;
    }else{
        [sipUtilAppDel.window makeToast:[sipUtilAppDel.localization localizedStringForKey:@"Phone number can not empty!"] duration:2.0 position:CSToastPositionCenter];
        return FALSE;
    }
}

+ (NSString *)makeValidPhoneNumber: (NSString *)phoneNumber {
    if ([phoneNumber hasPrefix:@"+84"]) {
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+84" withString:@"0"];
    }
    
    if ([phoneNumber hasPrefix:@"84"]) {
        phoneNumber = [phoneNumber substringFromIndex:2];
        phoneNumber = [NSString stringWithFormat:@"0%@", phoneNumber];
    }
    phoneNumber = [AppUtil removeAllSpecialInString: phoneNumber];
    return phoneNumber;
}

@end
