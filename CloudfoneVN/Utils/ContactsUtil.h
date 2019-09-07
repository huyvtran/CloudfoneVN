//
//  ContactsUtil.h
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneObject.h"
#import "PBXContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactsUtil : NSObject

+ (void)startContactsUtil;
+ (NSAttributedString *)getSearchValueFromResultForNewSearchMethod: (NSArray *)searchs;
+ (NSString *)getBase64AvatarFromContact: (ABRecordRef)aPerson;
+ (NSString *)getFullNameFromContact: (ABRecordRef)aPerson;
+ (NSString *)getAvatarFromContactPerson: (ABRecordRef)person;
+ (UIImage *)getAvatarFromContact: (ABRecordRef)aPerson;
+ (NSString *)getFirstPhoneFromContact: (ABRecordRef)aPerson;

+ (NSString *)getCompanyFromContact: (ABRecordRef)aPerson;
+ (NSString *)getEmailFromContact: (ABRecordRef)aPerson;
+ (NSMutableArray *)getListPhoneOfContactPerson: (ABRecordRef)aPerson;
+ (NSArray *)getFirstNameAndLastNameOfContact: (ABRecordRef)aPerson;
+ (NSString *)getFullnameOfContactIfExists;
+ (ABRecordRef)addNewContacts;
+ (PhoneObject *)getContactPhoneObjectWithNumber: (NSString *)number;
+ (PBXContact *)getPBXContactWithExtension: (NSString *)ext;

@end

NS_ASSUME_NONNULL_END
