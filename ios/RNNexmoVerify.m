
#import "RNNexmoVerify.h"
#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"

@import VerifyIosSdk;

NSString *const AppId = @"f19d37a7-23e0-4efe-bbb2-9b0e2910a24f";
NSString *const SharedSecretKey = @"d5eb1a031942c37";
NSString *const ERROR_DOMAIN = @"Nexmo";


@implementation RNNexmoVerify

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (id)init {
    self = [super init];
    if (self) {
        [NexmoClient startWithApplicationId:AppId sharedSecretKey:SharedSecretKey];
        RCTLogInfo(@"debug: RNNexmo init.");
    }
    return self;
}

RCT_EXPORT_MODULE()

NSString *VerifyErrorToString(int error);

NSString *VerifyErrorToString(int error) {
    NSString *message = @"nothing";
    switch (error) {
        case 1: //
            message = @"INVALID_NUMBER";
            //                    let controller = UIAlertController(title: "Invalid
            //                    Phone Number", message: "The phone number you
            //                    entered is invalid.", preferredStyle: .Alert)
            //                    controller.addAction(action)
            //                    self.presentViewController(controller, animated:
            //                    true, completion: nil)
            break;
        case 2: // INVALID_PIN_CODE
            break;
            //                    let controller = UIAlertController(title: "Wrong Pin
            //                    Code", message: "The pin code you entered is
            //                    invalid.", preferredStyle: .Alert)
            //                    controller.addAction(action)
            //                    self.presentViewController(controller, animated: true,
            //                    completion: nil)
            //
            //                    self.pinTry++
            //
            //                    if (self.pinTry == 3) {
            //                        self.state = .TRYAGAIN
            //                    }
            
        case 3: // INVALID_CODE_TOO_MANY_TIMES:
            //                    let controller = UIAlertController(title: "Invalid
            //                    code too many times", message: "You have entered an
            //                    invalid code too many times, verification process
            //                    has stopped..", preferredStyle: .Alert)
            //                    controller.addAction(action)
            //                    self.presentViewController(controller, animated:
            //                    true, completion: nil)
            break;
        case 4: // INVALID_CREDENTIALS:
            //                    let controller = UIAlertController(title: "Invalid
            //                    Credentials", message: "Having trouble connecting to
            //                    your account. Please check your app key and
            //                    secret.", preferredStyle: .Alert)
            //                    controller.addAction(action)
            //                    self.presentViewController(controller, animated:
            //                    true, completion: nil)
            break;
        case 5: // USER_EXPIRED:
            //                    let controller = UIAlertController(title: "User
            //                    Expired", message: "Verification for current use
            //                    expired (usually due to timeout), please start
            //                    verification again.", preferredStyle: .Alert)
            //                    controller.addAction(action)
            //                    self.presentViewController(controller, animated:
            //                    true, completion: nil)
            break;
        case 6: // USER_BLACKLISTED:
            //                    let controller = UIAlertController(title: "User
            //                    Blacklisted", message: "Unable to verify this user
            //                    due to blacklisting!", preferredStyle: .Alert)
            //                    controller.addAction(action)
            //                    self.presentViewController(controller, animated:
            //                    true, completion: nil)
            break;
        case 7: // QUOTA_EXCEEDED:
            //                    let controller = UIAlertController(title: "Quota
            //                    Exceeded", message: "You do not have enough credit
            //                    to complete the verification.", preferredStyle:
            //                    .Alert)
            //                    controller.addAction(action)
            //                    self.presentViewController(controller, animated:
            //                    true, completion: nil)
            break;
        case 8: // SDK_REVISION_NOT_SUPPORTED:
            //                    let controller = UIAlertController(title: "SDK
            //                    Revision too old", message: "This SDK revision is
            //                    not supported anymore!", preferredStyle: .Alert)
            //                    controller.addAction(action)
            //                    self.presentViewController(controller, animated:
            //                    true, completion: nil)
            break;
        case 9: // OS_NOT_SUPPORTED:
            //                    let controller = UIAlertController(title: "iOS
            //                    version not supported", message: "This iOS version
            //                    is not supported", preferredStyle: .Alert)
            //                    controller.addAction(action)
            //                    self.presentViewController(controller, animated:
            //                    true, completion: nil)
            break;
        case 10: // NETWORK_ERROR:
            //                    let controller = UIAlertController(title: "Network
            //                    Error", message: "Having trouble accessing the
            //                    network.", preferredStyle: .Alert)
            //                    controller.addAction(action)
            //                    self.presentViewController(controller, animated:
            //                    true, completion: nil)
            break;
        case 11: // VERIFICATION_ALREADY_STARTED:
            //                    let controller = UIAlertController(title:
            //                    "Verification already started", message: "A
            //                    verification is already in progress!", preferredStyle:
            //                    .Alert)
            //                    controller.addAction(action)
            //                    self.presentViewController(controller, animated: true,
            //                    completion: nil)
            //
        default:
            break;
    }
    return message;
}

// Get Verified User
RCT_EXPORT_METHOD(getVerifiedUser
                  : (NSString *)countryCode phoneNumber
                  : (NSString *)phoneNumber userVerifiedCallback
                  : (RCTResponseSenderBlock)userVerifiedCallback errorCallback
                  : (RCTResponseSenderBlock)errorCallback) {
    
    [VerifyClient getVerifiedUserWithCountryCode:countryCode
                                     phoneNumber:phoneNumber
                           verifyInProgressBlock:^{
                               NSString *eventName = @"verification process begins.";
                               [self.bridge.eventDispatcher sendAppEventWithName:@"NexmoVerify"
                                                                            body:@{
                                                                                   @"name" : eventName
                                                                                   }];
                           }
                               userVerifiedBlock:^{
                                   userVerifiedCallback(@[ @"user has been successfully verified." ]);
                               }
                                      errorBlock:^(VerifyError serror) {
                                          
                                          errorCallback(@[ @"error occurs during verification." ]);
                                      }];
}

// Check PinCode
RCT_EXPORT_METHOD(checkPinCode : (NSString *)code) {
    [VerifyClient checkPinCode:code];
}

// Get User Status
RCT_EXPORT_METHOD(getUserStatus
                  : (NSString *)countryCode phoneNumber
                  : (NSString *)phoneNumber callback
                  : (RCTResponseSenderBlock)callback) {
    [VerifyClient
     getUserStatusWithCountryCode:countryCode
     WithNumber:phoneNumber
     WithBlock:^(NSString *status, NSError *error) {
         callback(@[ [NSNull null], status ]);
     }];
}

RCT_EXPORT_METHOD(getUserStatusPromise
                  : (NSString *)countryCode phoneNumber
                  : (NSString *)phoneNumber resolver
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    [VerifyClient
     getUserStatusWithCountryCode:countryCode
     WithNumber:phoneNumber
     WithBlock:^(NSString *status, NSError *error) {
         if (error != nil) {
             return reject(nil, @"unable to get user status",
                           error);
         }
         resolve(status);
         //        if ([status
         //        isEqualToString:UserStatus.USER_UNKNOWN]) {
         //            // user has never before been verified
         //        } else if ([status
         //        isEqualToString:UserStatus.USER_PENDING]) {
         //            // a verification request is currently
         //            in progress for this user
         //        }
         //        // other user statuses can be found in the
         //        UserStatus class
     }];
}

// Cancel Verification
RCT_EXPORT_METHOD(cancelVerification : (RCTResponseSenderBlock)callback) {
    [VerifyClient cancelVerificationWithBlock:^(NSError *error) {
        NSArray *args = @[];
        if (error == nil) {
            args = @[ [NSNull null] ];
        } else {
            args = @[ error ];
        }
        callback(args);
    }];
}

RCT_EXPORT_METHOD(cancelVerificationPromise
                  : resolver
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    [VerifyClient cancelVerificationWithBlock:^(NSError *error) {
        if (error != nil) {
            return reject(nil, @"something wen't wrong whilst attempting to cancel "
                          @"the current verification request",
                          error);
        }
        resolve(@"verification request successfully cancelled");
    }];
}

// Trigger Next Event
RCT_EXPORT_METHOD(triggerNextEvent : (RCTResponseSenderBlock)callback) {
    [VerifyClient triggerNextEventWithBlock:^(NSError *error) {
        callback(@[ error ]);
    }];
}

RCT_EXPORT_METHOD(triggerNextEventPromise
                  : resolver
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    [VerifyClient triggerNextEventWithBlock:^(NSError *error) {
        if (error != nil) {
            return reject(nil, @"unable to trigger next event", error);
        }
        resolve(@"successfully triggered next event");
    }];
}

// Logout User
RCT_EXPORT_METHOD(logoutUser
                  : (NSString *)countryCode phoneNumber
                  : (NSString *)phoneNumber callback
                  : (RCTResponseSenderBlock)callback) {
    [VerifyClient logoutUserWithCountryCode:countryCode
                                 WithNumber:phoneNumber
                                  WithBlock:^(NSError *error) {
                                      
                                      NSArray *args = @[];
                                      if (error == nil) {
                                          args = @[ [NSNull null] ];
                                      } else {
                                          args = @[ error.description ];
                                      }
                                      callback(args);
                                      
                                  }];
}

RCT_EXPORT_METHOD(logoutUserPromise
                  : (NSString *)countryCode phoneNumber
                  : (NSString *)phoneNumber resolver
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    [VerifyClient
     logoutUserWithCountryCode:countryCode
     WithNumber:phoneNumber
     WithBlock:^(NSError *error) {
         if (error != nil) {
             return reject(ERROR_DOMAIN, @"unable to logout user", error);
         }
         resolve(@"successfully logged out user");
     }];
}

// Verify Stand Alone
RCT_EXPORT_METHOD(verifyStandAlone
                  : (NSString *)countryCode phoneNumber
                  : (NSString *)phoneNumber userVerifiedCallback
                  : (RCTResponseSenderBlock)userVerifiedCallback errorCallback
                  : (RCTResponseSenderBlock)errorCallback) {
    [VerifyClient verifyStandaloneWithCountryCode:countryCode
                                      phoneNumber:phoneNumber
                            verifyInProgressBlock:^{
                                NSString *eventName = @"verification process begins.";
                                [self.bridge.eventDispatcher sendAppEventWithName:@"NexmoVerify"
                                                                             body:@{
                                                                                    @"name" : eventName
                                                                                    }];
                            }
                                userVerifiedBlock:^{
                                    userVerifiedCallback(@"userVerifiedCallback");
                                }
                                       errorBlock:^(VerifyError error) {
                                           errorCallback(@"error occurs during verification");
                                       }];
}

@end
