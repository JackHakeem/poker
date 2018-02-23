//
//  LuaEventProxy.m
//  poker
//
//  Created by 罗昊 on 2017/6/7.
//
//

#import <Foundation/Foundation.h>
#import "LuaEventProxy.h"

#import "cocos2d.h"
#import "CCLuaEngine.h"
#import "CCLuaBridge.h"
#import "UMMobClick/MobClick.h"
#import <AudioToolbox/AudioToolbox.h>
#import "VoiceRecord.h"
#import "BLWebView.h"
#import <UserNotifications/UserNotifications.h>
using namespace cocos2d;

extern NSString *const appid = @"1238602984";
extern NSString *const loginFacebook = @"loginFacebook";
extern NSString *const loginYouke = @"loginYouke";
extern NSString *const payCallback = @"payCallback";
extern NSString *const voiceRecord = @"voiceRecord";
extern NSString *const voiceRecordDecibels = @"voiceRecordDecibels";
extern NSString *const registerPushTokenChange = @"registerPushTokenChange";
extern NSString *const pushMsg = @"pushMsg";
extern NSString *const shareCallback = @"shareCallback";
extern NSString *const FBGetInvitableFriendsCallback = @"FBGetInvitableFriendsCallback";
extern NSString *const FBGetAllRequestsForReward = @"FBGetAllRequestsForReward";

@implementation LuaEventProxy{
    int callbackHandlerID;
}

    static LuaEventProxy* instance = nil;
    +(id)sharedProxy{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            instance = [[self alloc] init];
            
        });
        
        return instance;
    }

    +(void)setLuaCallBackFunc:(NSDictionary *) params{
        [[LuaEventProxy sharedProxy]setLuaCallBackFunc:params];
    }

-(void)setLuaCallBackFunc:(NSDictionary *) params{
        if (callbackHandlerID != 0){
            LuaBridge::releaseLuaFunctionById(callbackHandlerID); //记得释放
        }
        callbackHandlerID = (int)[[params objectForKey:@"callback"] integerValue];
        
    }

    -(id)init{
        if(self=[super init]) {
        }
        return self;
    }

-(void)setToken:(NSString *) dToken{
    _token = [dToken copy];
    NSLog(@"%@",_token);
}

-(NSString *)getToken {
    if (_token!=NULL)
        return _token;
    else
        return @"";
}

+(int)getBatterypercentage{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    double deviceLevel = [UIDevice currentDevice].batteryLevel;
    return deviceLevel*100;
}
+(int)getSignalStrength{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSString *dataNetworkItemView = nil;
    NSString *wifiNetworkItemView = nil;
    for(id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarSignalStrengthItemView") class]]){
            dataNetworkItemView = subview;
            break;
        }
//        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]){
//            wifiNetworkItemView = subview;
//            //break;
//        }
    }
    
    int signalStrength = [[dataNetworkItemView valueForKey:@"_signalStrengthBars"] intValue];
    return signalStrength;
}
    // 先要初始化callevent
    -(void)dispatchEvent:(NSString *)event_cmd params:(NSString *)params{
        NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
        [dict setValue:event_cmd forKey:@"cmd"];
        [dict setValue:params forKey:@"params"];
        //判断是否能转为Json数据
        BOOL isValidJSONObject =  [NSJSONSerialization isValidJSONObject:dict];
        if (isValidJSONObject) {
            /*
             第一个参数:OC对象 也就是我们dict
             第二个参数:
             NSJSONWritingPrettyPrinted 排版
             kNilOptions 什么也不做
             */
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            //打印JSON数据
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",ret);
            LuaBridge::pushLuaFunctionById(callbackHandlerID); //压入需要调用的方法id（假设方法为XG）
            LuaStack *stack = LuaBridge::getStack();  //获取lua栈
            stack->pushString([ret cStringUsingEncoding: NSUTF8StringEncoding]);  //将需要通过方法XG传递给lua的参数压入lua栈
            stack->executeFunction(1);  //根据压入的方法id调用方法XG，并把XG方法参数传递给lua代码
//            LuaBridge::releaseLuaFunctionById(callbackHandlerID); //最后记得释放
        }
    }


+ (void)onProfileSignIn:(NSDictionary *) params{
    NSString *puid = [params objectForKey:@"puid"];
    NSString *provider = [params objectForKey:@"provider"];
    if ([puid compare:@""] == 0) {
        return;
    }
    if ([provider compare:@""] == 0) {
        [MobClick profileSignInWithPUID:puid];
    }else{
        [MobClick profileSignInWithPUID:puid provider:provider];
    }
}

+(void)onProfileSignOff{
    [MobClick profileSignOff];
}

+(void)onEvent:(NSDictionary *) params{
    NSString *eventId = [params objectForKey:@"eventId"];
    NSString *jsonStr = [params objectForKey:@"jsonStr"];
    if ([eventId compare:@""] == 0) {
        return;
    }
    
    if ([jsonStr compare:@"null"] == 0) {
        [MobClick event:eventId];
        return;
    }
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *attributes = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        [MobClick event:eventId];
        return;
    }
    [MobClick event:eventId attributes:attributes];
}
+(void)onEventValue:(NSDictionary *) params{
    NSString *eventId = [params objectForKey:@"eventId"];
    NSString *jsonStr = [params objectForKey:@"jsonStr"];
    int counter = (int)[[params objectForKey:@"value"] integerValue];
    if ([eventId compare:@""] == 0) {
        return;
    }
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *attributes = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        attributes = [[[NSDictionary alloc] init] autorelease];
    }
    [MobClick event:eventId attributes:attributes counter:counter];
}
+(void)reportError:(NSDictionary *) params{
//    NSString *error = [params objectForKey:@"error"];
//    if ([error compare:@""] == 0) {
//        return;
//    }
//    [MobClick repor
}
+(void)vibrate{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+(void)startRecord:(NSDictionary *) params{
    NSString *path = [params objectForKey:@"path"];
    NSString *what = [params objectForKey:@"what"];
    [[VoiceRecord sharedInstance] startRecord:path what:what ];
}
+(void)stopRecord:(NSDictionary *) params{
//    NSString *startRecord = [params objectForKey:@"eventId"];
//    NSString *what = [params objectForKey:@"jsonStr"];
    [[VoiceRecord sharedInstance] stopRecord];
}

+(int)copyToClipboard:(NSDictionary *) params{
    NSString *text = [params objectForKey:@"text"];
    UIPasteboard*pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string=text;
    return 0;
}
+(void)displayWebView:(NSDictionary *) params{
    CGFloat x = [[params objectForKey:@"x"] floatValue];
    CGFloat y = [[params objectForKey:@"y"] floatValue];
    CGFloat width = [[params objectForKey:@"width"] floatValue];
    CGFloat height = [[params objectForKey:@"height"] floatValue];
    Boolean showClose = [[params objectForKey:@"showClose"] boolValue];
    [[BLWebView sharedInstance] displayWebView:x y:y width:width height:height showClose:showClose];
}

+(void)dismissWebView{
    [[BLWebView sharedInstance] dismissWebView];
}
+(void)webViewLoadUrl:(NSDictionary *) params{
    NSString *url = [params objectForKey:@"url"];
    [[BLWebView sharedInstance] webViewLoadUrl:url];
}
+(int)isWebViewVisible{
    return [[BLWebView sharedInstance] isWebViewVisible];
}

+(NSString *)getPushToken{
    return [[LuaEventProxy sharedProxy] getToken];
}

+(int)isNotificationEnabled{
    BOOL isOpen = NO;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    isOpen = setting.types != UIUserNotificationTypeNone;
#else
    UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    isOpen = type != UIRemoteNotificationTypeNone;
#endif
    return isOpen ? 1 : 0;
}

+(void)gotoSet{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        NSURL *url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

+(void)gotoEvaluate{
    NSString * url = [[@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=" stringByAppendingString:appid] stringByAppendingString:@"&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+(NSString *)getVersionCode{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+(int)addLocalNotication:(NSDictionary *) params{
    NSString *title = [params objectForKey:@"title"];
    NSString *content = [params objectForKey:@"content"];
    int time = [[params objectForKey:@"time"] intValue];
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    int ret = [[NSNumber numberWithDouble:nowtime] longLongValue] % 100000000;
    [params setValue:[NSString stringWithFormat:@"%d",ret]  forKey:@"id"];
    
    UILocalNotification *localNotifi = [UILocalNotification new];
    [localNotifi setFireDate:[NSDate dateWithTimeIntervalSinceNow:time]];
    [localNotifi setAlertTitle:title];
    [localNotifi setAlertBody:content];
    [localNotifi setUserInfo:params];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotifi];
    return ret;
}

+(void)delLoaclNotication:(NSDictionary *) params{
    int rmoveId = [[params objectForKey:@"id"] intValue];
    NSArray *notifiArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *local in notifiArray) {
        //将来可以根据UserInfo的值，来查看这个是否是你想要删除的通知
        if ([[local.userInfo objectForKey:@"id"] intValue] == rmoveId) {
            //删除单个通知
            [[UIApplication sharedApplication]cancelLocalNotification:local];
        }
    }
}

+(void)sysShareString:(NSDictionary *) params{
    NSString *url = [params objectForKey:@"url"];
    NSURL *urlToShare = [NSURL URLWithString:url];
    NSString *textToShare = [params objectForKey:@"msg"];
//    NSString *bmpPath = [params objectForKey:@"bmpPath"];
//    UIImage *imageToShare = [UIImage imageNamed:bmpPath];
//    NSData *data = UIImageJPEGRepresentation(imageToShare, 1);
//    UIImage *imageToShareJpg = [UIImage imageWithData:data];
    NSArray *activityItems = @[textToShare,urlToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [[[self sharedProxy] viewController] presentViewController:activityVC animated:YES completion:nil];
}
@end
