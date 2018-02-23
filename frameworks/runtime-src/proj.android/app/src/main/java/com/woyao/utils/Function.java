package com.woyao.utils;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AppOpsManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Environment;
import android.telephony.CellInfo;
import android.telephony.CellInfoCdma;
import android.telephony.CellInfoGsm;
import android.telephony.CellInfoLte;
import android.telephony.CellInfoWcdma;
import android.telephony.CellSignalStrength;
import android.telephony.CellSignalStrengthCdma;
import android.telephony.CellSignalStrengthGsm;
import android.telephony.CellSignalStrengthLte;
import android.telephony.TelephonyManager;
import android.util.Log;

import org.cocos2dx.lua.AppActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Calendar;
import java.util.UUID;


/**
 * Created by bearluo on 2017/6/8.
 */

public class Function {
    private static final String CHECK_OP_NO_THROW = "checkOpNoThrow";
    private static final String OP_POST_NOTIFICATION = "OP_POST_NOTIFICATION";
    @TargetApi(19)
    public static boolean isNotificationEnabled(Context context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            return true;
        }
        AppOpsManager mAppOps = (AppOpsManager) context.getApplicationContext().getSystemService(Context.APP_OPS_SERVICE);

        ApplicationInfo appInfo = context.getApplicationInfo();

        String pkg = context.getApplicationContext().getPackageName();

        int uid = appInfo.uid;

        Class appOpsClass = null; /* Context.APP_OPS_MANAGER */

        try {

            appOpsClass = Class.forName(AppOpsManager.class.getName());

            Method checkOpNoThrowMethod = appOpsClass.getMethod(CHECK_OP_NO_THROW, Integer.TYPE, Integer.TYPE, String.class);

            Field opPostNotificationValue = appOpsClass.getDeclaredField(OP_POST_NOTIFICATION);
            int value = (int)opPostNotificationValue.get(Integer.class);

            return ((int)checkOpNoThrowMethod.invoke(mAppOps,value, uid, pkg) == AppOpsManager.MODE_ALLOWED);

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static JSONObject getLoginCommentData(JSONObject jsonObject, Activity activity) {
        try {
            jsonObject.put("device_id",AppActivity.getActivity().getDeviceId());//设备id
            jsonObject.put("imsi",AppActivity.getActivity().getImsi());//设备imsi
            jsonObject.put("apn",AppActivity.getActivity().getAPNSting());//网络类型
            jsonObject.put("mac_address",AppActivity.getActivity().getMacAddress());//mac 地址
            jsonObject.put("system_model",android.os.Build.MODEL);//手机型号
            jsonObject.put("system_version",android.os.Build.VERSION.RELEASE);//手机系统版本
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject;
    }
    /*
    充电状态值
    int BATTERY_STATUS_CHARGING = 2	充电中
    int BATTERY_STATUS_DISCHARGING = 3	放电中
    int BATTERY_STATUS_NOT_CHARGING = 4	未充电
    int BATTERY_STATUS_FULL = 5	已充满
    int BATTERY_STATUS_UNKNOWN = 1	状态未知
    充电的方式
    int BATTERY_PLUGGED_AC = 1	使用充电器充电
    int BATTERY_PLUGGED_USB = 2	使用USB充电
    int BATTERY_PLUGGED_WIRELESS = 4	使用无线方式充电
     */

    public static int getBatterypercentage(Activity activity){
        JSONObject jsonObject = new JSONObject();
        IntentFilter filter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
        Intent batteryStatus = activity.registerReceiver(null, filter);
        int level = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1); //获取当前电量
        int scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1); //电量的总刻度
//        int status = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, BatteryManager.BATTERY_STATUS_UNKNOWN);//当前的充电状态
//        int plug = batteryStatus.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1);//当前的充电方式
        return (level*100)/scale;
    }

    /**
     *
     * @param activity
     * @return 0-4
     */
    public static int getWIFISignalStrength(Activity activity){
        WifiManager wifiManager = (WifiManager) activity.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        WifiInfo wifiInfo = wifiManager.getConnectionInfo();
        //获得信号强度值
        int numberOfLevels = 5;
        int level = WifiManager.calculateSignalLevel(wifiInfo.getRssi(), numberOfLevels);
        return level;
    }

    /**
     *
     * @param activity
     * @return 0-4
     */
    @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    public static int getTeleSignalStrength(Activity activity) {
        final Context context = activity.getApplicationContext();

        int level = 0;

        final TelephonyManager tm = (TelephonyManager) context.getApplicationContext().getSystemService(Context.TELEPHONY_SERVICE);
        for (final CellInfo info : tm.getAllCellInfo()) {
            if (info instanceof CellInfoGsm) {
                final CellSignalStrengthGsm gsm = ((CellInfoGsm) info).getCellSignalStrength();
                level = gsm.getLevel();
            } else if (info instanceof CellInfoCdma) {
                final CellSignalStrengthCdma cdma = ((CellInfoCdma) info).getCellSignalStrength();
                level = cdma.getLevel();
            } else if (info instanceof CellInfoLte) {
                final CellSignalStrengthLte lte = ((CellInfoLte) info).getCellSignalStrength();
                level = lte.getLevel();
            } else if (info instanceof CellInfoWcdma) {
                final CellSignalStrength wcdma = ((CellInfoWcdma) info).getCellSignalStrength();
                level = wcdma.getLevel();
            }
        }
        return level;
    }

    /**
     * 获取当前的网络状态 ：没有网络-0：WIFI网络1：4G网络-4：3G网络-3：2G网络-2
     * 自定义
     *
     * @param context
     * @return
     */
    public static int getAPNType(Context context) {
        //结果返回值
        int netType = 0;
        //获取手机所有连接管理对象
        ConnectivityManager manager = (ConnectivityManager) context.getApplicationContext().getSystemService(Context.CONNECTIVITY_SERVICE);
        //获取NetworkInfo对象
        NetworkInfo networkInfo = manager.getActiveNetworkInfo();
        //NetworkInfo对象为空 则代表没有网络
        if (networkInfo == null) {
            return netType;
        }
        //否则 NetworkInfo对象不为空 则获取该networkInfo的类型
        int nType = networkInfo.getType();
        if (nType == ConnectivityManager.TYPE_WIFI) {
            //WIFI
            netType = 1;
        } else if (nType == ConnectivityManager.TYPE_MOBILE) {
            int nSubType = networkInfo.getSubtype();
            TelephonyManager telephonyManager = (TelephonyManager) context.getApplicationContext().getSystemService(Context.TELEPHONY_SERVICE);
            //3G   联通的3G为UMTS或HSDPA 电信的3G为EVDO
            if (nSubType == TelephonyManager.NETWORK_TYPE_LTE
                    && !telephonyManager.isNetworkRoaming()) {
                netType = 4;
            } else if (nSubType == TelephonyManager.NETWORK_TYPE_UMTS
                    || nSubType == TelephonyManager.NETWORK_TYPE_HSDPA
                    || nSubType == TelephonyManager.NETWORK_TYPE_EVDO_0
                    && !telephonyManager.isNetworkRoaming()) {
                netType = 3;
                //2G 移动和联通的2G为GPRS或EGDE，电信的2G为CDMA
            } else if (nSubType == TelephonyManager.NETWORK_TYPE_GPRS
                    || nSubType == TelephonyManager.NETWORK_TYPE_EDGE
                    || nSubType == TelephonyManager.NETWORK_TYPE_CDMA
                    && !telephonyManager.isNetworkRoaming()) {
                netType = 2;
            } else {
                netType = 2;
            }
        }
        return netType;
    }

    public static String getUUID() {
        String key = "uuid";
        String fileName = ".androidWY";
        String path = AppActivity.getActivity().getPackageName();
        SharedPreferences sharedPreferences = AppActivity.getActivity().getSharedPreferences("UUID", Context.MODE_PRIVATE);
        String uuid1 = sharedPreferences.getString(key, null);
        String uuid2 = readFileToString(Environment.getExternalStorageDirectory().getAbsolutePath()+"/"+path,fileName);
        String uuid3 = readFileToString(Environment.getExternalStorageDirectory().getAbsolutePath(),fileName);
        String ret = null;

        if ( ret == null && uuid1 != null ) {
            ret = uuid1;
        }

        if ( ret == null && uuid2 != null ) {
            ret = uuid2;
        }

        if ( ret == null && uuid3 != null ) {
            ret = uuid3;
        }

        if( ret == null ) {
            ret = UUID.randomUUID().toString().replaceAll("-", "");
        }

        if( uuid1 == null || uuid1.compareTo(ret) != 0) {
            SharedPreferences.Editor editor = sharedPreferences.edit();
            editor.putString(key, ret);
            editor.commit();
        }

        if( uuid2 == null || uuid2.compareTo(ret) != 0) {
            saveStingToFile(ret,Environment.getExternalStorageDirectory().getAbsolutePath()+"/"+path,fileName);
        }

        if( uuid3 == null || uuid3.compareTo(ret) != 0) {
            saveStingToFile(ret,Environment.getExternalStorageDirectory().getAbsolutePath(),fileName);
        }
        return ret;
    }

    public static void saveStingToFile(String uuid,String parentPath,String fileName) {
        Log.e("uuid","parentPath="+parentPath);
        if( Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED) ) {
            StringBuffer path = new StringBuffer();
            path.append(parentPath);
            File file = new File(path.toString());
            if( !file.exists() ) {
                if(!file.mkdirs()) {
                    Log.e("lua android", "saveUUIDbyExternalStorageFiles fail 1");
                    return ;
                }
            }
            path.append("/");
            path.append(fileName);
            file = new File(path.toString());
            if ( !file.exists() ) {
                try {
                    if ( !file.createNewFile() ) {
                        Log.e("lua android", "saveUUIDbyExternalStorageFiles fail 2");
                        return ;
                    }
                } catch (IOException e) {
                    // TODO Auto-generated catch block
                    Log.e("lua android", "saveUUIDbyExternalStorageFiles fail 3 "+ e.toString());
                    return ;
                }
            }
            try {
                FileOutputStream fileOutputStream = new FileOutputStream(file);
                fileOutputStream.write(uuid.getBytes());
                fileOutputStream.flush();
                fileOutputStream.close();
            } catch (FileNotFoundException e) {
                // TODO Auto-generated catch block
                Log.e("lua android", "saveUUIDbyExternalStorageFiles FileOutputStream fail 4 "+ e.toString());
            } catch (IOException e) {
                // TODO Auto-generated catch block
                Log.e("lua android", "saveUUIDbyExternalStorageFiles FileOutputStream fail 5 "+ e.toString());
            }
        }
    }

    public static String readFileToString(String parentPath,String fileName) {
        Log.e("uuid","parentPath="+parentPath);
        String ret = null;
        if( Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED) ) {
            StringBuffer path = new StringBuffer();
            path.append(parentPath);
            File file = new File(path.toString());
            if( !file.exists() ) {
                Log.e("lua android", "readFileToString fail 1");
                return null;
            }
            path.append("/");
            path.append(fileName);
            file = new File(path.toString());
            if ( !file.exists() ) {
                Log.e("lua android", "readFileToString fail 2");
                return null;
            }
            try {
                FileInputStream fileInputStream = new FileInputStream(file);
                int lenght = fileInputStream.available();
                byte[] bs = new byte[lenght];
                fileInputStream.read(bs);
                ret = new String(bs);
            } catch (FileNotFoundException e) {
                // TODO Auto-generated catch block
                Log.e("lua android", "readFileToString FileInputStream fail 3 "+ e.toString());
            } catch (IOException e) {
                // TODO Auto-generated catch block
                Log.e("lua android", "readFileToString FileInputStream fail 4 "+ e.toString());
            }
        }
        return ret;
    }
}
