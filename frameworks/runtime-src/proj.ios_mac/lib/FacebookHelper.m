//
//  FacebookHelper.m
//  poker
//
//  Created by 罗昊 on 2017/6/7.
//
//

#import <Foundation/Foundation.h>
#import "FacebookHelper.h"
#import "LuaEventProxy.h"
#import "Function.h"
extern NSString *loginFacebook;
extern NSString *shareCallback;
extern NSString *FBGetInvitableFriendsCallback;
extern NSString *FBGetAllRequestsForReward;
@implementation FacebookHelper{
    FBSDKLoginManager *loginManager;
    UIViewController *viewController;
}

static FacebookHelper* instance = nil;
    
+(id)sharedHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
        
    });
    
    return instance;
}

+(void)loginFacebook{
    [[FacebookHelper sharedHelper] loginFacebook];
}

-(void)setViewController:(UIViewController *)ctl {
    viewController = ctl;
}
-(UIViewController *)getViewController{
    return viewController;
}
    
-(id)init{
    if(self=[super init]) {
        loginManager = [[FBSDKLoginManager alloc] init];
    }
    return self;
}

-(void)loginFacebook{
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"logOut");
        [loginManager logOut];
    }
    
    [loginManager logInWithReadPermissions:@[@"public_profile",@"user_friends"] fromViewController:viewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"Process error");
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:@(3) forKey:@"ret"];
            [dict setValue:[error localizedDescription] forKey:@"error"];
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [[LuaEventProxy sharedProxy]dispatchEvent:loginFacebook params:ret];
        } else if (result.isCancelled) {
            NSLog(@"Cancelled");
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
            [dict setValue:@(2) forKey:@"ret"];
            NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            [[LuaEventProxy sharedProxy]dispatchEvent:loginFacebook params:ret];
        } else {
            NSLog(@"Logged in");
            NSString *tokenString = [[result token] tokenString];
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id,name,gender"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if(!error) {
                    NSLog(@"fetched user:%@ cmd:%@",result,loginFacebook);
                    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
                    [dict setValue:[result objectForKey:@"name"] forKey:@"name"];
                    [dict setValue:[result objectForKey:@"id"] forKey:@"id"];
                    [dict setValue:[result objectForKey:@"gender"] forKey:@"gender"];
                    [dict setValue:tokenString forKey:@"fb_token"];
                    [dict setValue:@(1) forKey:@"ret"];
                    dict = [Function getLoginCommentData:dict];
                    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
                    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    [[LuaEventProxy sharedProxy]dispatchEvent:loginFacebook params:ret];
                }else{
                    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
                    [dict setValue:@(3) forKey:@"ret"];
                    [dict setValue:[error localizedDescription] forKey:@"error"];
                    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
                    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    [[LuaEventProxy sharedProxy]dispatchEvent:loginFacebook params:ret];
                }
            }];
        }
    }];
}


+(void)shareLink:(NSDictionary *) params{
    NSString *url = [params objectForKey:@"url"];
    NSString *msg = [params objectForKey:@"msg"];
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    if(![msg isEqualToString:@""]) {
        content.quote = msg;
    }
    content.contentURL = [NSURL URLWithString:url];
    [FBSDKShareDialog showFromViewController:[[FacebookHelper sharedHelper] getViewController]
                                 withContent:content
                                    delegate:[FacebookHelper sharedHelper]];
}

+(void)shareOpenGraph:(NSDictionary *) params{
    NSString *url = [params objectForKey:@"url"];
    NSString *title = [params objectForKey:@"title"];
    NSString *bmpPath = [params objectForKey:@"bmpPath"];
//    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
//    [photo setImage:[UIImage imageNamed:bmpPath]];
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:url];
    
    //    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    //    content.photos = @[photo];
    
    //    NSString *bmpPath = [params objectForKey:@"bmpPath"];
    //    UIImage *imageToShare = [UIImage imageNamed:bmpPath];
    //    NSData *data = UIImageJPEGRepresentation(imageToShare, 1);
    //    UIImage *imageToShareJpg = [UIImage imageWithData:data];
    
//    UIImage *originImage = [UIImage imageNamed:bmpPath];
//    NSData *data = UIImageJPEGRepresentation(originImage, 1);
//    UIImage *imageToShareJpg = [UIImage imageWithData:data];
//    NSDictionary *properties = @{
//         @"fb:app_id": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"FacebookAppID"],
//         @"og:type": @"game.achievement",
//         @"og:url": url,
//         @"og:title": title,
//         @"game:points": @"test",
//     };
//    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
//    [photo setImage:imageToShareJpg];
//    [FBSDKSettings enableLoggingBehavior:FBSDKLoggingBehaviorNetworkRequests];
//    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
////    [object setPhoto:photo forKey:@"og:image"];
////    [object setArray:@[photo] forKey:@"og:image"];
//    FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
//    action.actionType = @"games.celebrate";
//    [action setObject:object forKey:@"victory"];
//    [action setArray:@[photo] forKey:@"image"];
//    FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
//    content.action = action;
//    content.previewPropertyName = @"victory";
    [FBSDKShareDialog showFromViewController:[[FacebookHelper sharedHelper] getViewController]
                                 withContent:content
                                    delegate:[FacebookHelper sharedHelper]];
}

+(NSString *)invitabelFriends:(NSDictionary *) params{
    NSString *to = [params objectForKey:@"to"];
    NSString *mid = [params objectForKey:@"mid"];
    NSString *msg = [params objectForKey:@"msg"];
    FBSDKGameRequestContent *gameRequestContent = [[FBSDKGameRequestContent alloc] init];
    // Look at FBSDKGameRequestContent for futher optional properties
    gameRequestContent.message = msg;
//    gameRequestContent.title = @"OPTIONAL TITLE";
    [gameRequestContent setData:mid];
    gameRequestContent.recipients = [to componentsSeparatedByString:@","];

    // Assuming self implements <FBSDKGameRequestDialogDelegate>
    [FBSDKGameRequestDialog showWithContent:gameRequestContent delegate:[FacebookHelper sharedHelper]];
    return @"success";
}

+(NSString *)getInvitableFriends{
    if ([FBSDKAccessToken currentAccessToken]) {
        NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
        [dict setValue:@"id,name,picture.width(80).width(80)" forKey:@"fields"];
        [dict setValue:@"100" forKey:@"limit"];
        
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                      initWithGraphPath:@"/me/invitable_friends"
                                      parameters:dict
                                      HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            // Handle the result
            if (error) {
                NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
                [dict setValue:[error localizedDescription] forKey:@"error"];
                [dict setValue:@(3) forKey:@"ret"];
                NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
                NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                [[LuaEventProxy sharedProxy]dispatchEvent:FBGetInvitableFriendsCallback params:ret];
            }else{
                NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
                [dict setValue:[result objectForKey:@"data"] forKey:@"data"];
                [dict setValue:@(1) forKey:@"ret"];
                NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
                NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                [[LuaEventProxy sharedProxy]dispatchEvent:FBGetInvitableFriendsCallback params:ret];
            }
        }];
    }else{
        return @"need login";
    }
    return @"sending";
}

+(NSString *)getAllRequestsForReward{
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                      initWithGraphPath:@"/me/apprequests"
                                      parameters:NULL
                                      HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            // Handle the result
            if (error) {
                NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
                [dict setValue:[error localizedDescription] forKey:@"error"];
                [dict setValue:@(3) forKey:@"ret"];
                NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
                NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                [[LuaEventProxy sharedProxy]dispatchEvent:FBGetAllRequestsForReward params:ret];
            }else{
                NSArray *array = [result objectForKey:@"data"];
                for(NSDictionary* obj in array){
                    NSString *app_id = [[obj objectForKey:@"application"] objectForKey:@"id"];
                    NSString *mid = [obj objectForKey:@"data"];
                    if ([app_id isEqualToString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"FacebookAppID"]]) {
                        NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
                        [dict setValue:mid forKey:@"mid"];
                        [dict setValue:@(1) forKey:@"ret"];
                        NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
                        NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                        [[LuaEventProxy sharedProxy]dispatchEvent:FBGetAllRequestsForReward params:ret];
                        return ;
                    }
                }
            }
        }];
    }else{
        return @"need login";
    }
    return @"sending";
}



/**
 A delegate for FBSDKSharing.
 
 The delegate is notified with the results of the sharer as long as the application has permissions to
 receive the information.  For example, if the person is not signed into the containing app, the sharer may not be able
 to distinguish between completion of a share and cancellation.
 */
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    NSLog(@"facebook share Success");
    NSLog(@"facebook share:%@",results);
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setValue:@(1) forKey:@"ret"];
    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [[LuaEventProxy sharedProxy]dispatchEvent:shareCallback params:ret];
}

/**
 Sent to the delegate when the sharer encounters an error.
 - Parameter sharer: The FBSDKSharing that completed.
 - Parameter error: The error.
 */
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    NSLog(@"facebook share fail:%@",[error localizedDescription]);
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setValue:@(3) forKey:@"ret"];
    [dict setValue:[error localizedDescription] forKey:@"error"];
    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [[LuaEventProxy sharedProxy]dispatchEvent:shareCallback params:ret];
}

/**
 Sent to the delegate when the sharer is cancelled.
 - Parameter sharer: The FBSDKSharing that completed.
 */
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer{
    NSLog(@"facebook share cancel");
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setValue:@(2) forKey:@"ret"];
    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    NSString * ret = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [[LuaEventProxy sharedProxy]dispatchEvent:shareCallback params:ret];
}

/**
 Sent to the delegate when the game request completes without error.
 - Parameter gameRequestDialog: The FBSDKGameRequestDialog that completed.
 - Parameter results: The results from the dialog.  This may be nil or empty.
 */
- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didCompleteWithResults:(NSDictionary *)results{
    NSLog(@"facebook GameRequest Success");
    NSLog(@"facebook GameRequest:%@",results);
}

/**
 Sent to the delegate when the game request encounters an error.
 - Parameter gameRequestDialog: The FBSDKGameRequestDialog that completed.
 - Parameter error: The error.
 */
- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didFailWithError:(NSError *)error{
    NSLog(@"facebook GameRequest fail:%@",[error localizedDescription]);
}

/**
 Sent to the delegate when the game request dialog is cancelled.
 - Parameter gameRequestDialog: The FBSDKGameRequestDialog that completed.
 */
- (void)gameRequestDialogDidCancel:(FBSDKGameRequestDialog *)gameRequestDialog{
    NSLog(@"facebook GameRequest cancel");
}
@end
