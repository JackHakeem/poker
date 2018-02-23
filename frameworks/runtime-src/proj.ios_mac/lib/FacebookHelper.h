//
//  FacebookHelper.h
//  poker
//
//  Created by 罗昊 on 2017/6/7.
//
//

#ifndef FacebookHelper_h
#define FacebookHelper_h

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface FacebookHelper:NSObject <FBSDKSharingDelegate,FBSDKGameRequestDialogDelegate>{
}
    
    
+(void) loginFacebook;
+(id)sharedHelper;
+(void)shareLink:(NSDictionary *) params;
+(void)shareOpenGraph:(NSDictionary *) params;
+(NSString *)getAllRequestsForReward;
+(NSString *)getInvitableFriends;
+(NSString *)invitabelFriends:(NSDictionary *) params;
    
-(void) loginFacebook;
-(void)setViewController:(UIViewController *)ctl;
-(UIViewController *)getViewController;
@end
#endif /* FacebookHelper_h */
