//
//  SipUtil.h
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SipUtil : NSObject

+ (void)startSipUtil;
+ (BOOL)makeCallToPhoneNumber: (NSString *)phoneNumber displayName: (NSString *)displayName;
+ (NSString *)makeValidPhoneNumber: (NSString *)phoneNumber;

@end

NS_ASSUME_NONNULL_END
