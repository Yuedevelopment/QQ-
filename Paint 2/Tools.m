//
//  Tools.m
//  SwifTest
//
//  Created by jyg on 16/2/27.
//  Copyright © 2016年 jyg. All rights reserved.
//

#import "Tools.h"
#import <CommonCrypto/CommonDigest.h>
#import <CoreData/CoreData.h>

//UUID
#define chainKey           @"uniqueDeviceIdentifierKey"

@implementation Tools

static NSManagedObjectContext *_managedObjectContext;
static NSPersistentStoreCoordinator *_persistentStoreCoordinator;
static NSManagedObjectModel *_managedObjectModel;

NSInteger _openid = 0;
NSString *_token = nil;

NSString *_curLan = nil;
NSDictionary *_curLanDic = nil;

BOOL _logined = NO;

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark 钥匙链
NSMutableDictionary *GetKeychainQuery(NSString *service) {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword,(__bridge id)kSecClass,
            service, (__bridge id)kSecAttrService,
            service, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock,(__bridge id)kSecAttrAccessible,
            nil];
}

void SaveKeychain(NSString *service, id data) {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = GetKeychainQuery(service);
    //Delete old item before add new item
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

id LoadKeychain(NSString *service) {
    id ret = nil;
    NSMutableDictionary *keychainQuery = GetKeychainQuery(service);
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

void DeleteKeychain(NSString *service) {
    NSMutableDictionary *keychainQuery = GetKeychainQuery(service);
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark 快捷方法
void AfterDispatch(double delayInSeconds, dispatch_block_t _Nullable block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

void MainDispatch(dispatch_block_t _Nullable block) {
    dispatch_async(dispatch_get_main_queue(), block);
}

void GlobalDispatch(dispatch_block_t _Nullable block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

CGFloat SW() {
    return SCREENWIDTH;
}
CGFloat SH() {
    return SCREENHEIGHT;
}

CGRect SF() {
    return CGRectMake(0, 0, SW(), SH());
}

CGFloat S1080(CGFloat p)
{
    return p*SCREENWIDTH/360;
}

UIColor * _Nonnull RGBA(NSInteger rgbValue, CGFloat alpha) {
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:alpha];
}

UIColor * _Nonnull MainBackColor() {
    return RGBA(0x272525, 1);
}

UIColor * _Nonnull CellSelectColor() {
    return RGBA(0x282727, 0.5);
}

UIColor * _Nonnull CellBackColor() {
    return RGBA(0x383838, 1);
}

UIColor * _Nonnull CellLabelColor() {
    return RGBA(0x8b8b8b, 1);
}

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark JSONData
id objectFromJSONData(NSData *data) {
    NSError *error;
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error != nil) return nil;
    return result;
}

id objectFromString(NSString *string) {
    NSError *error;
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}
id objectJsonFillterFromeString(NSString *string) {
    NSString *result = [NSString stringWithString:string];
    result = [result stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"null" withString:@"\"\""];
    result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",[NSNull null]] withString:@""];
    return objectFromString(result);
}

BOOL isHttpSuccessForData(id data) {
    NSInteger resultStatus = IntegerValueFrom([data objectForKey:@"code"]);
    BOOL result = NO;
    if(resultStatus == 200){
        result = YES;
    }
    return result;
}

NSString *JSONStringFromObject(id object) {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

NSString *stringValueWithData(NSData *data) {
    NSMutableString *buffer = [NSMutableString stringWithCapacity:([data length] * 2)];
    const unsigned char *dataBuffer = [data bytes];
    for (int i = 0; i < [data length]; ++i) {
        [buffer appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
    }
    
    return buffer;
}

NSData *MyJSONDataFromObject(id object) {
    NSError *error;
    NSData *result = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if (error) {
        return nil;
    }
    
    return result;
}

BOOL StringIsValid(NSString *string)
{
    if (!string) {
        return NO;
    }
    if (![string isKindOfClass:[NSString class]]) {
        return NO;
    }
    if ([string length] == 0) {
        return NO;
    }
    return YES;
}

NSString *StringWithObject(id object)
{
    if (!object) {
        return @"";
    }
    
    if (![object isKindOfClass:[NSString class]]) {
        return @"";
    }
    
    return object;
}

NSInteger IntegerValueFrom(id object)
{
    NSInteger value = 0;
    if ([object respondsToSelector:@selector(integerValue)]) {
        value = [object integerValue];
    }
    return value;
}

long long LonglongValueFrom(id object)
{
    long long value = 0;
    if ([object respondsToSelector:@selector(longLongValue)]) {
        value = [object longLongValue];
    }
    return value;
}

int IntValueFrom(id object)
{
    int value = 0;
    if ([object respondsToSelector:@selector(intValue)]) {
        value = [object intValue];
    }
    return value;
}

float FloatValueFrom(id object)
{
    float value = 0.f;
    if ([object respondsToSelector:@selector(floatValue)]) {
        value = [object floatValue];
    }
    return value;
}

double DoubleValueFrom(id object)
{
    double value = 0;
    if ([object respondsToSelector:@selector(doubleValue)]) {
        value = [object doubleValue];
    }
    return value;
}

BOOL BoolValueFrom(id object)
{
    BOOL value = NO;
    if ([object respondsToSelector:@selector(boolValue)]) {
        value = [object boolValue];
    }
    return value;
}

NSString *StringFromMD5WithString(NSString *string)
{
    if(!StringIsValid(string))
        return @"";
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

NSString *GetUniqueDeviceIdentifier() {
    NSString *uuid = LocalUniqueDeviceIdentifier();
    //NSLog(@"uuid1 = %@",uuid);
    if (!StringIsValid(uuid)) {
        uuid = LoadKeychain(chainKey);
        //NSLog(@"uuid2 = %@",uuid);
        if (!StringIsValid(uuid)) {
            uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            uuid = StringFromMD5WithString(uuid);
            //NSLog(@"uuid3 = %@",uuid);
            SaveKeychain(chainKey, uuid);
        }
        
        SaveLocalUniqueDeviceIdentifier(uuid);
    }
    return uuid;
}

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark 网络快捷方法

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark 好友
void CheckStaticFriends()
{
    /*
    NSInteger interval = (NSInteger)[[NSDate date] timeIntervalSince1970];
    User *user = GetUserWithUserid(YKUSERID);
    if (!user) {
        user = InsertNewObjectForEntityForName(@"User");
        user.userid = YKUSERID;
    }
    user.myid = Openid();
    user.liketype = LikeType_I_Like;
    user.lasttime = interval;
    
    interval++;
    
    user = GetUserWithUserid(GBUSERID);
    if (!user) {
        user = InsertNewObjectForEntityForName(@"User");
        user.userid = GBUSERID;
    }
    user.myid = Openid();
    user.liketype = LikeType_I_Like;
    user.lasttime = interval;
    
    interval++;
    
    user = GetUserWithUserid(BJUSERID);
    if (!user) {
        user = InsertNewObjectForEntityForName(@"User");
        user.userid = BJUSERID;
    }
    user.myid = Openid();
    user.liketype = LikeType_I_Like;
    user.lasttime = interval;
    
    SaveContext();
    */
}

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark 存储

#pragma mark 是否可以直接进入主界面
BOOL CanIn() {
    NSString *key = @"CanIn";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:key];
}

void SetCanIn(BOOL canin) {
    NSString *key = @"CanIn";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:canin forKey:key];
    [defaults synchronize];
}

NSString *LocalUniqueDeviceIdentifier()
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"LocalUniqueDeviceIdentifier"];
}

void SaveLocalUniqueDeviceIdentifier(NSString *uuid)
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:uuid forKey:@"LocalUniqueDeviceIdentifier"];
    [defaults synchronize];
}

#pragma mark openid
NSInteger Openid()
{
    if (_openid != 0) {
        return _openid;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _openid = [defaults integerForKey:@"OpenidOpenid"];
    
    return _openid;
}

void SaveOpenid(NSInteger openid)
{
    _openid = openid;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:openid forKey:@"OpenidOpenid"];
    [defaults synchronize];
}

#pragma mark token
NSString *Token()
{
    if (StringIsValid(_token)) {
        return _token;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _token = [defaults stringForKey:@"TokenToken"];
    if (!StringIsValid(_token)) {
        _token = @"";
    }
    return _token;
}

void SaveToken(NSString *token)
{
    _token = token;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"TokenToken"];
    [defaults synchronize];
}

#pragma mark 是否需要下载user资料
BOOL NeedLoadUser(NSString *userid)
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",@"NeedLoadUser",userid];
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

void SaveNeedLoadUser(NSString *userid, BOOL load)
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",@"NeedLoadUser",userid];
    [[NSUserDefaults standardUserDefaults] setBool:load forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark 是否需要设置用户昵称
BOOL NeedSetUserInfoNickname()
{
    NSString *key = [NSString stringWithFormat:@"%@_%ld",@"NeedSetUserInfoNickname",(long)Openid()];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:key];
}

void SaveNeedSetUserInfoNickname(BOOL need)
{
    NSString *key = [NSString stringWithFormat:@"%@_%ld",@"NeedSetUserInfoNickname",(long)Openid()];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:need forKey:key];
    [defaults synchronize];
}

#pragma mark 是否需要设置用户头像
BOOL NeedSetUserInfoStillImage()
{
    NSString *key = [NSString stringWithFormat:@"%@_%ld",@"NeedSetUserInfoStillImage",(long)Openid()];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:key];
}
void SaveNeedSetUserInfoStillImage(BOOL need)
{
    NSString *key = [NSString stringWithFormat:@"%@_%ld",@"NeedSetUserInfoStillImage",(long)Openid()];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:need forKey:key];
    [defaults synchronize];
}

#pragma mark 用户昵称
NSString *UserInfoNickname()
{
    NSString *key = [NSString stringWithFormat:@"%@_%ld",@"UserInfoNickname",(long)Openid()];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

void SaveUserInfoNickname(NSString *nickname)
{
    NSString *key = [NSString stringWithFormat:@"%@_%ld",@"UserInfoNickname",(long)Openid()];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nickname forKey:key];
    [defaults synchronize];
}

#pragma mark 默认的10条new数据
NSArray * _Nullable NewArr() {
    NSString *key = @"NewArr";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

void SaveNewArr(NSArray * _Nullable arr) {
    NSString *key = @"NewArr";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:arr forKey:key];
    [defaults synchronize];
}

#pragma mark 默认的10条hot数据
NSArray * _Nullable HotArr() {
    NSString *key = @"HotArr";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

void SaveHotArr(NSArray * _Nullable arr) {
    NSString *key = @"HotArr";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:arr forKey:key];
    [defaults synchronize];
}

#pragma mark 默认的10条大咖说数据
NSArray * _Nullable DakaArr() {
    NSString *key = @"DakaArr";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}
void SaveDakaArr(NSArray * _Nullable arr) {
    NSString *key = @"DakaArr";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:arr forKey:key];
    [defaults synchronize];
}

#pragma mark 默认的10条攻略数据
NSArray * _Nullable GonglueArr() {
    NSString *key = @"GonglueArr";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

void SaveGonglueArr(NSArray * _Nullable arr) {
    NSString *key = @"GonglueArr";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:arr forKey:key];
    [defaults synchronize];
}

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark 语言
NSString * _Nonnull mylocallang(NSString *key) {
    if (!StringIsValid(key)) {
        return @"";
    }
    
    return key;
    
    /*
    NSString *string = nil;
    
    if (!_curLanDic) {
        NSString *rpath = [[NSBundle mainBundle] pathForResource:@"lan" ofType:@"plist"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:rpath];
        _curLanDic = [dictionary valueForKey:CurrentLanguage()];
        if (!_curLanDic) {
            _curLanDic = [dictionary valueForKey:@"en"];
        }
    }
    
    string = [_curLanDic valueForKey:key];
    if (!StringIsValid(string)) {
        string = key;
    } else{
        string = [string stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        if ([_curLan isEqualToString:@"en"]) {
            NSString *astring = [string substringToIndex:1];
            NSString *bstring = [string substringFromIndex:1];
            astring = [astring uppercaseString];
            string = [astring stringByAppendingString:bstring];
        }
    }
    
    return string;
    */
}

NSString * _Nullable CurrentLanguage()
{
    if (StringIsValid(_curLan)) {
        return _curLan;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLang = languages.firstObject;
    if (!StringIsValid(currentLang)) {
        _curLan = @"en";
    }else {
        NSArray *_s = [currentLang componentsSeparatedByString:@"-"];
        _curLan = _s.firstObject;
    }
    //[[AFNetworkClient shareInstance] upLanguage:currentLang];
    
    return _curLan;
    //zh-Hans   简体中文
    //zh-Hant   繁体中文
    //zh-HK     繁体中文香港
    //en        英语
    //ja        日语
    //ko        韩语
    //fr        法语
    
    /*
     AppleLanguages =     @[@"zh-Hans",
     @"en",
     @"fr",
     @"de",
     @"ja",
     @"nl",
     @"it",
     @"es",
     @"pt",
     @"pt-PT",
     @"da",
     @"fi",
     @"nb",
     @"sv",
     @"ko",
     @"zh-Hant",
     @"ru",
     @"pl",
     @"tr",
     @"uk",
     @"ar",
     @"hr",
     @"cs",
     @"el",
     @"he",
     @"ro",
     @"sk",
     @"th",
     @"id",
     @"en-GB",
     @"ca",
     @"hu",
     @"vi"];
     */
}

NSString * _Nullable CurInputMode()
{
    NSString *mode = nil;
    NSArray *modes = [UITextInputMode activeInputModes];
    if (modes.count > 0) {
        mode = [modes[0] primaryLanguage];
    }
    return mode;
}

NSString * _Nullable getCurrentLanguageString() {
    NSString *languageString = mylocallang(@"英语");
    if ([@"zh" isEqualToString:CurrentLanguage()]) {
        languageString = mylocallang(@"简体中文");
    }else if ([@"en" isEqualToString:CurrentLanguage()]) {
        languageString = mylocallang(@"英语");
    }else if ([@"fr" isEqualToString:CurrentLanguage()]) {
        languageString = mylocallang(@"法语");
    }else if ([@"ja" isEqualToString:CurrentLanguage()]) {
        languageString = mylocallang(@"日语");
    }else if ([@"ko" isEqualToString:CurrentLanguage()]) {
        languageString = mylocallang(@"韩语");
    }
    
    
    return languageString;
}

#pragma mark core data 和 文件操作
void SaveContext() {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = ManagedObjectContext();
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //KDXClassLog(@"Unresolved error %@, %@", error, [error userInfo]);
#ifdef DEBUG
            abort();
#endif
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
NSManagedObjectContext * ManagedObjectContext() {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = PersistentStoreCoordinator();
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
NSManagedObjectModel * ManagedObjectModel() {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSDictionary *)sourceMetadata:(NSError **)error {
    return [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                      URL:SourceStoreURL()
                                                                    error:error];
}

- (BOOL)isMigrationNeeded {
    NSError *error = nil;
    
    // Check if we need to migrate
    NSDictionary *sourceMetadata = [self sourceMetadata:&error];
    BOOL isMigrationNeeded = NO;
    
    if (sourceMetadata != nil) {
        NSManagedObjectModel *destinationModel = ManagedObjectModel();
        // Migration is needed if destinationModel is NOT compatible
        isMigrationNeeded = ![destinationModel isConfiguration:nil
                                   compatibleWithStoreMetadata:sourceMetadata];
    }
    KDXClassLog(@"isMigrationNeeded: %d", isMigrationNeeded);
    return isMigrationNeeded;
}

NSURL *SourceStoreURL() {
    return [ApplicationDocumentsDirectory() URLByAppendingPathComponent:@"DataModel.sqlite"];
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
NSPersistentStoreCoordinator *PersistentStoreCoordinator() {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = SourceStoreURL();
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:ManagedObjectModel()];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        //NSLog(@"Unresolved error %@", [error userInfo]);
        //abort();
        NSFileManager *fileManager = [NSFileManager new];
        [fileManager removeItemAtPath:SourceStoreURL().path error:nil];
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
NSURL *ApplicationDocumentsDirectory() {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

id InsertNewObjectForEntityForName(NSString *entityName) {
    NSManagedObjectContext *context = ManagedObjectContext();
    id entity = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                              inManagedObjectContext:context];
    return entity;
}

id GetEntityWithString(NSString *string, NSString *entityName) {
    NSManagedObjectContext *context = ManagedObjectContext();
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //fetchRequest.fetchLimit = 1;
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName
                                        inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:string]];
    NSArray *resultArray = [context executeFetchRequest:fetchRequest
                                                  error:&error];
    if (error) {
        return nil;
    }
    
    return resultArray.lastObject;
}

void DeleteObject(id _Nullable object) {
    if (object) {
        NSManagedObjectContext *context = ManagedObjectContext();
        [context deleteObject:object];
        SaveContext();
    }
}

void DeleteObjects(NSArray * _Nullable objects) {
    BOOL save = NO;
    for (id object in objects) {
        if (object) {
            NSManagedObjectContext *context = ManagedObjectContext();
            [context deleteObject:object];
            save = YES;
        }
    }
    if (save) {
        SaveContext();
    }
}

NSUInteger GetEntityCountWithString(NSString * _Nullable string, NSString * _Nullable entityName) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    NSManagedObjectContext *context = ManagedObjectContext();
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //fetchRequest.fetchLimit = 1;
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName
                                        inManagedObjectContext:context]];
    
    [fetchRequest setPredicate:predicate];
    
    NSUInteger count = [context countForFetchRequest:fetchRequest
                                               error:&error];
    if (error) {
        return 0;
    }
    
    return count;
}

NSArray * _Nullable GetEntityArrayWithString(NSString * _Nullable string, NSString * _Nullable entityName, NSArray * _Nullable sorts) {
    NSManagedObjectContext *context = ManagedObjectContext();
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //fetchRequest.fetchLimit = 1;
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName
                                        inManagedObjectContext:context]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    [fetchRequest setPredicate:predicate];
    if (sorts) {
        fetchRequest.sortDescriptors = sorts;
    }
    
    NSArray *resultArray = [context executeFetchRequest:fetchRequest
                                                  error:&error];
    if (error) {
        return nil;
    }
    
    return resultArray;
}

void DeleteObjectsWithString(NSString * _Nullable string, NSString * _Nullable entityName) {
    NSArray *array = GetEntityArrayWithString(string, entityName, nil);
    for (id object in array) {
        DeleteObject(object);
    }
}

@end

@implementation NSObject (Swift)

- (id)swift_performSelector:(SEL)selector withObject:(id)object
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [self performSelector:selector withObject:object];
#pragma clang diagnostic pop
}

- (void)swift_performSelector:(SEL)selector withObject:(id)object afterDelay:(NSTimeInterval)delay
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [self performSelector:selector withObject:object afterDelay:delay];
#pragma clang diagnostic pop
}

@end

#pragma mark
#pragma mark UINavigationController-YRBackGesture--------------------------------------------------------------------------------
#import <objc/runtime.h>

static const char *assoKeyPanGesture="__yrakpanges";
static const char *assoKeyStartPanPoint="__yrakstartp";
static const char *assoKeyEnableGesture="__yrakenabg";

@implementation UINavigationController (YRBackGesture)
-(BOOL)enableBackGesture{
    NSNumber *enableGestureNum = objc_getAssociatedObject(self, assoKeyEnableGesture);
    if (enableGestureNum) {
        return [enableGestureNum boolValue];
    }
    return false;
}
-(void)setEnableBackGesture:(BOOL)enableBackGesture{
    NSNumber *enableGestureNum = [NSNumber numberWithBool:enableBackGesture];
    objc_setAssociatedObject(self, assoKeyEnableGesture, enableGestureNum, OBJC_ASSOCIATION_RETAIN);
    if (enableBackGesture) {
        [self.view addGestureRecognizer:[self panGestureRecognizer]];
    }else{
        [self.view removeGestureRecognizer:[self panGestureRecognizer]];
    }
}
-(UIPanGestureRecognizer *)panGestureRecognizer{
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, assoKeyPanGesture);
    if (!panGestureRecognizer) {
        panGestureRecognizer=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panToBack:)];
        [panGestureRecognizer setDelegate:self];
        objc_setAssociatedObject(self, assoKeyPanGesture, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN);
    }
    return panGestureRecognizer;
}
-(void)setStartPanPoint:(CGPoint)point{
    NSValue *startPanPointValue = [NSValue valueWithCGPoint:point];
    objc_setAssociatedObject(self, assoKeyStartPanPoint, startPanPointValue, OBJC_ASSOCIATION_RETAIN);
}
-(CGPoint)startPanPoint{
    NSValue *startPanPointValue = objc_getAssociatedObject(self, assoKeyStartPanPoint);
    if (!startPanPointValue) {
        return CGPointZero;
    }
    return [startPanPointValue CGPointValue];
}

-(void)panToBack:(UIPanGestureRecognizer*)pan{
    UIView *currentView=self.topViewController.view;
    if (self.panGestureRecognizer.state==UIGestureRecognizerStateBegan) {
        [self setStartPanPoint:currentView.frame.origin];
        CGPoint velocity=[pan velocityInView:self.view];
        if(velocity.x!=0){
            [self willShowPreViewController];
        }
        return;
    }
    CGPoint currentPostion = [pan translationInView:self.view];
    CGFloat xoffset = [self startPanPoint].x + currentPostion.x;
    CGFloat yoffset = [self startPanPoint].y + currentPostion.y;
    if (xoffset>0) {//向右滑
        /*
         if (true) {
         xoffset = xoffset>self.view.frame.size.width?self.view.frame.size.width:xoffset;
         }else{
         xoffset = 0;
         }
         */
    }else if(xoffset<0){//向左滑
        if (currentView.frame.origin.x>0) {
            xoffset = xoffset<-self.view.frame.size.width?-self.view.frame.size.width:xoffset;
        }else{
            xoffset = 0;
        }
    }
    if (!CGPointEqualToPoint(CGPointMake(xoffset, yoffset), currentView.frame.origin)) {
        [self layoutCurrentViewWithOffset:UIOffsetMake(xoffset, yoffset)];
    }
    if (self.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (currentView.frame.origin.x==0) {
        }else{
            if (currentView.frame.origin.x < BackGestureOffsetXToBack){
                //            if (CGRectContainsPoint(self.view.bounds, currentView.center)) {
                [self hidePreViewController];
            }else{
                [self showPreViewController];
            }
        }
    }
}

-(void)willShowPreViewController{
    NSInteger count=self.viewControllers.count;
    if (count>1) {
        UIViewController *currentVC = [self topViewController];
        UIViewController *preVC = [self.viewControllers objectAtIndex:count-2];
        [currentVC.view.superview insertSubview:preVC.view belowSubview:currentVC.view];
    }
}
-(void)showPreViewController{
    NSInteger count = self.viewControllers.count;
    if (count>1) {
        UIView *currentView = self.topViewController.view;
        NSTimeInterval animatedTime = 0;
        animatedTime = ABS(self.view.frame.size.width - currentView.frame.origin.x) / self.view.frame.size.width * 0.35;
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:animatedTime animations:^{
            [self layoutCurrentViewWithOffset:UIOffsetMake(self.view.frame.size.width, 0)];
        } completion:^(BOOL finished) {
            [self popViewControllerAnimated:false];
        }];
    }
}
-(void)hidePreViewController{
    NSInteger count = self.viewControllers.count;
    if (count>1) {
        UIViewController *preVC = [self.viewControllers objectAtIndex:count-2];
        UIView *currentView = self.topViewController.view;
        NSTimeInterval animatedTime = 0;
        animatedTime = ABS(self.view.frame.size.width - currentView.frame.origin.x) / self.view.frame.size.width * 0.35;
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:animatedTime animations:^{
            [self layoutCurrentViewWithOffset:UIOffsetMake(0, 0)];
        } completion:^(BOOL finished) {
            [preVC.view removeFromSuperview];
        }];
    }
}

-(void)layoutCurrentViewWithOffset:(UIOffset)offset{
    NSInteger count = self.viewControllers.count;
    if (count>1) {
        UIViewController *currentVC = [self topViewController];
        UIViewController *preVC = [self.viewControllers objectAtIndex:count-2];
        [currentVC.view setFrame:CGRectMake(offset.horizontal, self.view.bounds.origin.y, self.view.frame.size.width, currentVC.view.frame.size.height)];
        [preVC.view setFrame:CGRectMake(offset.horizontal/2-self.view.frame.size.width/2, self.view.bounds.origin.y, self.view.frame.size.width, preVC.view.frame.size.height)];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [panGesture translationInView:self.view];
        if ([panGesture velocityInView:self.view].x < 600 && ABS(translation.x)/ABS(translation.y)>1) {
            return true;
        }
        return false;
    }
    return true;
}

@end

#pragma mark
#pragma mark DXLog
static NSDateFormatter *DateFormatter;
void DXLog(NSString *module, NSString *format, ...)
{
    if (!DateFormatter) {
        DateFormatter = [[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"HHmmss"];
        //[DateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    }
    
    va_list ap;
    va_start(ap, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    NSString *log;
    NSString *dateStr = [DateFormatter stringFromDate:[NSDate date]];
    if ([NSThread isMainThread]) {
        log = [[NSString alloc] initWithFormat:@"%@  [%@] %@\n", dateStr, module, message];
    } else {
        log = [[NSString alloc] initWithFormat:@"%@ *[%@] %@\n", dateStr, module, message];
    }
    
    fputs(log.UTF8String, stderr);
}