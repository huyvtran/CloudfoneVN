//
//  DeviceUtil.h
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    eReceiver = 1,
    eSpeaker,
    eEarphone,
}TypeOutputRoute;

NS_ASSUME_NONNULL_BEGIN

@interface DeviceUtil : NSObject

+ (NSString *)getModelsOfCurrentDevice;
+ (float)getSizeOfKeypadButtonForDevice: (NSString *)deviceMode;
+ (float)getSpaceXBetweenKeypadButtonsForDevice: (NSString *)deviceMode;
+ (float)getSpaceYBetweenKeypadButtonsForDevice: (NSString *)deviceMode;
+ (BOOL)checkNetworkAvailable;
+ (void)cleanLogFolder;
+ (NSString *)convertLogFileName: (NSString *)fileName;
+ (NSString *)getPathOfFileWithSubDir: (NSString *)subDir;

+ (TypeOutputRoute)getCurrentRouteForCall;
+ (BOOL)enableSpeakerForCall: (BOOL)speaker;
+ (NSArray *)bluetoothRoutes;
+ (BOOL)isConnectedEarPhone;
+ (BOOL)tryToEnableSpeakerWithEarphone;
+ (BOOL)tryToConnectToEarphone;

@end

NS_ASSUME_NONNULL_END
