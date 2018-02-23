package com.woyao.bluepay;

import android.Manifest;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.bluepay.data.Config;
import com.bluepay.interfaceClass.BlueInitCallback;
import com.bluepay.pay.BlueMessage;
import com.bluepay.pay.BluePay;
import com.bluepay.pay.Client;
import com.bluepay.pay.IPayCallback;
import com.bluepay.pay.LoginResult;
import com.bluepay.pay.PublisherCode;
import com.woyao.luaevent.Contants;
import com.woyao.luaevent.LuaEventProxy;
import com.woyao.thai.poker.R;

import org.cocos2dx.lua.AppActivity;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by bearluo on 2017/12/18.
 */

public class BluepayHelper {
    public static String TAG = BluepayHelper.class.getSimpleName();
    protected static final int REQUEST_CODE_ASK_CALL_PHONE = 100026;
    public static BluePay mBluePay;
    private static AppActivity mActivity;
    private static boolean isInit = false;
    public static void init(final AppActivity activity) {
        mActivity = activity;
        mBluePay = BluePay.getInstance();
        //安卓6.0以上机型需要动态申请权限
		checkInit();
    }

    public static void onRequestPermissionsResult(int requestCode,
                  String[] permissions, int[] grantResults) {
        if (requestCode == REQUEST_CODE_ASK_CALL_PHONE) {
            for (int i = 0;i < permissions.length;i++) {
                String permission = permissions[i];
                if (permission.equals(Manifest.permission.READ_PHONE_STATE) && grantResults[i] == PackageManager.PERMISSION_GRANTED) {
                    initBlueSDK();
                }
                //
                if (permission.equals(Manifest.permission.SEND_SMS) && grantResults[i] == PackageManager.PERMISSION_GRANTED) {

                }
            }
        }
    }

    private static void initBlueSDK(){
        if(isInit) return ;
        isInit = true;
        Client.init(mActivity,new BlueInitCallback(){
            public void initComplete(String  loginResult, String  resultDesc) {
                String error = null;
                try {
                    if (loginResult.equals(LoginResult.LOGIN_SUCCESS)) {
                        BluePay.setLandscape(true);//设置BluePay的相关UI是否使用横屏UI
                        BluePay.setShowCardLoading(true);// 该方法设置使用cashcard时是否使用sdk的loading框
                        BluePay.setShowResult(true);// 设置是否使用支付结果展示窗
                        Log.e(TAG, "result: User Login Success!");
                    } else if (loginResult.equals(LoginResult.LOGIN_FAIL)) {
                        error = "User Login Failed!";
                        Log.e(TAG, "result: " + error);
                    } else {
                        StringBuilder sbStr = new StringBuilder(
                                "Fail! The code is:")
                                .append(loginResult)
                                .append(" desc is:").append(resultDesc);
                        error = sbStr.toString();
                        Log.e(TAG, "result: " + error);
                    }
                } catch (Exception e) {
                    error = e.getMessage();
                    Log.e(TAG, "result: " + error);
                }
                if (error != null) {
                    isInit = false;
                    Toast.makeText(mActivity, error, Toast.LENGTH_LONG).show();
                }
            }
        });
    }

    public static IPayCallback mIPayCallback = new IPayCallback(){
        @Override
        public void onFinished(BlueMessage msg) {
            Log.e(TAG, " message:" + msg.getDesc() + " code :" + msg.getCode()
                    + " prop's name:" + msg.getPropsName());
            String message = "result code:" + msg.getCode() + " message:"
                    + msg.getDesc() + " code :" + msg.getCode() + "   price:"
                    + msg.getPrice() + " Payment channel:" + msg.getPublisher();

            if (!TextUtils.isEmpty(msg.getOfflinePaymentCode())) {// offline
                // payment
                // code
                // 不为空，说明这个是印尼的offline，可以展示paymentCode给用户
                message += ", " + msg.getOfflinePaymentCode()
                        + ". please go to " + msg.getPublisher()
                        + " to finish this payment";
            }
            String title = "";
            if (msg.getCode() == 200) {
                // 计费成功
                title = "Success";
                try {
                    JSONObject info = new JSONObject();
                    info.put("ret", Contants.ret.success);
                    LuaEventProxy.getInstance().dispatchEvent(com.woyao.luaevent.Contants.bluepayCallback,info.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else if(msg.getCode() == 201) {
                //代表请求成功,计费还未完成
                title = "Request success,in progressing...";
                try {
                    JSONObject info = new JSONObject();
                    info.put("ret", Contants.ret.success);
                    LuaEventProxy.getInstance().dispatchEvent(com.woyao.luaevent.Contants.bluepayCallback,info.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else if (msg.getCode() == 603) {
                // 用户取消
                title = "User cancel";
                try {
                    JSONObject info = new JSONObject();
                    info.put("ret", Contants.ret.cancel);
                    LuaEventProxy.getInstance().dispatchEvent(com.woyao.luaevent.Contants.bluepayCallback,info.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {
                //请求失败
                title = "Fail";
                try {
                    JSONObject info = new JSONObject();
                    info.put("ret", Contants.ret.fail);
                    LuaEventProxy.getInstance().dispatchEvent(com.woyao.luaevent.Contants.bluepayCallback,info.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
            Log.i(TAG, "title:"+title);
            Log.i(TAG, "message:"+message);
//            AlertDialog dialog = new AlertDialog.Builder(mActivity)
//                    .create();
//            dialog.setTitle(title);
//            dialog.setMessage(message);
//            dialog.setButton(DialogInterface.BUTTON_POSITIVE, "OK",
//                    new DialogInterface.OnClickListener() {
//
//                        @Override
//                        public void onClick(DialogInterface dialog, int which) {
//
//                        }
//                    });
//            dialog.show();
        }

        /**
         * 特别关注！！！payByUI接口的交易id由这里生成
         * 如果使用了payByUI接口，需要在这里生成交易id并返回，这将用于payByUI中的每笔交易
         * 如果没有使用payByUI接口可直接返回null
         */
        @Override
        public String onPrepared() {
            //在这里生成交易id，payByUI中每笔交易id将从这里获取
            return null;
        }
    };

    public static boolean checkInit() {
        if (isInit) return isInit;
        if (Build.VERSION.SDK_INT >= 23) {// 如果是android 6.0 需要特殊处理
            int readPhoneState = mActivity.checkSelfPermission(Manifest.permission.READ_PHONE_STATE);
            if (readPhoneState != PackageManager.PERMISSION_GRANTED
                    ) {
                // 如果没有授权，则初始化的代码放在授权成功那里。否则会初始化失败。
                mActivity.requestPermissions(new String[] {
                                Manifest.permission.READ_PHONE_STATE},
                        REQUEST_CODE_ASK_CALL_PHONE);
            } else{
                initBlueSDK();
                return true;
            }
        }else {
            initBlueSDK();
            return true;
        }
        return false;
    }

    public static void payBySMS(String transactionId, String price, int smsId, String propsName) {
        if (!checkInit()) return ;
        int sendSms = mActivity.checkSelfPermission(Manifest.permission.SEND_SMS);
        if( sendSms != PackageManager.PERMISSION_GRANTED)
        {
            // 如果没有授权，短代会计费失败，请主动请求权限
            mActivity.requestPermissions(new String[] {
                            Manifest.permission.SEND_SMS },
                    REQUEST_CODE_ASK_CALL_PHONE);
            return;
        }
        String currency = mActivity.getResources().getString(R.string.blue_pay_currency);
        mBluePay.payBySMSV2(mActivity, transactionId,
                currency, price, smsId, propsName, null, true,
                mIPayCallback);
    }

    public static void payByCashcard(String userID, String transactionId, String propsName,String publisherCode) {
        if (!checkInit()) return ;
        BluePay.setShowCardLoading(true);
        mBluePay.payByCashcard(mActivity, userID,
                transactionId, propsName,
                publisherCode, null, null, mIPayCallback);
    }

    public static void payByWallet(String userID, String transactionId, String price, String propsName){
        if (!checkInit()) return ;
        String currency = mActivity.getResources().getString(R.string.blue_pay_currency);
        String scheme = mActivity.getResources().getString(R.string.blue_pay_scheme);
        String host = mActivity.getResources().getString(R.string.blue_pay_host);
        mBluePay.payByWallet(mActivity, userID, transactionId,
                currency, price, propsName,
                PublisherCode.PUBLISHER_LINE,
                String.format("%s://%s",scheme,host), true, mIPayCallback);
    }
}
