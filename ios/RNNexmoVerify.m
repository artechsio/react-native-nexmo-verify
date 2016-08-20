
#import "RNNexmoVerify.h"
#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"

@import VerifyIosSdk;

NSString *const AppId = @"92e4e8ca-cff8-46f1-9b27-4990024a86e1";
NSString *const SharedSecretKey = @"7966579094f60b8";
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
    }
    return self;
}

RCT_EXPORT_MODULE()

NSString *getNSError(VerifyError error) {
    
    int errorCode = 0;
    NSString *errorDescription = @"Operation was unsuccessful.";
    NSString *errorMessage = @"Operation Was Unsuccessful.";
    NSString *errorDomain = @"OPERATION_WAS_UNSUCCESSFUL";
    
    switch (error) {
        case 1:
            errorCode = 1;
            errorDomain = @"INVALID_NUMBER";
            errorMessage = @"Invalid Phone Number";
            errorDescription = @"The phone number you entered is invalid.";
            break;
        case 2:
            errorCode = 2;
            errorDomain = @"INVALID_PIN_CODE";
            errorMessage = @"Wrong Pin Code";
            errorDescription = @"The pin code you entered is invalid.";
            break;
        case 3:
            errorCode = 3;
            errorDomain = @"INVALID_CODE_TOO_MANY_TIMES";
            errorMessage = @"Invalid code too many time";
            errorDescription = @"You have entered an invalid code too many times, verification process has stopped..";
            break;
        case 4:
            errorCode = 4;
            errorDomain = @"INVALID_CREDENTIALS";
            errorMessage = @"Invalid Credentials";
            errorDescription = @"Having trouble connecting to your account. Please check your app key and secret.";
            break;
        case 5:
            errorCode = 5;
            errorDomain = @"USER_EXPIRED";
            errorMessage = @"Invalid Credentials";
            errorDescription = @"Verification for current use expired (usually due to timeout), please start verification again.";
            break;
        case 6:
            errorCode = 6;
            errorDomain = @"USER_BLACKLISTED";
            errorMessage = @"User Blacklisted";
            errorDescription = @"Unable to verify this user due to blacklisting!";
            break;
        case 7:
            errorCode = 7;
            errorDomain = @"QUOTA_EXCEEDED";
            errorMessage = @"Quota Exceeded";
            errorDescription = @"You do not have enough credit to complete the verification.";
            break;
        case 8:
            errorCode = 8;
            errorDomain = @"SDK_REVISION_NOT_SUPPORTED";
            errorMessage = @"SDK Revision too old";
            errorDescription = @"This SDK revision is Revision too old";
            break;
        case 9:
            errorCode = 9;
            errorDomain = @"OS_NOT_SUPPORTED";
            errorMessage = @"iOS version not supported";
            errorDescription = @"This iOS version is not supported";
            break;
        case 10: // :
            errorCode = 10;
            errorDomain = @"NETWORK_ERROR";
            errorMessage = @"Network Error";
            errorDescription = @"Having trouble accessing the network";
            break;
        case 11: // :
            errorCode = 11;
            errorDomain = @"VERIFICATION_ALREADY_STARTED";
            errorMessage = @"Verification already started";
            errorDescription = @"A verification is already in progress!";
            break;
        default:
            break;
    }
    
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(errorDescription, nil), NSLocalizedFailureReasonErrorKey: NSLocalizedString(errorMessage, nil)};
    NSError *nserror = [NSError errorWithDomain:errorDomain code:errorCode userInfo:userInfo];
    return nserror;
}

// Get Verified User
RCT_EXPORT_METHOD(getVerifiedUser:(NSString *)countryCode
                  phoneNumber:(NSString *)phoneNumber
                  userVerifiedCallback:(RCTResponseSenderBlock)userVerifiedCallback
                  errorCallback:(RCTResponseSenderBlock)errorCallback)
{
    
    [VerifyClient
     getVerifiedUserWithCountryCode:countryCode
     phoneNumber:phoneNumber
     verifyInProgressBlock:^{
         NSString *eventName = @"verification process begins.";
         [self.bridge.eventDispatcher sendAppEventWithName:@"NexmoVerify" body:@{@"name": eventName}];
     }
     userVerifiedBlock:^{
         userVerifiedCallback(@[@"user has been successfully verified."]);
     }
     errorBlock:^(VerifyError error) {
         NSError *e = getNSError(error);
         errorCallback(@[e.userInfo]);
     }];
}


// Get Verified User
RCT_EXPORT_METHOD(getVerifiedUserPromise:(NSString *)countryCode
                  phoneNumber:(NSString *)phoneNumber
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [VerifyClient
     getVerifiedUserWithCountryCode:countryCode
     phoneNumber:phoneNumber
     verifyInProgressBlock:^{
         NSString *eventName = @"verification process begins.";
         [self.bridge.eventDispatcher sendAppEventWithName:@"NexmoVerify" body:@{@"name": eventName}];
     }
     userVerifiedBlock:^{
         resolve(@"user has been successfully verified.");
     }
     errorBlock:^(VerifyError error) {
          NSError *e = getNSError(error);
         return reject(ERROR_DOMAIN, @"Unable to get user status", e.userInfo);
     }];
}



// Check PinCode
RCT_EXPORT_METHOD(checkPinCode:(NSString *)code)
{
    [VerifyClient checkPinCode:code];
}

// Get User Status
RCT_EXPORT_METHOD(getUserStatus:(NSString *)countryCode
                  phoneNumber:(NSString *)phoneNumber
                  successCallback:(RCTResponseSenderBlock)successCallback
                  errorCallback:(RCTResponseSenderBlock)errorCallback)
{
    [VerifyClient
     getUserStatusWithCountryCode:countryCode
     WithNumber:phoneNumber
     WithBlock:^(NSString *status, NSError *error) {
         if (error != nil) {
             return errorCallback(@[error.userInfo]);
         }
         successCallback(@[status]);
     }];
}

RCT_EXPORT_METHOD(getUserStatusPromise:(NSString *)countryCode
                  phoneNumber:(NSString *)phoneNumber
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [VerifyClient
     getUserStatusWithCountryCode:countryCode
     WithNumber:phoneNumber
     WithBlock:^(NSString *status, NSError *error) {
         if (error != nil) {
             return reject(ERROR_DOMAIN, @"Unable to get user status", error.userInfo);
         }
         resolve(status);
     }];
}

// Cancel Verification
RCT_EXPORT_METHOD(cancelVerification:(NSString *)countryCode
                  phoneNumber:(NSString *)phoneNumber
                  callback:(RCTResponseSenderBlock)callback)
{
    [VerifyClient
     cancelVerificationWithBlock:^(NSError *error) {
         NSArray *args = @[];
         if (error == nil) {
             args = @[[NSNull null]];
         } else {
             args = @[error.userInfo];
         }
         callback(args);
     }];
}

RCT_EXPORT_METHOD(cancelVerificationPromise:(NSString *)countryCode
                  phoneNumber:(NSString *)phoneNumber
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [VerifyClient cancelVerificationWithBlock:^(NSError *error) {
        if (error != nil) {
            return reject(nil, nil, error.userInfo);
        }
        resolve(@"verification request successfully cancelled");
    }];
}

// Trigger Next Event
RCT_EXPORT_METHOD(triggerNextEvent:(NSString *)countryCode
                  phoneNumber:(NSString *)phoneNumber
                  callback:(RCTResponseSenderBlock)callback)
{
    [VerifyClient
     triggerNextEventWithBlock:^(NSError *error) {
         NSArray *args = @[];
         if (error == nil) {
             args = @[ [NSNull null] ];
         } else {
             args = @[ error.userInfo ];
         }
         callback(args);
     }];
}

RCT_EXPORT_METHOD(triggerNextEventPromise:(NSString *)countryCode
                  phoneNumber:(NSString *)phoneNumber
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [VerifyClient triggerNextEventWithBlock:^(NSError *error) {
        if (error != nil) {
            return reject(ERROR_DOMAIN, @"unable to trigger next event", error);
        }
        resolve(@"successfully triggered next event");
    }];
}

// Logout User
RCT_EXPORT_METHOD(logoutUser:(NSString *)countryCode
                  phoneNumber:(NSString *)phoneNumber
                  callback:(RCTResponseSenderBlock)callback)
{
    [VerifyClient
     logoutUserWithCountryCode:countryCode
     WithNumber:phoneNumber
     WithBlock:^(NSError *error) {
         NSArray *args = @[];
         if (error == nil) {
             args = @[ [NSNull null] ];
         } else {
             args = @[ error.userInfo ];
         }
         callback(args);
     }];
}

RCT_EXPORT_METHOD(logoutUserPromise:(NSString *)countryCode
                  phoneNumber:(NSString *)phoneNumber
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [VerifyClient
     logoutUserWithCountryCode:countryCode
     WithNumber:phoneNumber
     WithBlock:^(NSError *error) {
         if (error != nil) {
             return reject(ERROR_DOMAIN, @"unable to logout user", error.userInfo);
         }
         resolve(@"successfully logged out user");
     }];
}

// Verify Stand Alone
RCT_EXPORT_METHOD(verifyStandAlone:(NSString *)countryCode
                  phoneNumber:(NSString *)phoneNumber
                  userVerifiedCallback:(RCTResponseSenderBlock)userVerifiedCallback
                  errorCallback:(RCTResponseSenderBlock)errorCallback)
{
    [VerifyClient
     verifyStandaloneWithCountryCode:countryCode
     phoneNumber:phoneNumber
     verifyInProgressBlock:^{
         NSString *eventName = @"verification process begins.";
         [self.bridge.eventDispatcher sendAppEventWithName:@"NexmoVerify" body:@{@"name" : eventName}];
     }
     userVerifiedBlock:^{
         userVerifiedCallback(@"userVerifiedCallback");
     }
     errorBlock:^(VerifyError error) {
         NSError *e = getNSError(error);
         errorCallback(@[e.userInfo]);
     }];
}

@end
