//
//  AppUtil.h
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABRecord.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppUtil : NSObject

+ (void)startAppUtil;
+ (NSString *)getAppVersionWithBuildVersion: (BOOL)showBuildVersion;
+ (NSString *)getCurrentDate;
+ (NSString *)getDateFromTimeInterval: (NSTimeInterval)interval;
+ (NSString *)getCurrentDateTime;
+ (BOOL)isNullOrEmpty:(NSString*)string;
+ (UIImage *)imageWithColor:(UIColor *)color andBounds:(CGRect)imgBounds;
+ (NSString *)getBuildDateWithTime: (BOOL)showTime;
+ (NSString *)stringTimeFromInterval: (NSTimeInterval)interval;
+ (NSString *)stringDateFromInterval: (NSTimeInterval)interval;
+ (void)addCornerRadiusTopLeftAndBottomLeftForButton: (id)view radius: (float)radius withColor: (UIColor *)borderColor border: (float)borderWidth;
+ (void)addCornerRadiusTopRightAndBottomRightForButton: (id)view radius: (float)radius withColor: (UIColor *)borderColor border: (float)borderWidth;
+ (void)setSelected: (BOOL)selected forButton: (UIButton *)button;

+ (NSString *)convertUTF8CharacterToCharacter: (NSString *)parentStr;
+ (NSString *)getNameForSearchOfConvertName: (NSString *)convertName;
+ (NSString *)getNameOfContact: (ABRecordRef)aPerson;
+ (NSData *)getFileDataFromDirectoryWithFileName: (NSString *)fileName;
+ (NSString *)convertUTF8StringToString: (NSString *)string;
+ (NSString *)removeAllSpecialInString: (NSString *)phoneString;
+ (UIImage*)cropImageWithSize:(CGSize)targetSize fromImage: (UIImage *)sourceImage;
+ (NSString *)getTypeOfPhone: (NSString *)typePhone;
+ (NSString *)durationToString:(int)duration;
+ (NSString *)getCurrentTimeStamp;
+ (NSString *)getCurrentTimeStampFromTimeInterval:(double)timeInterval;
+ (NSString *)randomStringWithLength: (int)len;
+ (NSString *)getTimeStringFromTimeInterval:(double)timeInterval;
+ (NSString *)convertDurtationToString: (long)duration;
+ (NSString *)getNameWasStoredFromUserInfo: (NSString *)number;
+ (NSString *)checkTodayForHistoryCall: (NSString *)dateStr;
+ (NSString *)checkYesterdayForHistoryCall: (NSString *)dateStr;

+ (NSString *)getDateFromInterval: (double)interval;
+ (NSString *)getFullTimeStringFromTimeInterval:(double)timeInterval;

@end

NS_ASSUME_NONNULL_END
