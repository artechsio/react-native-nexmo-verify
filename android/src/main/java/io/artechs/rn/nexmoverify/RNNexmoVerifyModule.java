
package io.artechs.rn.nexmoverify;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import com.nexmo.sdk.NexmoClient;
import com.nexmo.sdk.core.client.ClientBuilderException;
import com.nexmo.sdk.verify.client.VerifyClient;
import com.nexmo.sdk.verify.event.UserObject;
import com.nexmo.sdk.verify.event.VerifyClientListener;

import java.io.IOException;

public class RNNexmoVerifyModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private VerifyClient verifyClient;

  public RNNexmoVerifyModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNNexmoVerify";
  }

  @ReactMethod
  public void initialize(Promise promise) {

    Context context = getReactApplicationContext();
    try {
      NexmoClient nexmoClient = new NexmoClient.NexmoClientBuilder()
              .context(context)
              .applicationId(Config.AppId)
              .sharedSecretKey(Config.SharedSecretKey)
              .build();

      verifyClient = new VerifyClient(nexmoClient);


      promise.resolve("done");
    } catch (ClientBuilderException e) {
//      e.printStackTrace();
      promise.reject(e);
    }

  }

  @ReactMethod
  public void getVerifiedUser(String countryCode, String phoneNumber, final Callback verifyInProgressCallback, final Callback userVerifiedCallback, final Callback errorCallback) {
    verifyClient.getVerifiedUser(countryCode, phoneNumber);
    verifyClient.addVerifyListener(new VerifyClientListener() {
      @Override
      public void onVerifyInProgress(final VerifyClient verifyClient, UserObject user) {
        verifyInProgressCallback.invoke(user);
      }

      @Override
      public void onUserVerified(final VerifyClient verifyClient, UserObject user) {
        userVerifiedCallback.invoke(user);
      }

      @Override
      public void onError(final VerifyClient verifyClient, final com.nexmo.sdk.verify.event.VerifyError errorCode, UserObject user) {
        errorCallback.invoke("onError: " + errorCode);
      }

      @Override
      public void onException(final IOException exception) {
        errorCallback.invoke(exception);
      }
    });
  }

}