//
//  Tools.h
//  SwifTest
//
//  Created by jyg on 16/2/27.
//  Copyright © 2016年 jyg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IOS_VERSION_9_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)? (YES):(NO))

#define ISONIPAD        [[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound
#define ISONIPHONE4     CGSizeEqualToSize(CGSizeMake(640,960),[[UIScreen mainScreen]currentMode].size)
#define ISONIPHONE6     CGSizeEqualToSize(CGSizeMake(750,1334),[[UIScreen mainScreen]currentMode].size)
#define ISONIPHONE6P    (CGSizeEqualToSize(CGSizeMake(1242,2208),[[UIScreen mainScreen]currentMode].size) \
                        || \
                        CGSizeEqualToSize(CGSizeMake(1125,2001),[[UIScreen mainScreen]currentMode].size))

//#define SCREENWIDTH     (ISONIPAD?(600.f):([[UIScreen mainScreen] bounds].size.width))
#define SCREENWIDTH     ([[UIScreen mainScreen] bounds].size.width)
#define SCREENHEIGHT    ([[UIScreen mainScreen] bounds].size.height)

#define IDEAPHOTOSIZE       80  //idea图片大小
#define IDEAPHOTOMARGIN     8   //idea
#define FIRSTTOPVIEWHEIGHT  44  //
#define LOADINGMARGIN       44  //
#define CELLALPHADURATION   0.3 //每个cell的透明动画时间
#define FRESHOVERDURATION   0.4 //加载完成后回复时间
#define CELLLABELSIZE       12  //评论数等字体大小

@interface Tools : NSObject

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
NSString * _Nonnull StringWithObject(id _Nullable object);
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

@end

@interface NSObject (Swift)

- (id _Nullable)swift_performSelector:(SEL _Nullable)selector withObject:(id _Nullable)object;
- (void)swift_performSelector:(SEL _Nullable)selector withObject:(id _Nullable)object afterDelay:(NSTimeInterval)delay;

@end

#pragma mark
#pragma mark UINavigationController-YRBackGesture--------------------------------------------------------------------------------

#define BackGestureOffsetXToBack 80//>80 show pre vc
@interface UINavigationController (YRBackGesture)<UIGestureRecognizerDelegate>
/*!
 *	@brief	Default is NO;
 *  @note need call this after ViewDidLoad otherwise not work;
 */
@property (assign,nonatomic) BOOL enableBackGesture;

@end

#pragma mark
#pragma mark DXLog--------------------------------------------------------------------------------
#ifdef DEBUG
#   define KDXLog(...) DXLog(__VA_ARGS__)
#   define KDXClassLog(...) DXLog(NSStringFromClass([self class]), __VA_ARGS__)
#else
#   define KDXLog(...) do{}while(0)
#   define KDXClassLog(...) do{}while(0)
#endif

#pragma mark
#pragma mark DXLog
void DXLog(NSString * _Nullable module, NSString * _Nullable format, ...);
