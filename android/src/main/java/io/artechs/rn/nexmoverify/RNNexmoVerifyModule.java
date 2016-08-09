
package io.artechs.rn.nexmoverify;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.support.annotation.Nullable;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.nexmo.sdk.NexmoClient;
import com.nexmo.sdk.core.client.ClientBuilderException;
import com.nexmo.sdk.verify.client.VerifyClient;
import com.nexmo.sdk.verify.event.Command;
import com.nexmo.sdk.verify.event.CommandListener;
import com.nexmo.sdk.verify.event.SearchListener;
import com.nexmo.sdk.verify.event.UserObject;
import com.nexmo.sdk.verify.event.UserStatus;
import com.nexmo.sdk.verify.event.VerifyClientListener;
import com.nexmo.sdk.verify.event.VerifyError;

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
  public void initialize() {

    Context context = getReactApplicationContext();
    try {

      NexmoClient nexmoClient = new NexmoClient.NexmoClientBuilder()
              .context(getReactApplicationContext())
              .applicationId(Config.AppId)
              .sharedSecretKey(Config.SharedSecretKey)
              .build();

      verifyClient = new VerifyClient(nexmoClient);

//      promise.resolve("done");
    } catch (ClientBuilderException e) {
//      e.printStackTrace();
//      promise.reject(e);
    }

  }

  private void sendEvent(ReactContext reactContext, String eventName, Object params) {
    reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(eventName, params);
  }

  @ReactMethod
  public void getVerifiedUser(String countryCode, String phoneNumber, final Callback userVerifiedCallback, final Callback errorCallback) {
    verifyClient.getVerifiedUser(countryCode, phoneNumber);
    verifyClient.addVerifyListener(new VerifyClientListener() {


      @Override
      public void onVerifyInProgress(final VerifyClient verifyClient, UserObject user) {

          Log.d("onVerifyInProgress ", "onVerifyInProgress: ");
        final WritableMap params = Arguments.createMap();
        params.putString("name", "verification process begins.");


        sendEvent(reactContext, "NexmoVerify", params);

      }

      @Override
      public void onUserVerified(final VerifyClient verifyClient, UserObject user) {
        userVerifiedCallback.invoke("onUserVerified: " + user);
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

  //Check PinCode
  @ReactMethod
  public void checkPinCode(String code) {
    verifyClient.checkPinCode(code);
  }


  // Get User Status with callback function
  @ReactMethod
  public void getUserStatus(String countryCode , String phoneNumber, final Callback callback){

    verifyClient.getUserStatus(countryCode , phoneNumber, new SearchListener() {
      @Override
      public void onUserStatus(UserStatus userStatus) {
        switch(userStatus){
          case USER_PENDING:{
            // Handle each userStatus accordingly.
            callback.invoke("userStatus: " +userStatus);
          }
        }
        // other user statuses can be found in the UserStatus class
      }

      @Override
      public void onError(VerifyError errorCode, String errorMessage) {
        // unable to get user status for given device + phone number pair
        callback.invoke("onError: " + errorMessage);
      }

      @Override
      public void onException(IOException e) {
        callback.invoke("onError: " + e);
      }
    });
  }

  // Get User Status with promise function
  @ReactMethod
  public void getUserStatusPromise(String countryCode , String phoneNumber, final Promise promise){

    verifyClient.getUserStatus(countryCode , phoneNumber, new SearchListener() {
      @Override
      public void onUserStatus(UserStatus userStatus) {
        switch(userStatus){
          case USER_PENDING:{
            // Handle each userStatus accordingly.
            promise.resolve("userStatus: " + userStatus);
          }
        }
        // other user statuses can be found in the UserStatus class
      }

      @Override
      public void onError(VerifyError errorCode, String errorMessage) {
        // unable to get user status for given device + phone number pair
        promise.reject("errorMessage: " + errorMessage);
      }

      @Override
      public void onException(IOException e) {
        promise.reject("errorMessage: " + e);
      }
    });
  }

  // Cancel Verification with callback function
  @ReactMethod
  public void cancelVerification(String countryCode, String phoneNumber , final Callback callback){
    verifyClient.command(countryCode, phoneNumber, Command.LOGOUT, new CommandListener() {
      @Override
      public void onSuccess(Command command) {
        // verification request successfully cancelled
        callback.invoke("verification request successfully cancelled: " + command);
      }

      @Override
      public void onError(Command command, com.nexmo.sdk.verify.event.VerifyError verifyError, String s) {
        // something went wrong whilst attempting to cancel the current verification request
        callback.invoke("something went wrong whilst attempting to cancel the current verification request: " + verifyError);
      }

      @Override
      public void onException(IOException e) {
        callback.invoke("something went wrong whilst attempting to cancel the current verification request: " + e);
      }
    });
  }

  // Cancel Verification with Promise function
  @ReactMethod
  public void cancelVerificationPromise(String countryCode, String phoneNumber, final Promise promise){
    verifyClient.command(countryCode, phoneNumber, Command.LOGOUT, new CommandListener() {
      @Override
      public void onSuccess(Command command) {
        // verification request successfully cancelled
        promise.resolve("verification request successfully cancelled: " + command);
      }

      @Override
      public void onError(Command command, com.nexmo.sdk.verify.event.VerifyError verifyError, String s) {
        // something went wrong whilst attempting to cancel the current verification request
        promise.reject("something went wrong whilst attempting to cancel the current verification request: " + verifyError);
      }

      @Override
      public void onException(IOException e) {
        promise.reject("something went wrong whilst attempting to cancel the current verification request: " + e);
      }
    });
  }

  // Trigger Next Event with Callback function
  @ReactMethod
  public void triggerNextEvent(String countryCode, String phoneNumber, final Callback callback){
    verifyClient.command(countryCode, phoneNumber, Command.TRIGGER_NEXT_EVENT, new CommandListener() {
      @Override
      public void onSuccess(Command command) {
        // successfully triggered next event
        callback.invoke("successfully triggered next event: " + command);
      }

      @Override
      public void onError(Command command, com.nexmo.sdk.verify.event.VerifyError verifyError, String s) {
        // unable to trigger next event
        callback.invoke("unable to trigger next event: " + verifyError);
      }

      @Override
      public void onException(IOException e) {
        callback.invoke("unable to trigger next event: " + e);

      }
    });
  }

  // Trigger Next Event with Promise function
  @ReactMethod
  public void triggerNextEventPromise(String countryCode, String phoneNumber, final Promise promise){
    verifyClient.command(countryCode, phoneNumber, Command.TRIGGER_NEXT_EVENT, new CommandListener() {
      @Override
      public void onSuccess(Command command) {
        // successfully triggered next event
        promise.resolve("successfully triggered next event: " + command);
      }

      @Override
      public void onError(Command command, com.nexmo.sdk.verify.event.VerifyError verifyError, String s) {
        // unable to trigger next event
        promise.reject("unable to trigger next event: " + verifyError);
      }

      @Override
      public void onException(IOException e) {
        promise.reject("unable to trigger next event: " + e);

      }
    });
  }

  //Logout User with Callback function
  @ReactMethod
  public void logoutUser(String countryCode, String phoneNumber, final Callback callback){
    verifyClient.command(countryCode, phoneNumber, Command.LOGOUT, new CommandListener() {
      @Override
      public void onSuccess(Command command) {
        // successfully logged out user
        callback.invoke("successfully logged out user: " + command);
      }

      @Override
      public void onError(Command command, com.nexmo.sdk.verify.event.VerifyError verifyError, String s) {
        // unable to logout user
        callback.invoke("unable to logout user: " + verifyError);
      }

      @Override
      public void onException(IOException e) {
        callback.invoke("unable to logout user: " + e);
      }
    });
  }

  //Logout User with Promise function
  @ReactMethod
  public void logoutUserPromise(String countryCode, String phoneNumber, final Promise promise){
    verifyClient.command(countryCode, phoneNumber, Command.LOGOUT, new CommandListener() {
      @Override
      public void onSuccess(Command command) {
        // successfully logged out user
        promise.resolve("successfully logged out user: " + command);
      }

      @Override
      public void onError(Command command, com.nexmo.sdk.verify.event.VerifyError verifyError, String s) {
        // unable to logout user
        promise.reject("unable to logout user: " + verifyError);
      }

      @Override
      public void onException(IOException e) {
        promise.reject("unable to logout user: " + e);
      }
    });
  }

  // Verify Stand Alone
  @ReactMethod
  public void verifyStandAlone(String countryCode, String phoneNumber){
    verifyClient.verifyStandalone(countryCode, phoneNumber);
  }

  //Verify using the managed ux
  @ReactMethod
  public void getVerifiedUserFromDefaultManagedUI(){
    verifyClient.getVerifiedUserFromDefaultManagedUI();
  }
}
