package com.woyao.gpay;


import android.content.Intent;
import android.util.Log;
import android.widget.Toast;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.json.JSONException;
import org.json.JSONObject;

import com.woyao.luaevent.*;


/**
 * Created by shineflag on 2017/6/2.
 */

public class GPayLuaCall {

    static Cocos2dxActivity mContext = null;

    static final String TAG = "GpayLuaCall";

    
    // (arbitrary) request code for the  google pay purchase flow
    static final int RC_REQUEST = 10001;

    // The helper object
    static IabHelper mHelper;

    // Provides purchase notification while this app is running
    static IabBroadcastReceiver mBroadcastReceiver;

	// Listener that's called when we finish querying the items and subscriptions we own
    static IabHelper.QueryInventoryFinishedListener mGotInventoryListener;

     // Callback for when a purchase is finished
    static IabHelper.OnIabPurchaseFinishedListener mPurchaseFinishedListener;

    // Called when consumption is complete
    static IabHelper.OnConsumeFinishedListener mConsumeFinishedListener;

    public static void init(Cocos2dxActivity context) {
        mContext = context;
        String base64EncodedPublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApykJrFrV83aMI4wj0PRSd34sXFlD5GNA88LU5RPRdzMfflEwioymHqwC620yOkFALw1a4kTAj/nj8F0w72M5CTnSWNTGlscSB37ghPrRH+0Lev4zD/dlsL+KJagcCCLwg3l9ehQm79F4bRmc8ZHLr8Io/PXB1oSjJk+7sVjVP3XSbii0GHjgddik1lPuBixzQ9POeAztZLloDmENlMizT5cYsgTfOGTLYsz4qlOOHxXhufcrfptfxxDWNYLzIS0blqlu6chgbFZS7bVSsOQJF8wvihyR2ofrWDqWui24/cXhDxC24VWv3oP/d+TaWChe90FwS1I62ILZ/bHSkCs7FwIDAQAB";
		mGotInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
	        public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
	            Log.d(TAG, "Query inventory finished.");
	            // Have we been disposed of in the meantime? If so, quit.
	            if (mHelper == null) return;

	            // Is it a failure?
	            if (result.isFailure()) {
	                //complain("Failed to query inventory: " + result);
	                return;
	            }

	            Log.d(TAG, "Query inventory was successful.");

	            /*
	             * Check for items we own. Notice that for each purchase, we check
	             * the developer payload to see if it's correct! See
	             * verifyDeveloperPayload().
	             */
	            // Check for gas delivery -- if we own gas, we should fill up the tank immediately

                for(Purchase puc : inventory.getAllPurchases()){
                    Log.d(TAG, "We have coin. Consuming it:" + puc.getSku());
                    try {
                        mHelper.consumeAsync(puc, mConsumeFinishedListener);
                    } catch (IabHelper.IabAsyncInProgressException e) {
                       // complain("Error consuming gas. Another async operation in progress.");
                    }
                    return;
                }



	          	//updateUi();
	            Log.d(TAG, "Initial inventory query finished; enabling main UI.");
	        }
	    };


		mPurchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener() {
		        public void onIabPurchaseFinished(IabResult result, Purchase purchase) {
		            Log.d(TAG, "Purchase finished: " + result + ", purchase: " + purchase);

		            // if we were disposed of in the meantime, quit.
		            if (mHelper == null) return;

		            if (result.isFailure() ) {
		                //complain("Error purchasing: " + result);
		                //setWaitScreen(false);

                        if( result.getResponse() != IabHelper.BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED ){

                        }
		                return;
		            }

		            Log.d(TAG, "Purchase successful sku :" + purchase.getSku());

		
	                try {
	                    mHelper.consumeAsync(purchase, mConsumeFinishedListener);
	                } catch (IabHelper.IabAsyncInProgressException e) {
	                    //complain("Error consuming gas. Another async operation in progress.");
	                    //setWaitScreen(false);
	                    return;
	                }

		        }
		    };

	    mConsumeFinishedListener = new IabHelper.OnConsumeFinishedListener() {
	        public void onConsumeFinished(Purchase purchase, IabResult result) {
	            Log.d(TAG, "Consumption finished. Purchase: " + purchase + ", result: " + result);

	            // if we were disposed of in the meantime, quit.
	            if (mHelper == null) return;

	            // We know this is the "gas" sku because it's the only one we consume,
	            // so we don't check which sku was consumed. If you have more than one
	            // sku, you probably should check...
	            if (result.isSuccess()) {
	                // successfully consumed, so we apply the effects of the item in our
	                // game world's logic, which in our case means filling the gas tank a bit
	                Log.d(TAG, "Consumption successful. Provisioning.");

                    //消费成功就向服务器请求发货
                    try {
                        JSONObject info = new JSONObject();
                        info.put("gorderid",purchase.getOrderId());
                        info.put("purdata",purchase.getOriginalJson());
                        info.put("signature",purchase.getSignature());
                        info.put("orderid", purchase.getDeveloperPayload());
                        info.put("pid",purchase.getSku());
                        LuaEventProxy.getInstance().dispatchEvent(com.woyao.luaevent.Contants.gpayConsume,info.toString());
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

	            } else {
	            	Log.d(TAG,"Error while consuming: " + result);
	                //complain("Error while consuming: " + result);
	            }
	            Log.d(TAG, "End consumption flow.");
	        }
	    };

        mHelper = new IabHelper(context, base64EncodedPublicKey);
        // enable debug logging (for a production application, you should set this to false).
        mHelper.enableDebugLogging(true);

        mHelper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
            public void onIabSetupFinished(IabResult result) {
                Log.d(TAG, "Setup finished.");

                if (!result.isSuccess()) {
                    // Oh noes, there was a problem.
                   //complain("Problem setting up in-app billing: " + result);
					Log.e(TAG,"Problem setting up in-app billing: " + result);
                    return;
                }

                // Have we been disposed of in the meantime? If so, quit.
                if (mHelper == null) return;

                // IAB is fully set up. Now, let's get an inventory of stuff we own.
                Log.d(TAG, "Setup successful. Querying inventory.");
                try {
                    mHelper.queryInventoryAsync(mGotInventoryListener); //查询目前拥有的商品
                } catch (IabHelper.IabAsyncInProgressException e) {
                    //complain("Error querying inventory. Another async operation in progress.");
                }
            }
        });

    }


        /** Verifies the developer payload of a purchase. */
    static boolean verifyDeveloperPayload(Purchase p) {
        String payload = p.getDeveloperPayload();

        /*
         * TODO: verify that the developer payload of the purchase is correct. It will be
         * the same one that you sent when initiating the purchase.
         *
         * WARNING: Locally generating a random string when starting a purchase and
         * verifying it here might seem like a good approach, but this will fail in the
         * case where the user purchases an item on one device and then uses your app on
         * a different device, because on the other device you will not have access to the
         * random string you originally generated.
         *
         * So a good developer payload has these characteristics:
         *
         * 1. If two different users purchase an item, the payload is different between them,
         *    so that one user's purchase can't be replayed to another user.
         *
         * 2. The payload must be such that you can verify it even when the app wasn't the
         *    one who initiated the purchase flow (so that items purchased by the user on
         *    one device work on other devices owned by the user).
         *
         * Using your own server to store and verify developer payloads across app
         * installations is recommended.
         */

        return true;
    }


    public static boolean handleActivityResult(int requestCode, int resultCode, Intent data){
    	return mHelper.handleActivityResult(requestCode, resultCode, data);
    }

    /**
    * 购买商品 
    * @param sku:商品id  
    * @param orderid:订单号
    */
    public static void Purchase(final String sku, final String orderid){


        /* TODO: for security, generate your payload here for verification. See the comments on
         *        verifyDeveloperPayload() for more info. Since this is a SAMPLE, we just use
         *        an empty string, but on a production app you should carefully generate this. */

        Log.d(TAG, "Buy  pid " + sku);

        mContext.runOnUiThread(new Runnable() {

            @Override
            public void run() {

                try {
                    mHelper.launchPurchaseFlow(mContext, sku, RC_REQUEST,mPurchaseFinishedListener, orderid);
                } catch (IabHelper.IabAsyncInProgressException e) {
                    e.printStackTrace();
                    Log.d(TAG, "pay failed " + e.getMessage());
                    showToast("pay failed!");
                } catch (Exception e) {
                    e.printStackTrace();
                    Log.d(TAG, "pay failed " + e.getMessage());
                    showToast("pay failed!");
                }
            }
        });

    }

    public static void showToast( String msg){
        Toast.makeText(mContext, msg,
                Toast.LENGTH_SHORT).show();
    }

    public static void onDestroy(){

		// very important:
        Log.d(TAG, "Destroying helper.");
        if (mHelper != null) {
            mHelper.disposeWhenFinished();
            mHelper = null;
        }
    }
}
