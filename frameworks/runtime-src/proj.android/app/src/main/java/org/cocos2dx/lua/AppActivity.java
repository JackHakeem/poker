/****************************************************************************
 Copyright (c) 2008-2010 Ricardo Quesada
 Copyright (c) 2010-2012 cocos2d-x.org
 Copyright (c) 2011      Zynga Inc.
 Copyright (c) 2013-2014 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
package org.cocos2dx.lua;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHelper;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.umeng.analytics.MobclickAgent;
import com.woyao.bluepay.BluepayHelper;
import  com.woyao.gpay.GPayLuaCall;

import com.woyao.facebook.FacebookProxy;
import com.woyao.luaevent.LuaEventProxy;
import com.woyao.thai.poker.R;
import com.woyao.utils.AndroidBug5497Workaround;
import com.woyao.utils.Function;
import com.woyao.utils.PermissionHelper;
import com.woyao.utils.ShortCutUtils;
import com.woyao.youke.YoukeProxy;

import java.lang.reflect.Method;

public class AppActivity extends Cocos2dxActivity implements ActivityCompat.OnRequestPermissionsResultCallback {

    static final String TAG = "PokerApp";
    private WebView m_webView;
    private Button webViewCloseBtn;
    private ProgressBar mProgressBar;
    private int usableHeightPrevious;
    private int webViewHeight;

    private static ImageView imageView=null;
    private static AppActivity mAppActivity;
    private static Handler mHandler;

    private static long startTime=0;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mAppActivity = this;
        mHandler = new Handler();
//        AndroidBug5497Workaround.assistActivity(this);
        GPayLuaCall.init(this);
        FacebookProxy.getInstance().onCreate(this);
        FacebookProxy.getInstance().onIntent(getIntent());
        LuaEventProxy.getInstance().setCocos2dxActivity(this);
        YoukeProxy.getInstance().setActivity(this);
        MobclickAgent.enableEncrypt(true);
        BluepayHelper.init(this);
        //  不锁屏 不休眠
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        saveVersionInfo();
        GoogleApiAvailability googleApiAvailability = GoogleApiAvailability.getInstance();
        int resultCode = googleApiAvailability.isGooglePlayServicesAvailable(this);
        if(resultCode != ConnectionResult.SUCCESS)
        {
            if(googleApiAvailability.isUserResolvableError(resultCode))
            {
                googleApiAvailability.getErrorDialog(this,
                        resultCode, 2404).show();
            }
        }
        //addContentView(createLogoImg(), new WindowManager.LayoutParams(WindowManager.LayoutParams.FILL_PARENT, WindowManager.LayoutParams.FILL_PARENT));//添加启动页
        startTime = System.currentTimeMillis();
        FrameLayout content = (FrameLayout) findViewById(android.R.id.content);
        final View mChildOfContent = content.getChildAt(0);
        mChildOfContent.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            public void onGlobalLayout() {
                if (m_webView != null) {
                    Rect r = new Rect();
                    mChildOfContent.getWindowVisibleDisplayFrame(r);
                    FrameLayout.LayoutParams frameLayoutParams = (FrameLayout.LayoutParams) m_webView.getLayoutParams();
                    int usableHeightNow = (r.bottom - r.top);
                    if (usableHeightNow != usableHeightPrevious) {
                        int usableHeightSansKeyboard = m_webView.getRootView().getHeight();
                        int heightDifference = usableHeightSansKeyboard - usableHeightNow;
                        if (heightDifference > (usableHeightSansKeyboard / 4)) {
                            // keyboard probably just became visible
                            frameLayoutParams.height = usableHeightSansKeyboard - heightDifference;
                        } else {
                            // keyboard probably just became hidden
                            frameLayoutParams.height = webViewHeight;
                        }
                        m_webView.requestLayout();
                        usableHeightPrevious = usableHeightNow;
                    }
                }
            }
        });
    }
    public ImageView createLogoImg() {
        imageView = new ImageView(this);
//        imageView.setImageResource(R.drawable.splash);

        imageView.setScaleType(ImageView.ScaleType.FIT_CENTER);// 设置当前图像的图像（position为当前图像列表的位置）
//        imageView.setRotation(90);
        return imageView;
    }

    public static void removeSplashView() {
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (imageView!=null) {
                    imageView.setVisibility(View.GONE);
                }
            }
        });
    }

    private void goToSet(){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.BASE) {
            // 进入设置系统应用权限界面
            Intent intent = new Intent(Settings.ACTION_SETTINGS);
            startActivity(intent);
            return;
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {// 运行系统在5.x环境使用
            // 进入设置系统应用权限界面
            Intent intent = new Intent(Settings.ACTION_SETTINGS);
            startActivity(intent);
            return;
        }
    }

    void destroyWebView() {
        if (m_webView != null) {
            m_webView.setVisibility(View.GONE);
            m_webView.destroy();
            m_webView = null;
        }
    }

    void initWebView() {
        if (mProgressBar != null) mProgressBar.setVisibility(View.GONE);
        if (m_webView != null) {
            return;
        }

        webViewCloseBtn = new Button((Cocos2dxActivity) Cocos2dxActivity.getContext());
        webViewCloseBtn.setBackgroundResource(R.drawable.btn_close2);
        webViewCloseBtn.setOnClickListener(new Button.OnClickListener(){
            @Override
            public void onClick(View v) {
                dismissWebView();
            }
        });

        m_webView = new WebView((Cocos2dxActivity) Cocos2dxActivity.getContext());

        mProgressBar = new ProgressBar(Cocos2dxActivity.getContext(), null,
                android.R.attr.progressBarStyleHorizontal);
        LinearLayout.LayoutParams layoutParams1 = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, 8);
        mProgressBar.setLayoutParams(layoutParams1);
        Drawable drawable = Cocos2dxActivity.getContext().getResources().getDrawable(
                R.drawable.progress_horizontal);
        mProgressBar.setProgressDrawable(drawable);
        m_webView.addView(mProgressBar);
        m_webView.addView(webViewCloseBtn);
//        mFrameLayout.addView(m_webView);
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT);
        //可选的webview位置，x,y,width,height可任意填写，也可以做为函数参数传入。
        m_webView.setLayoutParams(layoutParams);
        addContentView(m_webView,layoutParams);
        //可选的webview配置
        m_webView.setBackgroundColor(0);
        m_webView.getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);
        m_webView.getSettings().setAppCacheEnabled(false);
        m_webView.getSettings().setJavaScriptEnabled(true);

        m_webView.setWebViewClient(new WebViewClient(){
            public boolean shouldOverrideUrlLoading(final WebView view,final String url) {
                Log.i(TAG,String.format("displayWebView url:%s",url));
                Uri uri = Uri.parse(url);
                if (uri.getScheme().compareTo("weixin") == 0) {
                    Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                    startActivity(intent);
                    return true;
                }
                return false;
            }
            public void onReceivedError(WebView view, int errorCode,String description, String failingUrl) {
                Log.i(TAG,String.format("onReceivedError description:%s",description));
            }
            public void onReceivedSslError(WebView view, android.webkit.SslErrorHandler handler, android.net.http.SslError error) {
                if(error.getPrimaryError() == android.net.http.SslError.SSL_INVALID ){// 校验过程遇到了bug
                    handler.proceed();
                }else{
                    handler.cancel();
                }
            }
        });
        m_webView.setWebChromeClient(new WebChromeClient(){
            public void onProgressChanged(WebView view, int newProgress) {
                Log.i(TAG,String.format("onProgressChanged newProgress:%d",newProgress));
                if (newProgress == 100) {
                    mProgressBar.setVisibility(View.GONE);
                } else {
                    if (mProgressBar.getVisibility() == View.GONE)
                        mProgressBar.setVisibility(View.VISIBLE);
                    mProgressBar.setProgress(newProgress);
                }
                super.onProgressChanged(view, newProgress);
            }
        });
        m_webView.setVisibility(View.GONE);
    }
	
    void complain(String message) {
        Log.e(TAG, "**** TrivialDrive Error: " + message);
        alert("Error: " + message);
    }

    void alert(String message) {
        AlertDialog.Builder bld = new AlertDialog.Builder(this);
        bld.setMessage(message);
        bld.setNeutralButton("OK", null);
        Log.d(TAG, "Showing alert dialog: " + message);
        bld.create().show();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // google play requestCode 10001
        Log.d(TAG, "onActivityResult(" + requestCode + "," + resultCode + "," + data);

        // Pass on the activity result to the helper for handling
       if (!GPayLuaCall.handleActivityResult(requestCode, resultCode, data)) {
           // not handled, so handle it ourselves (here's where you'd
           // perform any handling of activity results not related to in-app
           // billing...
           // super.onActivityResult(requestCode, resultCode, data);
            FacebookProxy.getInstance().onActivityResult(requestCode, resultCode, data);
       } else {
           Log.d(TAG, "onActivityResult handled by IABUtil.");
       }
    }

    public void Toast(final String msg) {
        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(AppActivity.this, msg, Toast.LENGTH_SHORT).show();
            }
        });
    }

    // We're being destroyed. It's important to dispose of the helper here!

    @Override
    protected void onResume() {
        super.onResume();
        FacebookProxy.getInstance().onResume(this);
        MobclickAgent.onResume(this);
        resumeWebView();
        Log.i(TAG,"PokerApp onResume");
    }

    @Override
    protected void onPause() {
        super.onPause();
        FacebookProxy.getInstance().onPause(this);
        MobclickAgent.onPause(this);
        pauseWebView();
        Log.i(TAG,"PokerApp onPause");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

         // very important:
        Log.d(TAG, "Destroying helper.");
        GPayLuaCall.onDestroy();
    }

    private float getVersionCode() {
        float versionCode = 0f;
        try{
            versionCode = this.getPackageManager().getPackageInfo(this.getPackageName(),0).versionCode;
        }catch (PackageManager.NameNotFoundException e){
            e.printStackTrace();
        }
        return versionCode;
    }

    private void saveVersionInfo() {
        float nowVersionCode = getVersionCode();
        Log.i(TAG,"nowVersionCode" + nowVersionCode);

        SharedPreferences sp = getSharedPreferences("version_info",MODE_PRIVATE);
        float spVersionCode = sp.getFloat("version_code",0f);

        if(nowVersionCode > spVersionCode) {
//            ShortCutUtils.delShortcut(this,this);
            ShortCutUtils.addShortCut(this, getResources().getString(R.string.app_name),R.drawable.icon,"org.cocos2dx.lua.AppActivity");
            SharedPreferences.Editor editor = sp.edit();
            editor.putFloat("version_code",nowVersionCode);
            editor.commit();
        }
    }
    public void displayWebView(final int x,final int y,final int width,final int height) {
        displayWebView(x,y,width,height,false);
    }
    public void displayWebView(final int x,final int y,final int width,final int height,final boolean showClose) {
        Log.i(TAG,String.format("displayWebView x:%d y:%d width:%d height:%d",x,y,width,height));
        this.runOnUiThread(new Runnable() {
            public void run() {
                if (m_webView == null) initWebView();
                FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT,
                        FrameLayout.LayoutParams.WRAP_CONTENT);
                layoutParams.leftMargin = x;
                layoutParams.topMargin = y;
                layoutParams.width = width;
                layoutParams.height = height;
                layoutParams.gravity = Gravity.TOP | Gravity.LEFT;
                webViewHeight = height;
                m_webView.setLayoutParams(layoutParams);
                m_webView.setVisibility(View.VISIBLE);
                if (showClose){
                    webViewCloseBtn.setVisibility(View.VISIBLE);
                    float scale = height/1480f;
                    Log.i(TAG,String.format("displayWebView scale:%f",scale));
                    webViewCloseBtn.getLayoutParams().width = height / 10;
                    webViewCloseBtn.getLayoutParams().height = height / 10;
                    webViewCloseBtn.setX(width - height / 10 - height / 40);
                    webViewCloseBtn.setY(height / 40);
                    webViewCloseBtn.requestLayout();
                }else{
                    webViewCloseBtn.setVisibility(View.GONE);
                }

            }
        });
    }

    public void dismissWebView(){
        Log.i(TAG,String.format("dismissWebView"));
        if (m_webView!=null) {
            this.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    destroyWebView();
//                    m_webView.setVisibility(View.GONE);
                }
            });
        }
    }

    public void loadUrl(final String url) {
        Log.i(TAG,"loadUrl");
        Log.i(TAG,url);
        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (m_webView == null) initWebView();
                m_webView.loadUrl(url);
            }
        });
    }

    public boolean isWebViewVisible() {
        if (m_webView!=null) {
            return m_webView.getVisibility() == View.VISIBLE;
        }
        return false;
    }

    public void pauseWebView() {
        if (m_webView!=null) {
            m_webView.onPause();
            m_webView.pauseTimers();
        }
    }

    public void resumeWebView() {
        if (m_webView!=null) {
            m_webView.onResume();
            m_webView.resumeTimers();
        }
    }

    public String getDeviceId() {
        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (PackageManager.PERMISSION_DENIED == ContextCompat.checkSelfPermission(AppActivity.getActivity(), Manifest.permission.READ_PHONE_STATE)) {
                return "PERMISSION_DENIED";
            }
        }

        String ret = ((TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE)).getDeviceId();
        if (ret == null) {
            return "ERROR";
        }
        return ret;
    }

    public String getMacAddress() {
        WifiManager wifi = (WifiManager)getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        WifiInfo info = wifi.getConnectionInfo();
        if (info == null)
            return "";
        return info.getMacAddress();
    }

    public String getAPNSting() {
        //获取手机所有连接管理对象
        ConnectivityManager manager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        //获取NetworkInfo对象
        NetworkInfo networkInfo = manager.getActiveNetworkInfo();
        //NetworkInfo对象为空 则代表没有网络
        if (networkInfo == null) {
            return "no network";
        }
        //否则 NetworkInfo对象不为空 则获取该networkInfo的类型
        int nType = networkInfo.getType();
        if (nType == ConnectivityManager.TYPE_WIFI) {
            //WIFI
            return "wifi";
        } else if (nType == ConnectivityManager.TYPE_MOBILE) {
            int nSubType = networkInfo.getSubtype();
            if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (PackageManager.PERMISSION_DENIED == ContextCompat.checkSelfPermission(AppActivity.getActivity(), Manifest.permission.READ_PHONE_STATE)) {
                    return "PERMISSION_DENIED";
                }
            }
            TelephonyManager telephonyManager = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
            //3G   联通的3G为UMTS或HSDPA 电信的3G为EVDO
            if (nSubType == TelephonyManager.NETWORK_TYPE_LTE
                    && !telephonyManager.isNetworkRoaming()) {
                return "4g";
            } else if (nSubType == TelephonyManager.NETWORK_TYPE_UMTS
                    || nSubType == TelephonyManager.NETWORK_TYPE_HSDPA
                    || nSubType == TelephonyManager.NETWORK_TYPE_EVDO_0
                    && !telephonyManager.isNetworkRoaming()) {
                return "3g";
                //2G 移动和联通的2G为GPRS或EGDE，电信的2G为CDMA
            } else if (nSubType == TelephonyManager.NETWORK_TYPE_GPRS
                    || nSubType == TelephonyManager.NETWORK_TYPE_EDGE
                    || nSubType == TelephonyManager.NETWORK_TYPE_CDMA
                    && !telephonyManager.isNetworkRoaming()) {
                return "2g";
            } else {
                return "2g";
            }
        }
        return "unknown";
    }

    public String getImsi() {
        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (PackageManager.PERMISSION_DENIED == ContextCompat.checkSelfPermission(AppActivity.getActivity(), Manifest.permission.READ_PHONE_STATE)) {
                return "PERMISSION_DENIED";
            }
        }
        String imsi = "";
        try {   //普通方法获取imsi
            TelephonyManager tm = (TelephonyManager)getSystemService(Context.TELEPHONY_SERVICE);
            imsi = tm.getSubscriberId();
            if (imsi==null || "".equals(imsi)) imsi = tm.getSimOperator();
            Class<?>[] resources = new Class<?>[] {int.class};
            Integer resourcesId = new Integer(1);
            if (imsi==null || "".equals(imsi)) {
                try {   //利用反射获取    MTK手机
                    Method addMethod = tm.getClass().getDeclaredMethod("getSubscriberIdGemini", resources);
                    addMethod.setAccessible(true);
                    imsi = (String) addMethod.invoke(tm, resourcesId);
                } catch (Exception e) {
                    imsi = null;
                }
            }
            if (imsi==null || "".equals(imsi)) {
                try {   //利用反射获取    展讯手机
                    Class<?> c = Class
                            .forName("com.android.internal.telephony.PhoneFactory");
                    Method m = c.getMethod("getServiceName", String.class, int.class);
                    String spreadTmService = (String) m.invoke(c, Context.TELEPHONY_SERVICE, 1);
                    TelephonyManager tm1 = (TelephonyManager)getSystemService(spreadTmService);
                    imsi = tm1.getSubscriberId();
                } catch (Exception e) {
                    imsi = null;
                }
            }
            if (imsi==null || "".equals(imsi)) {
                try {   //利用反射获取    高通手机
                    Method addMethod2 = tm.getClass().getDeclaredMethod("getSimSerialNumber", resources);
                    addMethod2.setAccessible(true);
                    imsi = (String) addMethod2.invoke(tm, resourcesId);
                } catch (Exception e) {
                    imsi = null;
                }
            }
            if (imsi==null || "".equals(imsi)) {
                imsi = "000000";
            }
            return imsi;
        } catch (Exception e) {
            return "000000";
        }
    }

    public static AppActivity getActivity() {
        return mAppActivity;
    }

    public static Handler getHandler() {
        return mHandler;
    }

    @TargetApi(Build.VERSION_CODES.M)
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        BluepayHelper.onRequestPermissionsResult(requestCode,permissions,grantResults);
        if(permissions.length > 0) {
            switch (requestCode) {
                case 1001: // request code define by me.
                    boolean isTip = shouldShowRequestPermissionRationale(permissions[0]);
                    if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                        if (isTip) {
                            // 用户没有彻底禁止弹出权限请求
//                        mAppActivity.requestPermissions(new String[]{Manifest.permission.READ_PHONE_STATE}, 1001);
                        } else {
                            // 用户已经彻底禁止弹出权限请求

                            // init Alert strings
                            final String fTitle = mAppActivity.getResources().getString(R.string.read_phone_state);
                            final String fconform = mAppActivity.getResources().getString(R.string.sure);
                            final String fcancel = mAppActivity.getResources().getString(R.string.cancel);

                            // on clicked handler
                            final DialogInterface.OnClickListener okHandler = new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    Intent intent = new Intent();
                                    intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                                    Uri uri = Uri.fromParts("package", getPackageName(), null);
                                    intent.setData(uri);
                                    startActivity(intent);
                                }
                            };

                            // new alert
                            mAppActivity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    new AlertDialog.Builder(mAppActivity)
                                            .setMessage(fTitle)
                                            .setPositiveButton(fconform, okHandler)
                                            .setNegativeButton(fcancel, null)
                                            .create()
                                            .show();
                                }
                            });
                        }
                    }
            }
        }
    }
}
