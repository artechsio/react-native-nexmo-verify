
package io.artechs.rn.nexmoverify;

import android.content.Context;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import com.nexmo.sdk.NexmoClient;
import com.nexmo.sdk.core.client.ClientBuilderException;
import com.nexmo.sdk.verify.client.VerifyClient;

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
}