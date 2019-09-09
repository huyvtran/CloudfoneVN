//
//  DatabaseUtil.m
//  CloudfoneVN
//
//  Created by OS on 8/27/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "DatabaseUtil.h"
#import "KHistoryCallObject.h"
#import "PhoneObject.h"
#import "PBXContact.h"
#import "CallHistoryObject.h"

AppDelegate *dbUtilAppDel;
HMLocalization *dbUtilLocalization;

@implementation DatabaseUtil

+ (void)startDatabaseUtil {
    dbUtilAppDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    dbUtilLocalization = [HMLocalization sharedInstance];
}

+ (BOOL)connectToDatabase {
    
    if (dbUtilAppDel.databasePath.length > 0) {
        dbUtilAppDel.dbQueue = [[FMDatabaseQueue alloc] initWithPath: dbUtilAppDel.databasePath];
        
        dbUtilAppDel.database = [[FMDatabase alloc] initWithPath: dbUtilAppDel.databasePath];
        if ([dbUtilAppDel.database open]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

+ (void)InsertHistory : (NSString *)call_id status : (NSString *)status phoneNumber : (NSString *)phone_number callDirection : (NSString *)callDirection recordFiles : (NSString*) record_files duration : (int)duration date : (NSString *)date time : (NSString *)time time_int : (int)time_int callType : (int)callType sipURI : (NSString*)sipUri MySip : (NSString *)mysip kCallId: (NSString *)kCallId andFlag: (int)flag andUnread: (int)unread
{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO history(call_id,status,phone_number,call_direction,record_files,duration,date,call_type,sipURI,time,time_int,my_sip, k_call_id, flag, unread) VALUES ('%@','%@','%@','%@','%@',%d,'%@',%d,'%@','%@',%d,'%@','%@',%d,%d)",call_id,status,phone_number,callDirection,record_files,duration,date,callType,sipUri,time,time_int,mysip, kCallId, flag, unread];
    [dbUtilAppDel.database executeUpdate: sql];
}

+ (NSMutableArray *)getHistoryCallListOfUser: (NSString *)account isMissed: (BOOL)missed
{
    __block NSMutableArray *listDate = [[NSMutableArray alloc] init];
    __block NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [dbUtilAppDel.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tSQL = [NSString stringWithFormat:@"SELECT date FROM history WHERE my_sip = '%@' GROUP BY date ORDER BY time_int DESC", account];
        FMResultSet *rs = [db executeQuery: tSQL];
        while ([rs next]) {
            NSDictionary *rsDict = [rs resultDictionary];
            NSString *dateStr = [rsDict objectForKey:@"date"];
            [listDate addObject: dateStr];
        }
        [rs close];
    }];
    
    for (int i=0; i<listDate.count; i++) {
        NSString *dateStr = [listDate objectAtIndex: i];
        
        NSMutableDictionary *oneDateDict = [[NSMutableDictionary alloc] init];
        [oneDateDict setObject:dateStr forKey:@"title"];
        if (missed) {
            NSMutableArray *missedArr = [self getMissedCallListOnDate:dateStr ofUser:account];
            if (missedArr.count > 0) {
                [oneDateDict setObject:missedArr forKey:@"rows"];
                [result addObject: oneDateDict];
            }
        }else{
            NSMutableArray *callArray = [self getAllCallOnDate:dateStr ofUser:account];
            if (callArray.count > 0) {
                [oneDateDict setObject:callArray forKey:@"rows"];
                [result addObject: oneDateDict];
            }
        }
    }
    return result;
}

+ (NSMutableArray *)getMissedCallListOnDate: (NSString *)dateStr ofUser: (NSString *)account
{
    __block NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [dbUtilAppDel.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip = '%@' AND call_direction = 'Incomming' AND status = 'Missed' AND date = '%@' GROUP BY phone_number ORDER BY _id DESC", account, dateStr];
         FMResultSet *rs = [db executeQuery: tSQL];
         while ([rs next]) {
             NSDictionary *rsDict = [rs resultDictionary];
             KHistoryCallObject *aCall = [[KHistoryCallObject alloc] init];
             int callId        = [[rsDict objectForKey:@"_id"] intValue];
             NSString *status        = [rsDict objectForKey:@"status"];
             NSString *phoneNumber = [rsDict objectForKey:@"phone_number"];
             
             NSString *callDirection = [rsDict objectForKey:@"call_direction"];
             NSString *callTime      = [rsDict objectForKey:@"time"];
             NSString *callDate      = [rsDict objectForKey:@"date"];
             int time_int = [[rsDict objectForKey:@"time_int"] intValue];
             int callType            = [[rsDict objectForKey:@"call_type"] intValue];
             
             PhoneObject *contact = [ContactsUtil getContactPhoneObjectWithNumber: phoneNumber];
             if (contact != nil) {
                 aCall._phoneName = contact.name;
                 aCall._phoneAvatar = contact.avatar;
             }else{
                 PBXContact *contact = [ContactsUtil getPBXContactWithExtension: phoneNumber];
                 if (contact != nil) {
                     aCall._phoneName = contact._name;
                 }else{
                     aCall._phoneName = [AppUtil getNameWasStoredFromUserInfo: aCall._phoneNumber];
                 }
             }
             aCall._callId = callId;
             aCall._status = status;
             aCall._prefixPhone = @"";
             aCall._phoneNumber = phoneNumber;
             aCall._callDirection = callDirection;
             aCall._callTime = callTime;
             aCall._callDate = callDate;
             aCall.timeInt = time_int;
             
             aCall.callType = callType;
             aCall.newMissedCall = [self getMissedCallUnreadWithRemote:phoneNumber onDate:dateStr ofAccount:account];
             
             [result addObject: aCall];
         }
         [rs close];
     }];
    return result;
}

+ (NSMutableArray *)getAllCallOnDate: (NSString *)dateStr ofUser: (NSString *)account
{
    __block NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [dbUtilAppDel.dbQueue inDatabase:^(FMDatabase *db)
     {
         NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip = '%@' AND date = '%@' GROUP BY phone_number ORDER BY time_int DESC", account, dateStr];;
         
         FMResultSet *rs = [db executeQuery: tSQL];
         while ([rs next]) {
             NSDictionary *rsDict = [rs resultDictionary];
             KHistoryCallObject *aCall = [[KHistoryCallObject alloc] init];
             int callId              = [[rsDict objectForKey:@"_id"] intValue];
             NSString *status        = [rsDict objectForKey:@"status"];
             NSString *callDirection = [rsDict objectForKey:@"call_direction"];
             NSString *callTime      = [rsDict objectForKey:@"time"];
             NSString *callDate      = [rsDict objectForKey:@"date"];
             NSString *phoneNumber   = [rsDict objectForKey:@"phone_number"];
             int callType            = [[rsDict objectForKey:@"call_type"] intValue];
             long timeInt   = [[rsDict objectForKey:@"time_int"] longValue];
             
             aCall._prefixPhone = @"";
             aCall._phoneNumber = phoneNumber;
             aCall.callType = callType;
             
             //  [Khai le - 03/11/2018]
             PhoneObject *aPhone = [ContactsUtil getContactPhoneObjectWithNumber: phoneNumber];
             if (aPhone != nil) {
                 aCall._phoneName = aPhone.name;
                 aCall._phoneAvatar = aPhone.avatar;
             }else{
                 PBXContact *contact = [ContactsUtil getPBXContactWithExtension:phoneNumber];
                 if (contact != nil) {
                     aCall._phoneName = contact._name;
                 }else{
                     aCall._phoneName = [AppUtil getNameWasStoredFromUserInfo: aCall._phoneNumber];
                 }
             }
             aCall._callId = callId;
             aCall._status = status;
             aCall._callDirection = callDirection;
             aCall._callTime = callTime;
             aCall._callDate = callDate;
             
             aCall.duration = [[rsDict objectForKey:@"duration"] intValue];
             aCall.timeInt = timeInt;
             aCall.newMissedCall = [self getMissedCallUnreadWithRemote:phoneNumber onDate:dateStr ofAccount:account];
             
             [result addObject: aCall];
         }
         [rs close];
     }];
    return result;
}

+ (int)getMissedCallUnreadWithRemote: (NSString *)remote onDate: (NSString *)date ofAccount: (NSString *)account
{
    int result = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as numMissedCall FROM history WHERE my_sip = '%@' and status = '%@' and unread = %d and date = '%@' and phone_number = '%@'", account, @"Missed", 1, date, remote];
    FMResultSet *rs = [dbUtilAppDel.database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [[rsDict objectForKey:@"numMissedCall"] intValue];
    }
    [rs close];
    return result;
}

+ (NSDictionary *)getCallInfoWithHistoryCallId: (int)callId {
    NSDictionary *rsDict;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE _id = %d ", callId];
    FMResultSet *rs = [dbUtilAppDel.database executeQuery: tSQL];
    while ([rs next]) {
        rsDict = [rs resultDictionary];
    }
    [rs close];
    return rsDict;
}

+ (BOOL)removeHistoryCallsOfUser: (NSString *)user onDate: (NSString *)date ofAccount: (NSString *)account onlyMissed: (BOOL)missed
{
    NSString *tSQL;
    if (missed) {
        tSQL = [NSString stringWithFormat:@"DELETE FROM history WHERE my_sip = '%@' AND phone_number = '%@' AND date = '%@' and status = '%@'", account, user, date, missed_call];
    }else{
        tSQL = [NSString stringWithFormat:@"DELETE FROM history WHERE my_sip = '%@' AND phone_number = '%@' AND date = '%@'", account, user, date];
    }
    
    BOOL result = [dbUtilAppDel.database executeUpdate: tSQL];
    return result;
}

+ (int)getUnreadMissedCallHisotryWithAccount: (NSString *)account
{
    __block int result = 0;
    [dbUtilAppDel.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as numMissedCall FROM history WHERE my_sip = '%@' and status = '%@' and unread = %d", account, @"Missed", 1];
        FMResultSet *rs = [db executeQuery: tSQL];
        while ([rs next]) {
            NSDictionary *rsDict = [rs resultDictionary];
            result = [[rsDict objectForKey:@"numMissedCall"] intValue];
        }
        [rs close];
    }];
    return result;
}

+ (NSMutableArray *)getAllListCallOfMe: (NSString *)account withPhoneNumber: (NSString *)phoneNumber
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *dateSQL = @"";
    if ([phoneNumber isEqualToString: hotline]) {
        dateSQL = [NSString stringWithFormat:@"SELECT date FROM history WHERE my_sip='%@' AND phone_number = '%@' GROUP BY date ORDER BY _id DESC", account, phoneNumber];
    }else{
        dateSQL = [NSString stringWithFormat:@"SELECT date FROM history WHERE my_sip='%@' AND phone_number LIKE '%%%@%%' GROUP BY date ORDER BY _id DESC", account, phoneNumber];
    }
    
    FMResultSet *rs = [dbUtilAppDel.database executeQuery: dateSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *dateStr = [rsDict objectForKey:@"date"];
        
        CallHistoryObject *aCall = [[CallHistoryObject alloc] init];
        aCall._date = dateStr;
        aCall._rate = -1;
        aCall._duration = -1;
        [result addObject: aCall];
        [result addObjectsFromArray:[self getAllCallOfMe:account withPhone:phoneNumber onDate:dateStr onlyMissedCall: FALSE]];
    }
    [rs close];
    return result;
}

+ (NSMutableArray *)getAllCallOfMe: (NSString *)mySip withPhone: (NSString *)phoneNumber onDate: (NSString *)dateStr onlyMissedCall: (BOOL)onlyMissedCall
{
    __block NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    [dbUtilAppDel.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tSQL = @"";
        if ([phoneNumber isEqualToString: hotline]) {
            tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip='%@' AND phone_number = '%@' AND date='%@' ORDER BY time_int DESC", mySip, phoneNumber, dateStr];
        }else{
            if (onlyMissedCall) {
                tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip='%@' AND phone_number LIKE '%%%@%%' AND date='%@' AND status = '%@' ORDER BY time_int DESC", mySip, phoneNumber, dateStr, missed_call];
            }else{
                tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip='%@' AND phone_number LIKE '%%%@%%' AND date='%@' ORDER BY time_int DESC", mySip, phoneNumber, dateStr];
            }
        }
        
        FMResultSet *rs = [db executeQuery: tSQL];
        while ([rs next]) {
            NSDictionary *rsDict = [rs resultDictionary];
            
            NSString *time = [rsDict objectForKey:@"time"];
            NSString *status = [rsDict objectForKey:@"status"];
            int duration = [[rsDict objectForKey:@"duration"] intValue];
            float rate = [[rsDict objectForKey:@"rate"] floatValue];
            NSString *call_direction = [rsDict objectForKey:@"call_direction"];
            long timeInt = [[rsDict objectForKey:@"time_int"] longValue];
            int call_type = [[rsDict objectForKey:@"call_type"] intValue];
            
            CallHistoryObject *aCall = [[CallHistoryObject alloc] init];
            aCall._time = time;
            aCall._status= status;
            aCall._duration = duration;
            aCall._rate = rate;
            aCall._date = @"date";
            aCall._callDirection = call_direction;
            aCall._timeInt = timeInt;
            aCall.typeCall = call_type;
            
            [resultArr addObject: aCall];
        }
        [rs close];
    }];
    return resultArr;
}

+ (BOOL)resetMissedCallOfRemote: (NSString *)remote onDate: (NSString *)date ofAccount: (NSString *)account
{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE history SET unread = %d WHERE my_sip = '%@' AND date = '%@' AND phone_number = '%@'", 0, account, date, remote];
    return [dbUtilAppDel.database executeUpdate: tSQL];
}

+ (BOOL)deleteCallHistoryOfRemote: (NSString *)remote onDate: (NSString *)date ofAccount: (NSString *)account {
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM history WHERE my_sip = '%@' and phone_number = '%@' and date = '%@'", account, remote, date];
    BOOL result = [dbUtilAppDel.database executeUpdate: tSQL];
    return result;
}

+ (NSString *)getLastCallOfUser {
    NSString *phone = @"";
    //  NSString *tSQL = [NSString stringWithFormat:@"SELECT phone_number FROM history WHERE my_sip = '%@' AND call_direction = '%@' AND sipURI NOT LIKE '%%%@%%'  ORDER BY _id DESC LIMIT 0,1", USERNAME, outgoing_call, hotline];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT phone_number FROM history WHERE my_sip = '%@' AND call_direction = '%@' ORDER BY _id DESC LIMIT 0,1", USERNAME, outgoing_call];
    FMResultSet *rs = [dbUtilAppDel.database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        phone = [rsDict objectForKey:@"phone_number"];
    }
    [rs close];
    return phone;
}

+ (BOOL)checkMissedCallExistsFromUser: (NSString *)phone withAccount: (NSString *)account atTime: (long)time
{
    BOOL result = FALSE;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip = '%@' AND status = '%@' AND phone_number = '%@' AND time_int = %ld LIMIT 0,1", account, missed_call, phone, time];
    FMResultSet *rs = [dbUtilAppDel.database executeQuery: tSQL];
    while ([rs next]) {
        result = TRUE;
        break;
    }
    [rs close];
    return result;
}

@end
