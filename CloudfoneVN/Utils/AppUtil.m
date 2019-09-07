//
//  AppUtil.m
//  CloudfoneVN
//
//  Created by Khai Leo on 8/25/19.
//  Copyright © 2019 CloudfoneVN. All rights reserved.
//

#import "AppUtil.h"

AppDelegate *appUtilAppDel;

@implementation AppUtil

+ (void)startAppUtil {
    appUtilAppDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (NSString *)getAppVersionWithBuildVersion: (BOOL)showBuildVersion {
    NSString *version = @"";
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    
    if (!showBuildVersion) {
        version = [info objectForKey:@"CFBundleShortVersionString"];
    }else{
        version = SFM(@"%@ (%@)", [info objectForKey:@"CFBundleShortVersionString"], [info objectForKey:@"CFBundleVersion"]);
    }
    return version;
}

+ (NSString *)getCurrentDateTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (NSString *)getCurrentDate{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

+ (NSString *)getDateFromTimeInterval: (NSTimeInterval)interval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: interval];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

+(BOOL)isNullOrEmpty:(NSString*)string{
    return string == nil || string==(id)[NSNull null] || [string isEqualToString: @""];
}

+ (UIImage *)imageWithColor:(UIColor *)color andBounds:(CGRect)imgBounds {
    UIGraphicsBeginImageContextWithOptions(imgBounds.size, NO, 0);
    [color setFill];
    UIRectFill(imgBounds);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (NSString *)getBuildDateWithTime: (BOOL)showTime
{
    NSString *dateStr = SFM(@"%@ %@", [NSString stringWithUTF8String:__DATE__], [NSString stringWithUTF8String:__TIME__]);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"LLL d yyyy HH:mm:ss"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDate *date1 = [dateFormatter dateFromString:dateStr];
    
    NSTimeInterval time = [date1 timeIntervalSince1970];
    NSString *dateResult = [AppUtil stringDateFromInterval: time];
    if (showTime) {
        NSString *timeResult = [AppUtil stringTimeFromInterval: time];
        return SFM(@"%@ %@", dateResult, timeResult);
    }else{
        return dateResult;
    }
}

+ (NSString *)stringTimeFromInterval: (NSTimeInterval)interval{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *currentTime = [dateFormatter stringFromDate: date];
    return currentTime;
}

+ (NSString *)stringDateFromInterval: (NSTimeInterval)interval{
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:language_key];
    if (language == nil) {
        language = key_en;
        [[NSUserDefaults standardUserDefaults] setObject:language forKey:language_key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: interval];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    if ([language isEqualToString: key_en]) {
        [dateFormat setDateFormat:@"MM-dd-yyyy"];
    }else{
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
    }
    
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

+ (void)addCornerRadiusTopLeftAndBottomLeftForButton: (id)view radius: (float)radius withColor: (UIColor *)borderColor border: (float)borderWidth{
    if ([view isKindOfClass:[UIView class]]) {
        CAShapeLayer * maskLayer = [CAShapeLayer layer];
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: [(UIView *)view bounds] byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii: (CGSize){radius, radius}].CGPath;
        [(UIView *)view layer].mask = maskLayer;
        
        //Give Border
        //Create path for border
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:[(UIView *)view bounds]
                                                         byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft
                                                               cornerRadii:CGSizeMake(radius, radius)];
        // Create the shape layer and set its path
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        
        borderLayer.frame       = [(UIView *)view bounds];
        borderLayer.path        = borderPath.CGPath;
        borderLayer.strokeColor = borderColor.CGColor;
        borderLayer.fillColor   = UIColor.clearColor.CGColor;
        borderLayer.lineWidth   = borderWidth;
        
        //Add this layer to give border.
        [[(UIView *)view layer] addSublayer:borderLayer];
    }
}

+ (void)addCornerRadiusTopRightAndBottomRightForButton: (id)view radius: (float)radius withColor: (UIColor *)borderColor border: (float)borderWidth {
    if ([view isKindOfClass:[UIView class]]) {
        CAShapeLayer * maskLayer = [CAShapeLayer layer];
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: [(UIView *)view bounds] byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii: (CGSize){radius, radius}].CGPath;
        [(UIView *)view layer].mask = maskLayer;
        
        //Give Border
        //Create path for border
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:[(UIView *)view bounds]
                                                         byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                                                               cornerRadii:CGSizeMake(radius, radius)];
        // Create the shape layer and set its path
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        
        borderLayer.frame       = [(UIView *)view bounds];
        borderLayer.path        = borderPath.CGPath;
        borderLayer.strokeColor = borderColor.CGColor;
        borderLayer.fillColor   = UIColor.clearColor.CGColor;
        borderLayer.lineWidth   = borderWidth;
        
        //Add this layer to give border.
        [[(UIView *)view layer] addSublayer:borderLayer];
    }
}

+ (void)setSelected: (BOOL)selected forButton: (UIButton *)button {
    button.backgroundColor = (selected) ? SELECT_TAB_BG_COLOR : UIColor.clearColor;
}

// Hàm chuyển chuỗi ký tự có dấu thành không dấu
+ (NSString *)convertUTF8CharacterToCharacter: (NSString *)parentStr{
    NSData *dataConvert = [parentStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *convertName = [[NSString alloc] initWithData:dataConvert encoding:NSASCIIStringEncoding];
    return convertName;
}

// Chuyển từ convert name sang tên seach dạng số
+ (NSString *)getNameForSearchOfConvertName: (NSString *)convertName{
    convertName = [AppUtil convertUTF8CharacterToCharacter: convertName];
    
    convertName = [convertName lowercaseString];
    NSString *result = @"";
    for (int strCount=0; strCount<convertName.length; strCount++) {
        char characterChar = [convertName characterAtIndex: strCount];
        NSString *c = SFM(@"%c", characterChar);
        if ([c isEqualToString:@"a"] || [c isEqualToString:@"b"] || [c isEqualToString:@"c"]) {
            result = SFM(@"%@%@", result, @"2");
        }else if([c isEqualToString:@"d"] || [c isEqualToString:@"e"] || [c isEqualToString:@"f"]){
            result = SFM(@"%@%@", result, @"3");
        }else if ([c isEqualToString:@"g"] || [c isEqualToString:@"h"] || [c isEqualToString:@"i"]){
            result = SFM(@"%@%@", result, @"4");
        }else if ([c isEqualToString:@"j"] || [c isEqualToString:@"k"] || [c isEqualToString:@"l"]){
            result = SFM(@"%@%@", result, @"5");
        }else if ([c isEqualToString:@"m"] || [c isEqualToString:@"n"] || [c isEqualToString:@"o"]){
            result = SFM(@"%@%@", result, @"6");
        }else if ([c isEqualToString:@"p"] || [c isEqualToString:@"q"] || [c isEqualToString:@"r"] || [c isEqualToString:@"s"]){
            result = SFM(@"%@%@", result, @"7");
        }else if ([c isEqualToString:@"t"] || [c isEqualToString:@"u"] || [c isEqualToString:@"v"]){
            result = SFM(@"%@%@", result, @"8");
        }else if ([c isEqualToString:@"w"] || [c isEqualToString:@"x"] || [c isEqualToString:@"y"] || [c isEqualToString:@"z"]){
            result = SFM(@"%@%@", result, @"9");
        }else if ([c isEqualToString:@"1"]){
            result = SFM(@"%@%@", result, @"1");
        }else if ([c isEqualToString:@"0"]){
            result = SFM(@"%@%@", result, @"0");
        }else if ([c isEqualToString:@" "])
        {
            result = SFM(@"%@%@", result, @" ");
        }else{
            result = SFM(@"%@%@", result, c);
        }
    }
    return result;
}


+ (NSString *)getNameOfContact: (ABRecordRef)aPerson
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
        return fullname;
    }
    return @"";
}

+ (NSData *)getFileDataFromDirectoryWithFileName: (NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: pathFile];
    
    if (!fileExists) {
        return nil;
    }else{
        NSData *fileData = [NSData dataWithContentsOfFile: pathFile];
        return fileData;
    }
}

// Chuyển kí tự có dấu thành kí tự ko dấu
+ (NSString *)convertUTF8StringToString: (NSString *)string {
    if ([string isEqualToString:@"À"] || [string isEqualToString:@"Ã"] || [string isEqualToString:@"Ạ"]  || [string isEqualToString:@"Á"] || [string isEqualToString:@"Ả"]  || [string isEqualToString:@"Ằ"] || [string isEqualToString:@"Ẵ"] || [string isEqualToString:@"Ặ"] || [string isEqualToString:@"Ắ"] || [string isEqualToString:@"Ẳ"] || [string isEqualToString:@"Ă"] || [string isEqualToString:@"Ầ"] || [string isEqualToString:@"Ẫ"] || [string isEqualToString:@"Ậ"] || [string isEqualToString:@"Ấ"] || [string isEqualToString:@"Ẩ"] || [string isEqualToString:@"Â"]) {
        string = @"A";
    }else if ([string isEqualToString:@"Đ"]) {
        string = @"D";
    }else if ([string isEqualToString:@"È"] || [string isEqualToString:@"Ẽ"] || [string isEqualToString:@"Ẹ"] || [string isEqualToString:@"É"] || [string isEqualToString:@"Ẻ"]  || [string isEqualToString:@"Ề"] || [string isEqualToString:@"Ễ"] || [string isEqualToString:@"Ệ"] || [string isEqualToString:@"Ế"] || [string isEqualToString:@"Ể"] || [string isEqualToString:@"Ê"]) {
        string = @"E";
    }else if([string isEqualToString:@"Ì"] || [string isEqualToString:@"Ĩ"] || [string isEqualToString:@"Ị"] || [string isEqualToString:@"Í"] || [string isEqualToString:@"Ỉ"]) {
        string = @"I";
    }else if([string isEqualToString:@"Ò"] || [string isEqualToString:@"Õ"] || [string isEqualToString:@"Ọ"] || [string isEqualToString:@"Ó"] || [string isEqualToString:@"Ỏ"] || [string isEqualToString:@"Ờ"] || [string isEqualToString:@"Ở"] || [string isEqualToString:@"Ợ"] || [string isEqualToString:@"Ớ"] || [string isEqualToString:@"Ở"] || [string isEqualToString:@"Ơ"] || [string isEqualToString:@"Ồ"] || [string isEqualToString:@"Ỗ"] || [string isEqualToString:@"Ộ"] || [string isEqualToString:@"Ố"] || [string isEqualToString:@"Ổ"] || [string isEqualToString:@"Ô"]) {
        string = @"O";
    }else if ([string isEqualToString:@"Ù"] || [string isEqualToString:@"Ũ"] || [string isEqualToString:@"Ụ"] || [string isEqualToString:@"Ú"] || [string isEqualToString:@"Ủ"]) {
        string = @"U";
    }else if([string isEqualToString:@"Ỳ"] || [string isEqualToString:@"Ỹ"] || [string isEqualToString:@"Ỵ"] || [string isEqualToString:@"Ý"] || [string isEqualToString:@"Ỷ"]) {
        string = @"Y";
    }
    return string;
}

+ (NSString *)removeAllSpecialInString: (NSString *)phoneString {
    NSString *resultStr = @"";
    for (int strCount=0; strCount<phoneString.length; strCount++) {
        char characterChar = [phoneString characterAtIndex: strCount];
        NSString *characterStr = SFM(@"%c", characterChar);
        if ([appUtilAppDel.listNumber containsObject: characterStr]) {
            resultStr = SFM(@"%@%@", resultStr, characterStr);
        }
    }
    return resultStr;
}


+ (NSString *)getAvatarFromContactPerson: (ABRecordRef)person {
    return @"";
}

+ (UIImage*)cropImageWithSize:(CGSize)targetSize fromImage: (UIImage *)sourceImage
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 1;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 1;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (NSString *)getTypeOfPhone: (NSString *)typePhone {
    if ([typePhone isEqualToString: type_phone_mobile]) {
        return @"btn_contacts_mobile.png";
    }else if ([typePhone isEqualToString: type_phone_work]){
        return @"btn_contacts_work.png";
    }else if ([typePhone isEqualToString: type_phone_fax]){
        return @"btn_contacts_fax.png";
    }else if ([typePhone isEqualToString: type_phone_home]){
        return @"btn_contacts_home.png";
    }else{
        return @"btn_contacts_mobile.png";
    }
}

+ (NSString *)durationToString:(int)duration {
    NSMutableString *result = [[NSMutableString alloc] init];
    if (duration / 3600 > 0) {
        [result appendString:SFM(@"%02i:", duration / 3600)];
        duration = duration % 3600;
    }
    return [result stringByAppendingString:SFM(@"%02i:%02i", (duration / 60), (duration % 60))];
}

+ (NSString *)getCurrentTimeStamp{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    NSString *currentTime = [dateFormatter stringFromDate:now];
    return currentTime;
}

+ (NSString *)getCurrentTimeStampFromTimeInterval:(double)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return formattedDateString;
}

+ (NSString *)randomStringWithLength: (int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int iCount=0; iCount<len; iCount++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length]) % [letters length]]];
    }
    return randomString;
}

+ (NSString *)getTimeStringFromTimeInterval:(double)timeInterval {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return formattedDateString;
}

+ (NSString *)convertDurtationToString: (long)duration
{
    int hour = (int)(duration/3600);
    int minutes = (int)((duration - hour*3600)/60);
    int seconds = (int)(duration - hour*3600 - minutes*60);
    
    NSString *result = @"";
    if (hour > 0) {
        if (hour == 1) {
            result = SFM(@"%ld %@", (long)hour, [appUtilAppDel.localization localizedStringForKey:@"hour"]);;
        }else{
            result = SFM(@"%ld %@", (long)hour, [appUtilAppDel.localization localizedStringForKey:@"hours"]);
        }
    }
    
    if (minutes > 0) {
        if (![result isEqualToString:@""]) {
            if (minutes == 1) {
                result = SFM(@"%@ %d %@", result, minutes, [appUtilAppDel.localization localizedStringForKey:@"minute"]);
            }else{
                result = SFM(@"%@ %d %@", result, minutes, [appUtilAppDel.localization localizedStringForKey:@"minutes"]);
            }
        }else{
            if (minutes == 1) {
                result = SFM(@"%d %@", minutes, [appUtilAppDel.localization localizedStringForKey:@"minute"]);
            }else{
                result = SFM(@"%d %@", minutes, [appUtilAppDel.localization localizedStringForKey:@"minutes"]);
            }
        }
    }
    
    if (seconds > 0) {
        if (![result isEqualToString:@""]) {
            result = SFM(@"%@ %d %@", result, seconds, [appUtilAppDel.localization localizedStringForKey:@"sec"]);
        }else{
            result = SFM(@"%d %@", seconds, [appUtilAppDel.localization localizedStringForKey:@"sec"]);
        }
    }
    return result;
}

+ (NSString *)getNameWasStoredFromUserInfo: (NSString *)number {
    NSString *key = [NSString stringWithFormat:@"name_for_%@", number];
    NSString *display = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (![AppUtil isNullOrEmpty: display]) {
        return display;
    }
    return [appUtilAppDel.localization localizedStringForKey:@"Unknown"];
}

+ (NSString *)checkTodayForHistoryCall: (NSString *)dateStr{
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow: 0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"yyyy-MM-dd"];
    [formatter2 setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    
    NSString *currentTime = [formatter stringFromDate: today];
    NSString *currentTime2 = [formatter2 stringFromDate: today];
    
    if ([currentTime isEqualToString: dateStr] || [currentTime2 isEqualToString: dateStr]) {
        return @"Today";
    }else{
        return currentTime;
    }
}

/* Trả về title cho header section trong phần history call */
+ (NSString *)checkYesterdayForHistoryCall: (NSString *)dateStr{
    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow: -(60.0f*60.0f*24.0f)];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"yyyy/MM/dd"];
    [formatter2 setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    
    NSString *currentTime = [formatter stringFromDate: yesterday];
    NSString *currentTime2 = [formatter2 stringFromDate: yesterday];
    
    if ([currentTime isEqualToString: dateStr] || [currentTime2 isEqualToString: dateStr]) {
        return @"Yesterday";
    }else{
        return currentTime;
    }
}

+ (NSString *)getDateFromInterval: (double)timeInterval {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return formattedDateString;
}

+ (NSString *)getFullTimeStringFromTimeInterval:(double)timeInterval {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    //    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return formattedDateString;
}

@end
