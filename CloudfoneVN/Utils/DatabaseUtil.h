//
//  DatabaseUtil.h
//  CloudfoneVN
//
//  Created by OS on 8/27/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseUtil : NSObject

+ (void)startDatabaseUtil;
+ (BOOL)connectToDatabase;

+ (void)InsertHistory : (NSString *)call_id status : (NSString *)status phoneNumber : (NSString *)phone_number callDirection : (NSString *)callDirection recordFiles : (NSString*) record_files duration : (int)duration date : (NSString *)date time : (NSString *)time time_int : (int)time_int callType : (int)callType sipURI : (NSString*)sipUri MySip : (NSString *)mysip kCallId: (NSString *)kCallId andFlag: (int)flag andUnread: (int)unread;
+ (NSMutableArray *)getHistoryCallListOfUser: (NSString *)account isMissed: (BOOL)missed;
+ (int)getMissedCallUnreadWithRemote: (NSString *)remote onDate: (NSString *)date ofAccount: (NSString *)account;
+ (NSDictionary *)getCallInfoWithHistoryCallId: (int)callId;
+ (BOOL)removeHistoryCallsOfUser: (NSString *)user onDate: (NSString *)date ofAccount: (NSString *)account onlyMissed: (BOOL)missed;
+ (int)getUnreadMissedCallHisotryWithAccount: (NSString *)account;
+ (NSMutableArray *)getAllListCallOfMe: (NSString *)mySip withPhoneNumber: (NSString *)phoneNumber;
+ (NSMutableArray *)getAllCallOfMe: (NSString *)mySip withPhone: (NSString *)phoneNumber onDate: (NSString *)dateStr onlyMissedCall: (BOOL)onlyMissedCall;
+ (BOOL)resetMissedCallOfRemote: (NSString *)remote onDate: (NSString *)date ofAccount: (NSString *)account;
+ (BOOL)deleteCallHistoryOfRemote: (NSString *)remote onDate: (NSString *)date ofAccount: (NSString *)account;
+ (NSString *)getLastCallOfUser;
+ (BOOL)checkMissedCallExistsFromUser: (NSString *)phone withAccount: (NSString *)account atTime: (long)time;

@end

NS_ASSUME_NONNULL_END
