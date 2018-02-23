//
//  LuaEventProxy.h
//  poker
//
//  Created by 罗昊 on 2017/6/7.
//
//

#ifndef LuaEventProxy_h
#define LuaEventProxy_h

@interface LuaEventProxy:NSObject{
}
@property(nonatomic,retain)UIViewController * viewController;
@property(nonatomic,copy) NSString *token;
    +(id)sharedProxy;
    +(void)setLuaCallBackFunc:(NSDictionary *) params;
+(int)getBatterypercentage;
+(int)getSignalStrength;
+ (void)onProfileSignIn:(NSDictionary *) params;
+(void)onProfileSignOff;
+(void)onEvent:(NSDictionary *) params;
+(void)onEventValue:(NSDictionary *) params;
+(void)reportError:(NSDictionary *) params;
+(void)vibrate;
+(int)copyToClipboard:(NSDictionary *) params;
+(void)displayWebView:(NSDictionary *) params;
+(void)dismissWebView;
+(void)webViewLoadUrl:(NSDictionary *) params;
+(int)isWebViewVisible;
+(NSString *)getPushToken;
+(int)isNotificationEnabled;
+(void)gotoSet;
+(void)gotoEvaluate;
+(NSString *)getVersionCode;
+(int)addLocalNotication:(NSDictionary *) params;
+(void)delLoaclNotication:(NSDictionary *) params;
+(void)sysShareString:(NSDictionary *) params;
-(void)dispatchEvent:(NSString *)event_cmd params:(NSString *)params;
-(void)setToken:(NSString *) token;
    // Constants
@end
#endif /* FacebookHelper_h */
