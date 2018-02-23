package com.woyao.luaevent;

/**
 * Created by bearluo on 2017/6/5.
 */

public class Contants {
    public static String loginFacebook = "loginFacebook";
    public static String loginYouke = "loginYouke";
    public static String gpayConsume = "gpayConsume";   //google支付成功向服务器请求发货
    public static String voiceRecord = "voiceRecord";   //錄音廣播
    public static String voiceRecordDecibels = "voiceRecordDecibels";   //錄音分貝 百分比
    public static String registerPushTokenChange = "registerPushTokenChange";   // 推送token 变更
    public static String pushMsg = "pushMsg";   // 推送消息
    public static String bluepayCallback = "bluepayCallback";   // 支付返回
    public static String shareCallback = "shareCallback";
    public static String FBGetInvitableFriendsCallback = "FBGetInvitableFriendsCallback";
    public static String FBGetAllRequestsForReward = "FBGetAllRequestsForReward";


    public static class ret {
        public static int success = 1;
        public static int cancel = 2;
        public static int fail = 3;
        public static int TimeOut = 4;
    };
}
