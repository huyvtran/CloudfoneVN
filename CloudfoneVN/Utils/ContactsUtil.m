//
//  ContactsUtil.m
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "ContactsUtil.h"
#import "PhoneObject.h"
#import "ContactDetailObj.h"

AppDelegate *contactUtilAppDel;

@implementation ContactsUtil

+ (void)startContactsUtil {
    contactUtilAppDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (NSAttributedString *)getSearchValueFromResultForNewSearchMethod: (NSArray *)searchs
{
    UIFont *font = contactUtilAppDel.fontNormalBold;
    NSMutableAttributedString *attrResult = [[NSMutableAttributedString alloc] init];
    
    if (searchs.count == 1) {
        PhoneObject *phone = [searchs firstObject];
        
        [attrResult appendAttributedString:[[NSAttributedString alloc] initWithString: phone.name]];
        [attrResult addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, phone.name.length)];
        [attrResult addAttribute: NSLinkAttributeName value:phone.number range: NSMakeRange(0, phone.name.length)];
    }else if (searchs.count == 2)
    {
        PhoneObject *phone = [searchs firstObject];
        
        [attrResult appendAttributedString:[[NSAttributedString alloc] initWithString: phone.name]];
        [attrResult addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, phone.name.length)];
        [attrResult addAttribute: NSLinkAttributeName value:phone.number range: NSMakeRange(0, phone.name.length)];
        
        phone = [searchs lastObject];
        
        NSString *strOR = SFM(@" %@ ", [contactUtilAppDel.localization localizedStringForKey:@"or"]);
        [attrResult appendAttributedString:[[NSAttributedString alloc] initWithString: strOR]];
        
        NSMutableAttributedString *secondAttr = [[NSMutableAttributedString alloc] initWithString: phone.name];
        [secondAttr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, phone.name.length)];
        [secondAttr addAttribute: NSLinkAttributeName value:phone.number range: NSMakeRange(0, phone.name.length)];
        [attrResult appendAttributedString:secondAttr];
    }else if (searchs.count > 0){
        PhoneObject *phone = [searchs firstObject];
        
        NSMutableAttributedString * str1 = [[NSMutableAttributedString alloc] initWithString:phone.name];
        [str1 addAttribute: NSLinkAttributeName value:phone.number range: NSMakeRange(0, phone.name.length)];
        [str1 addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:NSMakeRange(0, phone.name.length)];
        [str1 addAttribute: NSFontAttributeName value: font range: NSMakeRange(0, phone.name.length)];
        [attrResult appendAttributedString:str1];
        
        NSString *strAND = SFM(@" %@ ", [contactUtilAppDel.localization localizedStringForKey:@"and"]);
        NSMutableAttributedString * attrAnd = [[NSMutableAttributedString alloc] initWithString:strAND];
        [attrAnd addAttribute: NSFontAttributeName value: [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0]
                        range: NSMakeRange(0, strAND.length)];
        [attrResult appendAttributedString:attrAnd];
        
        NSString *strOthers = SFM(@"%d %@", (int)searchs.count-1, [contactUtilAppDel.localization localizedStringForKey:@"others"]);
        NSMutableAttributedString * str2 = [[NSMutableAttributedString alloc] initWithString:strOthers];
        [str2 addAttribute: NSLinkAttributeName value: @"others" range: NSMakeRange(0, strOthers.length)];
        [str2 addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:NSMakeRange(0, strOthers.length)];
        [str2 addAttribute: NSFontAttributeName value: font range: NSMakeRange(0, strOthers.length)];
        [attrResult appendAttributedString:str2];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attrResult addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrResult.string.length)];
    
    return attrResult;
}

+ (NSString *)getBase64AvatarFromContact: (ABRecordRef)aPerson
{
    if (aPerson != nil) {
        NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(aPerson);
        if (imgData != nil) {
            return [imgData base64EncodedStringWithOptions: 0];
        }
    }
    return @"";
}

+ (NSString *)getFullNameFromContact: (ABRecordRef)aPerson
{
    if (aPerson != nil) {
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        firstName = [firstName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        firstName = [firstName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *middleName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonMiddleNameProperty);
        middleName = [middleName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        middleName = [middleName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        lastName = [lastName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        lastName = [lastName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        // Lưu tên contact cho search phonebook
        NSString *fullname = @"";
        if (![AppUtil isNullOrEmpty: lastName]) {
            fullname = lastName;
        }
        
        if (![AppUtil isNullOrEmpty: middleName]) {
            if ([fullname isEqualToString:@""]) {
                fullname = middleName;
            }else{
                fullname = SFM(@"%@ %@", fullname, middleName);
            }
        }
        
        if (![AppUtil isNullOrEmpty: firstName]) {
            if ([fullname isEqualToString:@""]) {
                fullname = firstName;
            }else{
                fullname = SFM(@"%@ %@", fullname, firstName);
            }
        }
        if ([fullname isEqualToString:@""]) {
            return [contactUtilAppDel.localization localizedStringForKey:@"Unknown"];
        }
        return fullname;
    }
    return [contactUtilAppDel.localization localizedStringForKey:@"Unknown"];
}

+ (UIImage *)getAvatarFromContact: (ABRecordRef)aPerson
{
    if (aPerson != nil) {
        NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(aPerson);
        if (imgData != nil) {
            return [UIImage imageWithData: imgData];
        }
    }
    return [UIImage imageNamed:@"no_avatar.png"];
}

+ (NSString *)getFirstPhoneFromContact: (ABRecordRef)aPerson
{
    ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phones) > 0)
    {
        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, 0);
        NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
        phoneNumber = [AppUtil removeAllSpecialInString: phoneNumber];
        return phoneNumber;
    }
    return @"";
}

+ (NSString *)getEmailFromContact: (ABRecordRef)aPerson {
    NSString *email = @"";
    ABMultiValueRef map = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
    if (map) {
        for (int i = 0; i < ABMultiValueGetCount(map); ++i) {
            ABMultiValueIdentifier identifier = ABMultiValueGetIdentifierAtIndex(map, i);
            NSInteger index = ABMultiValueGetIndexForIdentifier(map, identifier);
            if (index != -1) {
                NSString *valueRef = CFBridgingRelease(ABMultiValueCopyValueAtIndex(map, index));
                if (valueRef != NULL && ![valueRef isEqualToString:@""]) {
                    //  just get one email for contact
                    email = valueRef;
                    break;
                }
            }
        }
        CFRelease(map);
    }
    return email;
}

+ (NSString *)getCompanyFromContact: (ABRecordRef)aPerson {
    NSString *result = @"";
    CFStringRef companyRef  = ABRecordCopyValue(aPerson, kABPersonOrganizationProperty);
    if (companyRef != NULL && companyRef != nil){
        NSString *company = (__bridge NSString *)companyRef;
        if (company != nil && ![company isEqualToString:@""]){
            result = company;
        }
    }
    return result;
}

+ (NSMutableArray *)getListPhoneOfContactPerson: (ABRecordRef)aPerson
{
    NSMutableArray *result = nil;
    ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
    NSString *strPhone = [[NSMutableString alloc] init];
    if (ABMultiValueGetCount(phones) > 0)
    {
        result = [[NSMutableArray alloc] init];
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
            CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
            
            NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
            phoneNumber = [AppUtil removeAllSpecialInString: phoneNumber];
            
            strPhone = @"";
            if (locLabel == nil) {
                ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                anItem._iconStr = @"btn_contacts_home.png";
                anItem._titleStr = [contactUtilAppDel.localization localizedStringForKey:@"Home"];
                anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                anItem._buttonStr = @"contact_detail_icon_call.png";
                anItem._typePhone = type_phone_home;
                [result addObject: anItem];
            }else{
                if (CFStringCompare(locLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_home.png";
                    anItem._titleStr = [contactUtilAppDel.localization localizedStringForKey:@"Home"];
                    anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_home;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABWorkLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_work.png";
                    anItem._titleStr = [contactUtilAppDel.localization localizedStringForKey:@"Work"];
                    anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_work;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_mobile.png";
                    anItem._titleStr = [contactUtilAppDel.localization localizedStringForKey:@"Mobile"];
                    anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_mobile;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABPersonPhoneHomeFAXLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_fax.png";
                    anItem._titleStr = [contactUtilAppDel.localization localizedStringForKey:@"Fax"];
                    anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_fax;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABOtherLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_fax.png";
                    anItem._titleStr = [contactUtilAppDel.localization localizedStringForKey:@"Other"];
                    anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_other;
                    [result addObject: anItem];
                }else{
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_mobile.png";
                    anItem._titleStr = [contactUtilAppDel.localization localizedStringForKey:@"Mobile"];
                    anItem._valueStr = [AppUtil removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_mobile;
                    [result addObject: anItem];
                }
            }
        }
    }
    return result;
}

+ (NSArray *)getFirstNameAndLastNameOfContact: (ABRecordRef)aPerson
{
    if (aPerson != nil) {
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        if (firstName == nil) {
            firstName = @"";
        }
        firstName = [firstName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        firstName = [firstName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *middleName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonMiddleNameProperty);
        if (middleName == nil) {
            middleName = @"";
        }
        middleName = [middleName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        middleName = [middleName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        if (lastName == nil) {
            lastName = @"";
        }
        lastName = [lastName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        lastName = [lastName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        // Lưu tên contact cho search phonebook
        NSString *fullname = @"";
        if (![lastName isEqualToString:@""]) {
            fullname = lastName;
        }
        
        if (![middleName isEqualToString:@""]) {
            if ([fullname isEqualToString:@""]) {
                fullname = middleName;
            }else{
                fullname = SFM(@"%@ %@", fullname, middleName);
            }
        }
        return @[firstName, fullname];
    }
    return @[@"", @""];
}

+ (NSString *)getFullnameOfContactIfExists {
    NSString *fullname = @"";
    
    if (contactUtilAppDel.newContact._firstName != nil && contactUtilAppDel.newContact._lastName != nil) {
        fullname = SFM(@"%@ %@", contactUtilAppDel.newContact._lastName, contactUtilAppDel.newContact._firstName);
        
    }else if (contactUtilAppDel.newContact._firstName != nil && contactUtilAppDel.newContact._lastName == nil){
        fullname = contactUtilAppDel.newContact._firstName;
        
    }else if (contactUtilAppDel.newContact._firstName == nil && contactUtilAppDel.newContact._lastName != nil){
        fullname = contactUtilAppDel.newContact._lastName;
    }
    return fullname;
}

+ (ABRecordRef)addNewContacts
{
    NSString *convertName = [AppUtil convertUTF8CharacterToCharacter: contactUtilAppDel.newContact._firstName];
    NSString *nameForSearch = [AppUtil getNameForSearchOfConvertName:convertName];
    contactUtilAppDel.newContact._nameForSearch = nameForSearch;
    
    
    if (contactUtilAppDel.dataCrop != nil) {
        contactUtilAppDel.newContact._avatar = [contactUtilAppDel.dataCrop base64EncodedStringWithOptions: 0];
    }else{
        contactUtilAppDel.newContact._avatar = @"";
    }
    
    ABRecordRef aRecord = ABPersonCreate();
    CFErrorRef  anError = NULL;
    
    // Lưu thông tin
    ABRecordSetValue(aRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)(contactUtilAppDel.newContact._firstName), &anError);
    ABRecordSetValue(aRecord, kABPersonLastNameProperty, (__bridge CFTypeRef)(contactUtilAppDel.newContact._lastName), &anError);
    ABRecordSetValue(aRecord, kABPersonOrganizationProperty, (__bridge CFTypeRef)(contactUtilAppDel.newContact._company), &anError);
    ABRecordSetValue(aRecord, kABPersonFirstNamePhoneticProperty, (__bridge CFTypeRef)(contactUtilAppDel.newContact._sipPhone), &anError);
    
    if (contactUtilAppDel.newContact._email == nil) {
        contactUtilAppDel.newContact._email = @"";
    }
    
    ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(email, (__bridge CFTypeRef)(contactUtilAppDel.newContact._email), CFSTR("email"), NULL);
    ABRecordSetValue(aRecord, kABPersonEmailProperty, email, &anError);
    
    if (contactUtilAppDel.dataCrop != nil) {
        CFDataRef cfdata = CFDataCreate(NULL,[contactUtilAppDel.dataCrop bytes], [contactUtilAppDel.dataCrop length]);
        ABPersonSetImageData(aRecord, cfdata, &anError);
    }
    
    // Phone number
    NSMutableArray *listPhone = [[NSMutableArray alloc] init];
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    for (int iCount=0; iCount<contactUtilAppDel.newContact._listPhone.count; iCount++) {
        ContactDetailObj *aPhone = [contactUtilAppDel.newContact._listPhone objectAtIndex: iCount];
        if ([AppUtil isNullOrEmpty: aPhone._valueStr]) {
            continue;
        }
        if ([aPhone._typePhone isEqualToString: type_phone_mobile]) {
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._valueStr), kABPersonPhoneMobileLabel, NULL);
            [listPhone addObject: aPhone];
        }else if ([aPhone._typePhone isEqualToString: type_phone_work]){
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._valueStr), kABWorkLabel, NULL);
            [listPhone addObject: aPhone];
        }else if ([aPhone._typePhone isEqualToString: type_phone_fax]){
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._valueStr), kABPersonPhoneHomeFAXLabel, NULL);
            [listPhone addObject: aPhone];
        }else if ([aPhone._typePhone isEqualToString: type_phone_home]){
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._valueStr), kABHomeLabel, NULL);
            [listPhone addObject: aPhone];
        }else if ([aPhone._typePhone isEqualToString: type_phone_other]){
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._valueStr), kABOtherLabel, NULL);
            [listPhone addObject: aPhone];
        }
    }
    ABRecordSetValue(aRecord, kABPersonPhoneProperty, multiPhone,nil);
    CFRelease(multiPhone);
    
    //Address
    ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    NSMutableDictionary *addressDict = [[NSMutableDictionary alloc] init];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressStreetKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressZIPKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressStateKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressCityKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressCountryKey];
    ABMultiValueAddValueAndLabel(address, (__bridge CFTypeRef)(addressDict), kABWorkLabel, NULL);
    ABRecordSetValue(aRecord, kABPersonAddressProperty, address, &anError);
    
    if (anError != NULL) {
        NSLog(@"error while creating..");
    }
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, &error);
    
    BOOL isAdded = ABAddressBookAddRecord (addressBook,aRecord,&error);
    
    if(isAdded){
        NSLog(@"added..");
    }
    if (error != NULL) {
        NSLog(@"ABAddressBookAddRecord %@", error);
    }
    error = NULL;
    
    BOOL isSaved = ABAddressBookSave (addressBook,&error);
    if(isSaved){
        NSLog(@"saved..");
    }
    
    if (error != NULL) {
        NSLog(@"ABAddressBookSave %@", error);
    }
    return aRecord;
}

+ (PhoneObject *)getContactPhoneObjectWithNumber: (NSString *)number {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number = %@", number];
    NSMutableArray *list = contactUtilAppDel.listInfoPhoneNumber;
    NSArray *filter = [list filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        for (int i=0; i<filter.count; i++) {
            PhoneObject *item = [filter objectAtIndex: i];
            if (![AppUtil isNullOrEmpty: item.avatar]) {
                return item;
            }
        }
        return [filter firstObject];
    }
    return nil;
}

+ (PBXContact *)getPBXContactWithExtension: (NSString *)ext {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_number = %@", ext];
    NSArray *filter = [contactUtilAppDel.pbxContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        return [filter objectAtIndex: 0];
    }
    return nil;
}

@end
