
#import "RNNexmoVerify.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"

@import VerifyIosSdk;

NSString *const AppId = @"ID";
NSString *const SharedSecretKey = @"KEY";

@interface RNNexmoVerify()

@end

@implementation RNNexmoVerify


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

-()init
{
    self = [super init];
    if (self)
    {
        [NexmoClient startWithApplicationId:AppId sharedSecretKey:SharedSecretKey];
    }
    return self;
}

RCT_EXPORT_MODULE()




// Get Verified User
RCT_EXPORT_METHOD(getVerifiedUser:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verifyInProgressCallback:(RCTResponseSenderBlock)verifyInProgressCallback userVerifiedCallback:(RCTResponseSenderBlock)userVerifiedCallback errorCallback:(RCTResponseSenderBlock)errorCallback)
{
    [VerifyClient getVerifiedUserWithCountryCode:countryCode phoneNumber:phoneNumber
                           verifyInProgressBlock:^ {
                               verifyInProgressCallback(@"verification process begins.");
                           } userVerifiedBlock:^{
                               userVerifiedCallback(@"user has been successfully verified.");
                           } errorBlock:^(VerifyError _error) {
                               errorCallback(@"err");
                           }
     ];
}




// Check PinCode
RCT_EXPORT_METHOD(checkPinCode:(NSString *)code)
{
    [VerifyClient checkPinCode:code];
}




// Get User Status
RCT_EXPORT_METHOD(getUserStatus:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber callback:(RCTResponseSenderBlock)callback)
{
    [VerifyClient getUserStatusWithCountryCode:countryCode WithNumber:phoneNumber WithBlock:^(NSString *status, NSError *error) {
        callback(@[error, status]);
    }];
    
}

RCT_EXPORT_METHOD(getUserStatusPromise:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [VerifyClient getUserStatusWithCountryCode:countryCode WithNumber:phoneNumber WithBlock:^(NSString *status, NSError *error) {
        if(error != nil) {
            return reject(nil, @"unable to get user status", error);
        }
        resolve(status);
        //        if ([status isEqualToString:UserStatus.USER_UNKNOWN]) {
        //            // user has never before been verified
        //        } else if ([status isEqualToString:UserStatus.USER_PENDING]) {
        //            // a verification request is currently in progress for this user
        //        }
        //        // other user statuses can be found in the UserStatus class
    }];
}



// Cancel Verification
RCT_EXPORT_METHOD(cancelVerification:(RCTResponseSenderBlock)callback)
{
    [VerifyClient cancelVerificationWithBlock:^(NSError *error) {
        callback(@[error]);
    }];
}

RCT_EXPORT_METHOD(cancelVerificationPromise:resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [VerifyClient cancelVerificationWithBlock:^(NSError *error) {
        if (error != nil) {
            return reject(nil, @"something wen't wrong whilst attempting to cancel the current verification request", error);
        }
        resolve(@"verification request successfully cancelled");
    }];
}




// Trigger Next Event
RCT_EXPORT_METHOD(triggerNextEvent:(RCTResponseSenderBlock)callback)
{
    [VerifyClient triggerNextEventWithBlock:^(NSError *error) {
        callback(@[error]);
    }];
}

RCT_EXPORT_METHOD(triggerNextEventPromise:resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [VerifyClient triggerNextEventWithBlock:^(NSError *error) {
        if (error != nil) {
            return reject(nil, @"unable to trigger next event", error);
        }
        resolve(@"successfully triggered next event");
    }];
}




//Logout User
RCT_EXPORT_METHOD(logoutUser:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber callback:(RCTResponseSenderBlock)callback)
{
    [VerifyClient logoutUserWithCountryCode:countryCode WithNumber:phoneNumber WithBlock:^(NSError *error) {
        callback(@[error]);
    }];
}

RCT_EXPORT_METHOD(logoutUserPromise:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    
    [VerifyClient logoutUserWithCountryCode:countryCode WithNumber:phoneNumber WithBlock:^(NSError *error) {
        if ( error != nil ) {
            return reject(nil, @"unable to logout user", error);
        }
        resolve(@"successfully logged out user");
    }];
}




// Verify Stand Alone
RCT_EXPORT_METHOD(verifyStandAlone:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber verifyInProgressBlock:(RCTResponseSenderBlock)verifyInProgressBlock userVerifiedBlock:(RCTResponseSenderBlock)userVerifiedBlock errorBlock:(RCTResponseSenderBlock)errorBlock)
{
    [VerifyClient verifyStandaloneWithCountryCode:countryCode phoneNumber:phoneNumber
                            verifyInProgressBlock:^{
                                verifyInProgressBlock(@[[NSNull null], @"verification process begins."]);
                            } userVerifiedBlock:^{
                                //
                            } errorBlock:^(VerifyError error) {
                                // Called when an error occurs during verification. For example, the user enters the wrong pin.
                                // See the VerifyError class for more details.
                            }
     ];
}

@end












