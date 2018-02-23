package com.woyao.facebook;

import android.app.Activity;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.HttpMethod;
import com.facebook.LoggingBehavior;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.Profile;
import com.facebook.applinks.AppLinkData;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.ShareApi;
import com.facebook.share.Sharer;
import com.facebook.share.model.AppInviteContent;
import com.facebook.share.model.GameRequestContent;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.model.ShareOpenGraphAction;
import com.facebook.share.model.ShareOpenGraphContent;
import com.facebook.share.model.ShareOpenGraphObject;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.widget.AppInviteDialog;
import com.facebook.share.widget.GameRequestDialog;
import com.facebook.share.widget.ShareDialog;
import com.woyao.luaevent.*;
import com.woyao.luaevent.Contants;
import com.woyao.thai.poker.R;
import com.woyao.utils.Function;

import org.cocos2dx.lua.AppActivity;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.Arrays;

import bolts.AppLinks;

/**
 * Created by bearluo on 2017/6/2.
 */


public class FacebookProxy {

    private CallbackManager callbackManager;
    private static FacebookProxy instance = new FacebookProxy();
    private static String TAG = FacebookProxy.class.getSimpleName();
    public static FacebookProxy getInstance(){
        return instance;
    }
    public static Activity mActivity;
    public ShareDialog shareDialog;
    public GameRequestDialog requestDialog;
    private String invite_code = "";
    public void onCreate(final Activity activity) {
        mActivity = activity;
        FacebookSdk.addLoggingBehavior(LoggingBehavior.APP_EVENTS);
        FacebookSdk.setIsDebugEnabled(true);
//        FacebookSdk.sdkInitialize(activity.getApplicationContext());
        initAppLogin(activity);
        initAppInvite(activity);
    }
    private void initAppLogin(final Activity activity){
        callbackManager = CallbackManager.Factory.create();
        registerCallback(new FacebookCallback<LoginResult>() {
            @Override
            public void onSuccess(final LoginResult loginResult) {
                // App code
                AccessToken accessToken = loginResult.getAccessToken();
                final String userId = accessToken.getUserId();
                final String token = accessToken.getToken();
                Log.e(TAG,String.format("成功：userId:%s token:%s",userId,token));
                updateUI();

                GraphRequest request = GraphRequest.newMeRequest(
                        loginResult.getAccessToken(),
                        new GraphRequest.GraphJSONObjectCallback() {

                            //當RESPONSE回來的時候

                            @Override
                            public void onCompleted(JSONObject object, GraphResponse response) {
                                updateUI();
                                //讀出姓名 ID FB個人頁面連結
                                if ( response.getError() == null ) {
                                    Log.d("FB","complete");
                                    Log.d("FB",object.optString("name"));
                                    Log.d("FB",object.optString("id"));
                                    try {
                                        object.put("fb_token",token);
                                    } catch (JSONException e) {
                                        e.printStackTrace();
                                    }
                                    LuaEventProxy.getInstance().dispatchEventSuccess(com.woyao.luaevent.Contants.loginFacebook, Function.getLoginCommentData(object,activity));
                                }else {
                                    LuaEventProxy.getInstance().dispatchEventFail(com.woyao.luaevent.Contants.loginFacebook,response.getError().toString());
                                }
                            }
                        });

                //包入你想要得到的資料 送出request

                Bundle parameters = new Bundle();
                parameters.putString("fields", "id,name,gender");
                request.setParameters(parameters);
                request.executeAsync();
            }

            @Override
            public void onCancel() {
                // App code
                Log.e(TAG,"取消");
                LuaEventProxy.getInstance().dispatchEventCancel(com.woyao.luaevent.Contants.loginFacebook);
            }

            @Override
            public void onError(final FacebookException exception) {
                // App code
                Log.e(TAG,"失败：" + exception.toString());
                LuaEventProxy.getInstance().dispatchEventFail(com.woyao.luaevent.Contants.loginFacebook,exception.toString());
            }
        });

//        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams
//                (FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
//        Button mbtn = new Button(activity);
//        mbtn.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                login(activity);
//            }
//        });
//        activity.addContentView(mbtn,params);
//        new ProfileTracker() {
//            @Override
//            protected void onCurrentProfileChanged(
//                    final Profile oldProfile,
//                    final Profile currentProfile) {
//                // 用户数据变更
//                Log.e(TAG,"onCurrentProfileChanged");
//                updateUI();
//            }
//        };
        shareDialog = new ShareDialog(activity);
        shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
            @Override
            public void onSuccess(Sharer.Result result) {
                Log.i(TAG,"Success");
                LuaEventProxy.getInstance().dispatchEventSuccess(com.woyao.luaevent.Contants.shareCallback);
            }

            @Override
            public void onCancel() {
                Log.i(TAG,"Cancel");
                LuaEventProxy.getInstance().dispatchEventCancel(com.woyao.luaevent.Contants.shareCallback);
            }

            @Override
            public void onError(FacebookException error) {
                Log.i(TAG,"Error");
                Log.i(TAG,error.toString());
                LuaEventProxy.getInstance().dispatchEventFail(com.woyao.luaevent.Contants.shareCallback,error.toString());
            }
        });

        requestDialog = new GameRequestDialog(activity);
        requestDialog.registerCallback(callbackManager, new FacebookCallback<GameRequestDialog.Result>() {
            @Override
            public void onSuccess(GameRequestDialog.Result result) {
                Log.i(TAG,"Success");
                Log.i(TAG,result.getRequestRecipients().toString());
            }

            @Override
            public void onCancel() {
                Log.i(TAG,"Cancel");
            }

            @Override
            public void onError(FacebookException error) {
                Log.i(TAG,"Error");
                Log.i(TAG,error.toString());
            }
        });

    }
    private void initAppInvite(final Activity activity){
        Uri targetUrl =
                AppLinks.getTargetUrlFromInboundIntent(activity, activity.getIntent());
        if (targetUrl != null) {
            Log.i("Activity", "App Link Target URL: " + targetUrl.toString());
        } else {
            AppLinkData.fetchDeferredAppLinkData(
                    activity,
                    new AppLinkData.CompletionHandler() {
                        @Override
                        public void onDeferredAppLinkDataFetched(AppLinkData appLinkData) {
                            //process applink data
                            if (appLinkData != null) {
                                Uri targetUrl = appLinkData.getTargetUri();
                                Log.i("Activity", "App Link Target URL: " + targetUrl.toString());
                            }
                        }
                    });
        }
    }

    private void updateUI() {
        Profile profile = Profile.getCurrentProfile();
        if (profile != null) {
            Log.e(TAG,String.format("id:%s FirstName:%s LastName:%s",profile.getId(),profile.getFirstName(), profile.getLastName()));
        } else {
            Log.e(TAG,"updateUI null");
        }
    }

    public void onResume(Activity activity) {
//        AppEventsLogger.activateApp(activity);
    }

    public void onPause(Activity activity) {
//        AppEventsLogger.deactivateApp(activity);
    }

    public void onActivityResult(
            final int requestCode,
            final int resultCode,
            final Intent data) {
            callbackManager.onActivityResult(requestCode, resultCode, data);
    }

    public void login(Activity activity){
        if (isLoggedIn()) logout(activity);
        LoginManager.getInstance().logInWithReadPermissions(activity, Arrays.asList("public_profile","user_friends"));
    }

    public void logout(Activity activity){
        LoginManager.getInstance().logOut();
    }


    public void registerCallback(FacebookCallback<LoginResult> LoginResultListener) {
        LoginManager.getInstance().registerCallback(callbackManager,LoginResultListener);
    }

    public boolean isLoggedIn(){
        AccessToken accesstoken = AccessToken.getCurrentAccessToken();
        return !(accesstoken == null || accesstoken.getPermissions().isEmpty());
    }

    public static void loginFacebook(){
        getInstance().login(mActivity);
    }

    public static void shareLink(String url,String msg) {
        ShareLinkContent.Builder builder = new ShareLinkContent.Builder()
                .setContentUrl(Uri.parse(url));
        if (!msg.equals("")) {
            builder.setQuote(msg);
        }
        ShareLinkContent content = builder.build();
        getInstance().shareDialog.show(content);
    }

    public static void sharePhoto() {
        SharePhoto photo = new SharePhoto.Builder()
                .setBitmap(BitmapFactory.decodeResource(getInstance().mActivity.getResources(), R.drawable.icon))
                .build();
        SharePhotoContent content = new SharePhotoContent.Builder()
                .addPhoto(photo)
                .build();
        getInstance().shareDialog.show(content);
    }

    public static void shareOpenGraph(String url,String title,String bmpPath) {
        SharePhoto.Builder photoBuilder = new SharePhoto.Builder();
        if (bmpPath.substring(0,7).compareTo("assets/") == 0) {
            try {
                photoBuilder.setBitmap(BitmapFactory.decodeStream(getInstance().mActivity.getAssets().open(bmpPath.substring(7))));
            } catch (IOException e) {
                e.printStackTrace();
            }
        }else{
            photoBuilder.setBitmap(BitmapFactory.decodeFile(bmpPath));
        }

        SharePhoto photo = photoBuilder.build();
        // Create an object
        ShareOpenGraphObject object = new ShareOpenGraphObject.Builder()
                .putString("fb:app_id", getInstance().mActivity.getResources().getString(R.string.facebook_app_id))
                .putString("og:type", "game.achievement")
                .putString("og:url", url)
                .putString("og:title", title)
                .putPhoto("og:image", photo)
//                .putString("og:image", getInstance().mActivity.getResources().getString(R.string.fb_share_img))
//                .putString("game:points", "10")
                .build();
        // Create an action
        ShareOpenGraphAction action = new ShareOpenGraphAction.Builder()
                .setActionType("games.celebrate")
                .putObject("victory", object)
                .build();
        // Create the content
        ShareOpenGraphContent content = new ShareOpenGraphContent.Builder()
                .setPreviewPropertyName("victory")
                .setAction(action)
                .build();
        getInstance().shareDialog.show(content);
    }

    public static String invitabelFriends(String to,String mid,String msg) {
        Log.d(TAG,"FB invitabelFriends:" + to);
        String[] recipientsArray = to.split(", ");
        GameRequestContent content = new GameRequestContent.Builder()
                .setMessage(msg)
                .setRecipients(Arrays.asList(recipientsArray))
//                .setActionType(GameRequestContent.ActionType.TURN)
//                .setObjectId("YOUR_OBJECT_ID")
                .setData(mid)
                .build();
        getInstance().requestDialog.show(content);
        return "success";
    }

    public static String getInvitableFriends() {
        if (AccessToken.getCurrentAccessToken() == null) {
            return "need login";
        }else{
            GraphRequest request = GraphRequest.newGraphPathRequest(
                    AccessToken.getCurrentAccessToken(),
                    "me/invitable_friends",
                    new GraphRequest.Callback() {
                        @Override
                        public void onCompleted(GraphResponse response) {
                            JSONObject object = response.getJSONObject();
                            if ( response.getError() == null ) {
                                Log.d(TAG,"FB invitable_friends:" + response.toString());
                                LuaEventProxy.getInstance().dispatchEventSuccess(Contants.FBGetInvitableFriendsCallback,object);
                            }else {
                                Log.d(TAG,"FB invitable_friends" + response.getError().toString());
                                LuaEventProxy.getInstance().dispatchEventFail(Contants.FBGetInvitableFriendsCallback,response.getError().toString());
                            }
                        }
                    });
            Bundle parameters = new Bundle();
            parameters.putString("fields", "id,name,picture.width(80).height(80)");
            parameters.putString("limit",String.valueOf(100));
            request.setParameters(parameters);
            request.executeAsync();
            return "sending";
        }
    }

    public static void getAllRequestsForReward() {
        GraphRequest.newGraphPathRequest(AccessToken.getCurrentAccessToken(),"me/apprequests", new GraphRequest.Callback() {
            @Override
            public void onCompleted(GraphResponse response) {
                //data was sort by fb according request time
                JSONObject object = response.getJSONObject();
                if ( response.getError() == null ) {
                    Log.d(TAG,"FB apprequests:" + response.toString());
                    try {
                        JSONArray data = object.getJSONArray("data");
                        if (data == null || data.length() == 0) {
                            return;
                        }
                        for (int i = 0; i < data.length(); i++) {
                            JSONObject requestObject = data.optJSONObject(i);
                            String app_id = requestObject.getJSONObject("application").getString("id");
                            String mid = requestObject.optString("data");
                            if (app_id.equals(AppActivity.getContext().getResources().getString(R.string.facebook_app_id))) {
                                JSONObject retObject = new JSONObject();
                                retObject.put("mid",mid);
                                LuaEventProxy.getInstance().dispatchEventSuccess(Contants.FBGetAllRequestsForReward,retObject);
                                return;
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }else {
                    Log.d("FB apprequests",response.getError().toString());
                    LuaEventProxy.getInstance().dispatchEventFail(Contants.FBGetAllRequestsForReward,response.getError().toString());
                }
            }
        }).executeAsync();
    }

    public static String appInvite(String appLinkUrl,String previewImageUrl) {
        return "deprecated";
    }

    public void onIntent(Intent intent) {
        Uri targetUrl =
                AppLinks.getTargetUrlFromInboundIntent(mActivity, intent);
        if (targetUrl != null) {
            Log.i("Activity", "App Link Target URL: " + targetUrl.toString());
            onUrl(targetUrl);
        } else {
            AppLinkData.fetchDeferredAppLinkData(
                    mActivity,
                    new AppLinkData.CompletionHandler() {
                        @Override
                        public void onDeferredAppLinkDataFetched(AppLinkData appLinkData) {
                            //process applink data
                            if (appLinkData != null) {
                                Uri targetUrl = appLinkData.getTargetUri();
                                if (targetUrl != null) {
                                    onUrl(targetUrl);
                                }
                            }
                        }
                    });
        }
    }

    public void onUrl(Uri targetUrl) {
//        if (targetUrl.getHost().equals("invite_from_fb")) {
//            invite_code = targetUrl.getQueryParameter("invite_code");
//            if (invite_code == null) invite_code = "";
//        }
    }
}
