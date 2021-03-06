//
//  DeviceUtil.m
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "DeviceUtil.h"
#import <sys/utsname.h>
#import <AVFoundation/AVFoundation.h>

@implementation DeviceUtil

//  https://www.theiphonewiki.com/wiki/Models
+ (NSString *)getModelsOfCurrentDevice {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *modelType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return modelType;
}

+ (float)getSizeOfKeypadButtonForDevice: (NSString *)deviceMode {
    if (IS_IPHONE || IS_IPOD) {
        if (SCREEN_WIDTH <= SCREEN_WIDTH_IPHONE_5) {
            return 62.0;
            
        }else if (SCREEN_WIDTH <= SCREEN_WIDTH_IPHONE_6){
            return 73.0;
            
        }else if (SCREEN_WIDTH <= SCREEN_WIDTH_IPHONE_6PLUS){
            return 76.0;
        }
        return 76.0;
    }else{
        return 62.0;
    }
}

+ (float)getSpaceXBetweenKeypadButtonsForDevice: (NSString *)deviceMode
{
    if (SCREEN_WIDTH <= SCREEN_WIDTH_IPHONE_5) {
        return 20.0;
        
    }else if (SCREEN_WIDTH <= SCREEN_WIDTH_IPHONE_6){
        return 27.0;
        
    }else if (SCREEN_WIDTH <= SCREEN_WIDTH_IPHONE_6PLUS){
        return 30.0;
    }
    return 30.0;
}

+ (float)getSpaceYBetweenKeypadButtonsForDevice: (NSString *)deviceMode {
    if (SCREEN_WIDTH <= SCREEN_WIDTH_IPHONE_5) {
        return 10.0;
        
    }else if (SCREEN_WIDTH <= SCREEN_WIDTH_IPHONE_6){
        return 15.0;
        
    }else if (SCREEN_WIDTH <= SCREEN_WIDTH_IPHONE_6PLUS){
        return 20.0;
    }
    return 20.0;
}

+ (BOOL)checkNetworkAvailable {
    NetworkStatus internetStatus = [[AppDelegate sharedInstance].internetReachable currentReachabilityStatus];
    if (internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN) {
        return TRUE;
    }
    return FALSE;
}

+ (void)cleanLogFolder {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *arr = [WriteLogsUtils getAllFilesInDirectory: logsFolderName];
    for (int i=0; i<arr.count; i++) {
        NSString *fileName = [arr objectAtIndex: i];
        if ([fileName hasPrefix: bundleIdentifier]) {
            NSString *path = [DeviceUtil getPathOfFileWithSubDir:SFM(@"%@/%@", logsFolderName, fileName)];
            [WriteLogsUtils removeFileWithPath: path];
        }
    }
}

+ (NSString *)convertLogFileName: (NSString *)fileName {
    if ([fileName hasPrefix:@"."]) {
        fileName = [fileName substringFromIndex: 1];
    }
    
    if ([fileName hasSuffix:@".txt"]) {
        fileName = [fileName substringToIndex:(fileName.length - 4)];
    }
    
    fileName = [fileName stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    
    return [NSString stringWithFormat:@"Log_file_%@", fileName];
}

+ (NSString *)getPathOfFileWithSubDir: (NSString *)subDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *result = [[paths objectAtIndex:0] stringByAppendingPathComponent: subDir];
    return result;
}

//  check current route used bluetooth
+ (TypeOutputRoute)getCurrentRouteForCall {
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    NSArray *outputs = currentRoute.outputs;
    for (AVAudioSessionPortDescription *route in outputs) {
        if (route.portType == AVAudioSessionPortBuiltInReceiver) {
            return eReceiver;
            
        }else if (route.portType == AVAudioSessionPortBuiltInSpeaker || [[route.portType lowercaseString] containsString:@"speaker"]) {
            return eSpeaker;
            
        }else if (route.portType == AVAudioSessionPortBluetoothHFP || route.portType == AVAudioSessionPortBluetoothLE || route.portType == AVAudioSessionPortBluetoothA2DP || [[route.portType lowercaseString] containsString:@"bluetooth"]) {
            return eEarphone;
        }
    }
    return eReceiver;
}

+ (BOOL)enableSpeakerForCall: (BOOL)speaker {
    BOOL success;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    if (speaker) {
        success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                           withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                 error:&error];
        if (!success){
            return FALSE;
        }
        
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        if (!success){
            return FALSE;
        }
        
        success = [session setActive:YES error:&error];
        if (!success){
            return FALSE;
        }
    }else{
        success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                           withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                 error:&error];
        if (!success){
            return FALSE;
        }
        
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        if (!success){
            return FALSE;
        }
        
        success = [session setActive:YES error:&error];
        if (!success){
            return FALSE;
        }
    }
    return success;
}

+ (BOOL)isConnectedEarPhone {
    NSArray *bluetoothPorts = @[ AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP ];
    
    NSArray *routes = [[AVAudioSession sharedInstance] availableInputs];
    for (AVAudioSessionPortDescription *route in routes) {
        if ([bluetoothPorts containsObject:route.portType]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)tryToEnableSpeakerWithEarphone {
    NSError *err;
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&err];
    if (err) {
        return FALSE;
    }
    return TRUE;
}

+ (BOOL)tryToConnectToEarphone {
    NSError *err;
    AVAudioSessionPortDescription *_bluetoothPort = [self bluetoothAudioDevice];
    [[AVAudioSession sharedInstance] setPreferredInput:_bluetoothPort error:&err];
    // if setting bluetooth failed, it must be because the device is not available
    // anymore (disconnected), so deactivate bluetooth.
    if (err) {
        return FALSE;
    } else {
        return TRUE;
    }
}

+ (AVAudioSessionPortDescription *)bluetoothAudioDevice {
    return [self audioDeviceFromTypes:[self bluetoothRoutes]];
}


+ (AVAudioSessionPortDescription *)audioDeviceFromTypes:(NSArray *)types {
    NSArray *routes = [[AVAudioSession sharedInstance] availableInputs];
    for (AVAudioSessionPortDescription *route in routes) {
        if ([types containsObject:route.portType]) {
            return route;
        }
    }
    return nil;
}

+ (NSArray *)bluetoothRoutes {
    return @[ AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP ];
}

@end
