package com.woyao.luaevent;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Vibrator;
import android.provider.Settings;
import android.util.Log;

import com.google.firebase.iid.FirebaseInstanceId;
import com.umeng.analytics.MobclickAgent;
import com.woyao.utils.Function;
import com.woyao.utils.NotificationService;
import com.woyao.voicerecord.VoiceRecord;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lua.AppActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayDeque;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Queue;

/**
 * Created by bearluo on 2017/6/5.
 */

public class LuaEventProxy {

    private static String TAG = LuaEventProxy.class.getSimpleName();
    private static LuaEventProxy instance = new LuaEventProxy();
    private Cocos2dxActivity activity;
    private static Queue<Runnable> queue = new ArrayDeque<>();
    public static LuaEventProxy getInstance(){
        return instance;
    }
    public void setCocos2dxActivity(final Cocos2dxActivity activity) {
        this.activity = activity;
    }

    public void dispatchEventSuccess(final String event_cmd) {
        JSONObject object = new JSONObject();
        dispatchEventSuccess(event_cmd,object);
    }

    public void dispatchEventFail(final String event_cmd,final String error) {
        JSONObject object = new JSONObject();
        dispatchEventFail(event_cmd,error,object);
    }

    public void dispatchEventCancel(final String event_cmd) {
        JSONObject object = new JSONObject();
        dispatchEventCancel(event_cmd,object);
    }

    public void dispatchEventSuccess(final String event_cmd,final JSONObject object) {
        try {
            object.put("ret", Contants.ret.success);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        dispatchEvent(event_cmd,object.toString(),true);
    }

    public void dispatchEventFail(final String event_cmd,final String error,final JSONObject object) {
        try {
            object.put("ret", Contants.ret.fail);
            object.put("error",error);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        dispatchEvent(event_cmd,object.toString(),true);
    }

    public void dispatchEventCancel(final String event_cmd,final JSONObject object) {
        try {
            object.put("ret", Contants.ret.cancel);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        dispatchEvent(event_cmd,object.toString(),true);
    }

    public void dispatchEvent(final String event_cmd,final String params) {
        dispatchEvent(event_cmd,params,true);
    }

    public void dispatchEvent(final String event_cmd,final String params,final boolean runOnGLThread) {
        Runnable mRunnable = new Runnable(){
            @Override
            public void run() {
                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("cmd",event_cmd);
                    jsonObject.put("params",params);
                    int ret = Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("native_event",jsonObject.toString());
                    Log.d(TAG, String.format("dispatchEvent: cmd %s ret %d",event_cmd,ret));
                } catch (JSONException e) {
//                    e.printStackTrace();
                    Log.e(TAG, String.format("dispatchEvent: cmd %s JSONException %s",event_cmd,e.getMessage()));
                }
            }
        };
        Log.i(TAG, String.format("dispatchEvent: cmd %s runOnGLThread %b",event_cmd,runOnGLThread));
        if (runOnGLThread) {
            queue.add(mRunnable);
        }else{
            mRunnable.run();
        }
    }

    public void dispatchQueueEvent() {
        while(!queue.isEmpty()) {
            Runnable mRunnable = queue.poll();
            activity.runOnGLThread(mRunnable);
        }
    }

    public static void getQueueEvent() {
        LuaEventProxy.getInstance().dispatchQueueEvent();
    }

    public static int getBatterypercentage() {
        return Function.getBatterypercentage(LuaEventProxy.getInstance().activity);
    }

    public static int getSignalStrength() {
        int type = Function.getAPNType(LuaEventProxy.getInstance().activity);
//        没有网络-0：WIFI网络1：4G网络-4：3G网络-3：2G网络-2
        if ( type == 0 ) return 0;
        if ( type == 1 ) return Function.getWIFISignalStrength(LuaEventProxy.getInstance().activity);
        return Function.getTeleSignalStrength(LuaEventProxy.getInstance().activity);
    }

    public static void onProfileSignIn(String Provider, String ID){
        Log.i(TAG,String.format("onProfileSignIn Provider:%s ID:%s",Provider,ID));
        if (ID.compareTo("") == 0) return;
        if ( Provider.compareTo("") == 0 )
            MobclickAgent.onProfileSignIn(ID);
        else
            MobclickAgent.onProfileSignIn(Provider,ID);
    }

    public static void onProfileSignOff() {
        Log.i(TAG,String.format("onProfileSignOff"));
        MobclickAgent.onProfileSignOff();
    }

    public static void onEvent(String eventId,String jsonStr) {
        Log.i(TAG,String.format("onEvent eventId:%s jsonStr:%s",eventId,jsonStr));
        if (eventId.compareTo("") == 0) return;

        if (jsonStr.compareTo("") == 0 || jsonStr.compareTo("null") == 0 ) {
            MobclickAgent.onEvent(LuaEventProxy.getInstance().activity, eventId);
            return;
        }

        HashMap<String,String> map = new HashMap<String,String>();
        try {
            JSONObject jsonObject= new JSONObject(jsonStr);
            for (Iterator<String> keys = jsonObject.keys(); keys.hasNext();) {
                String key = keys.next();
                System.out.println("key:" + key + "----------jo.get(key):"
                        + jsonObject.getString(key));
                map.put(key,jsonObject.getString(key));
            }
            MobclickAgent.onEvent(LuaEventProxy.getInstance().activity, eventId,map);
        } catch (JSONException e) {
//            e.printStackTrace();
            MobclickAgent.onEvent(LuaEventProxy.getInstance().activity, eventId);
        }
    }

    public static void onEventValue(String eventId,String jsonStr,int value) {
        Log.i(TAG,String.format("onEventValue eventId:%s jsonStr:%s value:%d",eventId,jsonStr,value));
        if (eventId.compareTo("") == 0) return;
        if (jsonStr.compareTo("") == 0 || jsonStr.compareTo("null") == 0) return;
        HashMap<String,String> map = new HashMap<String,String>();
        try {
            JSONObject jsonObject= new JSONObject(jsonStr);
            for (Iterator<String> keys = jsonObject.keys(); keys.hasNext();) {
                String key = keys.next();
                System.out.println("key:" + key + "----------jo.get(key):"
                        + jsonObject.getString(key));
                map.put(key,jsonObject.getString(key));
            }
            MobclickAgent.onEventValue(LuaEventProxy.getInstance().activity, eventId,map,value);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public static void reportError(String error) {
        Log.i(TAG,String.format("reportError error:%s",error));
        if (error.compareTo("") == 0) return;
        MobclickAgent.reportError(LuaEventProxy.getInstance().activity, error);
    }

    public static void vibrate() {
        Vibrator vibrator = (Vibrator)LuaEventProxy.getInstance().activity.getApplicationContext().getSystemService(Context.VIBRATOR_SERVICE);
        long [] pattern = {100,400,100,400};   // 停止 开启 停止 开启
        vibrator.vibrate(pattern,-1);
    }

    public static void startRecord(String path,String what) {
        VoiceRecord.getInstance().startRecording(path, what);
    }
    public static void stopRecord() {
        VoiceRecord.getInstance().stopRecording();
    }
    static public int copyToClipboard(final String text)
    {
        try
        {
            //Log.d("cocos2dx","copyToClipboard " + text);
            Runnable runnable = new Runnable() {
                public void run() {
                    android.content.ClipboardManager clipboard = (android.content.ClipboardManager) Cocos2dxActivity.getContext().getSystemService(Context.CLIPBOARD_SERVICE);
                    android.content.ClipData clip = android.content.ClipData.newPlainText("Copied Text", text);
                    clipboard.setPrimaryClip(clip);
                }
            };
            //getSystemService运行所在线程必须执行过Looper.prepare()
            //否则会出现Can't create handler inside thread that has not called Looper.prepare()
            ((Cocos2dxActivity)Cocos2dxActivity.getContext()).runOnUiThread(runnable);

        }catch(Exception e){
            // Log.d("cocos2dx","copyToClipboard error");
            e.printStackTrace();
            return -1;
        }
        return 0;
    }

    public static void displayWebView(final int x,final int y,final int width,final int height) {
        AppActivity.getActivity().displayWebView(x,y,width,height);
    }

    public static void displayWebView(final int x,final int y,final int width,final int height,final boolean showClose) {
        AppActivity.getActivity().displayWebView(x,y,width,height,showClose);
    }

    public static void dismissWebView(){
        AppActivity.getActivity().dismissWebView();
    }

    public static void webViewLoadUrl(String url) {
        AppActivity.getActivity().loadUrl(url);
    }

    public static int isWebViewVisible() {
        return AppActivity.getActivity().isWebViewVisible() == true ? 1:0;
    }

    public static String getPushToken() {
        String refreshedToken = FirebaseInstanceId.getInstance().getToken();
        if (refreshedToken == null)
            return "";
        else
            return refreshedToken;
    }

    public static int isNotificationEnabled() {
        return Function.isNotificationEnabled(LuaEventProxy.getInstance().activity) ? 1 : 0;
    }

    public static void gotoSet() {
        LuaEventProxy.getInstance().activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    Intent intent = new Intent();
                    intent.setAction("android.settings.APP_NOTIFICATION_SETTINGS");
                    intent.putExtra("app_package", LuaEventProxy.getInstance().activity.getPackageName());
                    intent.putExtra("app_uid", LuaEventProxy.getInstance().activity.getApplicationInfo().uid);
                    LuaEventProxy.getInstance().activity.startActivity(intent);
                } else if (android.os.Build.VERSION.SDK_INT == Build.VERSION_CODES.KITKAT) {
                    Intent intent = new Intent();
                    intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                    intent.addCategory(Intent.CATEGORY_DEFAULT);
                    intent.setData(Uri.parse("package:" + LuaEventProxy.getInstance().activity.getPackageName()));
                    LuaEventProxy.getInstance().activity.startActivity(intent);
                }else {
                    Intent intent = new Intent(Settings.ACTION_SETTINGS);
                    LuaEventProxy.getInstance().activity.startActivity(intent);
                }
            }
        });
    }

    public static void removeSplashView() {
        AppActivity.removeSplashView();
    }

    public static void gotoEvaluate() {
        AppActivity.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                String mAddress = "market://details?id=" + AppActivity.getActivity().getPackageName();
                Intent marketIntent = new Intent("android.intent.action.VIEW");
                marketIntent.setData(Uri.parse(mAddress ));
                AppActivity.getActivity().startActivity(marketIntent);
            }
        });
    }

    public static String getBLUUID(){
        return Function.getUUID();
    }

    public static int getVersionCode()//获取版本号(内部识别号)
    {
        try {
            PackageInfo pi=AppActivity.getActivity().getPackageManager().getPackageInfo(AppActivity.getActivity().getPackageName(), 0);
            return pi.versionCode;
        } catch (PackageManager.NameNotFoundException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            return 0;
        }
    }

    /*
     * name:通知名字，作为通知id使用
     * content：通知内容
     * time：倒时时（秒）
     * */
    public static int addLocalNotication(String title,String content, int time) {
        Log.i(TAG, "addLocalNotication title:" + title);
        Log.i(TAG, "addLocalNotication content:" + content);
        Log.i(TAG, "addLocalNotication time:" + time * 1000L);
        int id = (int) (System.currentTimeMillis() % 100000);
        Activity activity = LuaEventProxy.getInstance().activity;
        Intent intent = new Intent(activity, NotificationService.class);
        intent.putExtra("title", title);
        intent.putExtra("contentText", content);
        PendingIntent pi = PendingIntent.getService(activity, id, intent, PendingIntent.FLAG_CANCEL_CURRENT);
        AlarmManager am = (AlarmManager) activity.getSystemService(Context.ALARM_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            am.setExact(AlarmManager.RTC_WAKEUP, time*1000L, pi);
        } else {
            am.set(AlarmManager.RTC_WAKEUP, time*1000L, pi);
        }

//        am.setRepeating(AlarmManager.RTC_WAKEUP,System.currentTimeMillis(),10000,pi);
        return id;
    }

    public static void delLoaclNotication(int id) {
        Activity activity = LuaEventProxy.getInstance().activity;
        Intent intent = new Intent(activity, NotificationService.class);
        PendingIntent sender = PendingIntent.getService(activity, id, intent, PendingIntent.FLAG_NO_CREATE);
        AlarmManager am = (AlarmManager) activity.getSystemService(Context.ALARM_SERVICE);
        if (sender != null){
            Log.i(TAG,"delLoaclNotication cancel alarm");
            am.cancel(sender);
        }else{
            Log.i(TAG,"delLoaclNotication sender == null");
        }
    }

    public static void sysShareString(String msg, String url) {
        Intent share_intent = new Intent();
        share_intent.setAction(Intent.ACTION_SEND);//设置分享行为
        share_intent.setType("text/plain");//设置分享内容的类型
//        share_intent.putExtra(Intent.EXTRA_SUBJECT, contentTitle);//添加分享内容标题
        share_intent.putExtra(Intent.EXTRA_TEXT, msg +"\n" + url);//添加分享内容
        LuaEventProxy.getInstance().activity.startActivity(share_intent);
    }
}
