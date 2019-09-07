//
//  WriteLogsUtils.h
//  iMomeet
//
//  Created by lam quang quan on 11/12/18.
//  Copyright © 2018 Softfoundry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WriteLogsUtils : NSObject

+ (void)startWriteLogsUtil;
+ (NSString *)makeFilePathWithFileName:(NSString *)fileName;
+ (BOOL)createLogFileWithName: (NSString *)filePathName;
+ (NSString *)getLogContentIfExistsFromFile: (NSString *)fileName isFullPath: (BOOL)isFullPath;
+ (void)clearLogFilesAfterExpireTime: (long)expireTime;
+ (void)removeFileWithPath: (NSString *)path;
+ (NSArray *)getAllFilesInDirectory: (NSString *)subPath;
+ (NSString *)getLogFileNameForCurrentDay;
+ (void)writeForGoToScreen: (NSString *)screen;
+ (void)writeLogContent: (NSString *)logContent;

@end
