//
//  BridgingHeader.h
//  SwifTest
//
//  Created by jyg on 16/2/27.
//  Copyright © 2016年 jyg. All rights reserved.
//

#ifndef BridgingHeader_h
#define BridgingHeader_h

#import "Tools.h"

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark 快捷方法
void AfterDispatch(double delayInSeconds, dispatch_block_t _Nullable block);
void MainDispatch(dispatch_block_t _Nullable block);
void GlobalDispatch(dispatch_block_t _Nullable block);
CGFloat SW();
CGFloat SH();
CGRect SF();

CGFloat S1080(CGFloat p);
UIColor * _Nonnull RGBA(NSInteger rgbValue, CGFloat alpha);
UIColor * _Nonnull MainBackColor();
UIColor * _Nonnull CellSelectColor();
UIColor * _Nonnull CellBackColor();
UIColor * _Nonnull CellLabelColor();

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark JSONData
id _Nullable objectFromJSONData(NSData * _Nullable data);
id _Nullable objectFromString(NSString * _Nullable string);
id _Nullable objectJsonFillterFromeString(NSString * _Nullable string);
BOOL isHttpSuccessForData(id _Nullable data);
NSString * _Nullable JSONStringFromObject(id _Nullable object);
NSString * _Nullable stringValueWithData(NSData * _Nullable data);
NSData * _Nullable MyJSONDataFromObject(id _Nullable object);

BOOL StringIsValid(NSString * _Nullable string);
NSString *  _Nonnull StringWithObject(id _Nullable object);
NSInteger IntegerValueFrom(id _Nullable object);
long long LonglongValueFrom(id _Nullable object);
int IntValueFrom(id _Nullable object);
float FloatValueFrom(id _Nullable object);
double DoubleValueFrom(id _Nullable object);
BOOL BoolValueFrom(id _Nullable object);

NSString * _Nullable GetUniqueDeviceIdentifier();

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark 网络快捷方法

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark 好友
void CheckStaticFriends();

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark 存储

#pragma mark 是否可以直接进入主界面
BOOL CanIn();
void SetCanIn(BOOL canin);

#pragma mark openid
NSInteger Openid();
void SaveOpenid(NSInteger openid);

#pragma mark token
NSString * _Nullable Token();
void SaveToken(NSString * _Nullable token);

#pragma mark 是否需要下载user资料
BOOL NeedLoadUser(NSString * _Nullable userid);
void SaveNeedLoadUser(NSString * _Nullable userid, BOOL load);

#pragma mark 是否需要设置用户昵称
BOOL NeedSetUserInfoNickname();
void SaveNeedSetUserInfoNickname(BOOL need);

#pragma mark 是否需要设置用户头像
BOOL NeedSetUserInfoStillImage();
void SaveNeedSetUserInfoStillImage(BOOL need);

#pragma mark 用户昵称
NSString * _Nullable UserInfoNickname();
void SaveUserInfoNickname(NSString * _Nullable nickname);

#pragma mark 默认的10条new数据
NSArray * _Nullable NewArr();
void SaveNewArr(NSArray * _Nullable arr);

#pragma mark 默认的10条hot数据
NSArray * _Nullable HotArr();
void SaveHotArr(NSArray * _Nullable arr);

#pragma mark 默认的10条大咖说数据
NSArray * _Nullable DakaArr();
void SaveDakaArr(NSArray * _Nullable arr);

#pragma mark 默认的10条攻略数据
NSArray * _Nullable GonglueArr();
void SaveGonglueArr(NSArray * _Nullable arr);

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark 语言
NSString * _Nonnull mylocallang(NSString * _Nullable key);
NSString * _Nullable currentLanguage();
NSString * _Nullable CurInputMode();
NSString * _Nullable getCurrentLanguageString();

#pragma mark----------------------------------------------------------------------------------------------------
#pragma mark core data 和 文件操作
void SaveContext();

id _Nullable InsertNewObjectForEntityForName(NSString * _Nullable entityName);
id _Nullable GetEntityWithString(NSString * _Nullable string, NSString * _Nullable entityName);

void DeleteObject(id _Nullable object);
void DeleteObjects(NSArray * _Nullable objects);
NSUInteger GetEntityCountWithString(NSString * _Nullable string, NSString * _Nullable entityName);
NSArray * _Nullable  GetEntityArrayWithString(NSString * _Nullable string, NSString * _Nullable entityName, NSArray * _Nullable sorts);
void DeleteObjectsWithString(NSString * _Nullable string, NSString * _Nullable entityName);

#endif /* BridgingHeader_h */
