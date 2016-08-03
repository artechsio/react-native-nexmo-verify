
#import "RNNexmoVerify.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"


@import VerifyIosSdk;

@implementation RNNexmoVerify


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


//@synthesize bridge = _bridge;
//
//- (void)calendarEventReminderReceived:(NSNotification *)notification
//{
//    NSString *eventName = notification.userInfo[@"name"];
//    [self.bridge.eventDispatcher sendAppEventWithName:@"VerifyInProgressBlock" body:@{@"name": eventName}];
//}


RCT_EXPORT_MODULE()


RCT_EXPORT_METHOD(initialize)
{
    [NexmoClient startWithApplicationId:@"" sharedSecretKey:@""];
}

RCT_EXPORT_METHOD(getUserStatusWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber) {

    [VerifyClient getUserStatusWithCountryCode:countryCode WithNumber:phoneNumber WithBlock:^(NSString *status, NSError *error) {

        if ([status isEqualToString:UserStatus.USER_UNKNOWN]) {
            // user has never before been verified
            // ..
        } else if ([status isEqualToString:UserStatus.USER_PENDING]) {
            // a verification request is currently in progress for this user
            // ..
        }
        // other user statuses can be found in the UserStatus class
        //..
    }];
}

RCT_EXPORT_METHOD(logoutUserWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    [VerifyClient logoutUserWithCountryCode:@"IL" WithNumber:@"0546917698" WithBlock:^(NSError *error) {
     if ( error != nil ) {
         // unable to logout user
         return reject(@"no_events", @"There were no events", @"unable to logout user");
     }
        resolve(@"successfully logged out user");
     // successfully logged out user
     }];
}


RCT_EXPORT_METHOD(getVerifiedUserWithCountryCode:(NSString *)countryCode phoneNumber:(NSString *)phoneNumber resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{



    [VerifyClient getVerifiedUserWithCountryCode:countryCode phoneNumber:phoneNumber
                           verifyInProgressBlock:^{
                               //Called when the verification process begins.
                               //                               inProgressCallback(@"verification process begins.");

                           }
                               userVerifiedBlock:^{
                                   // Called when the user has been successfully verified.
                                   resolve(@"user has been successfully verified.");

                               }
                                      errorBlock:^(VerifyError error) {
                                          //                                          RCTLog(error);
                                          reject(@"no_events", @"There were no events", @"an error occured during verification.");
                                          // Called when an error occurs during verification. For example, the user enters the wrong pin.
                                          // See the VerifyError class for more details.
                                      }
     ];
}

//RCT_EXPORT_METHOD(unVerify)

RCT_EXPORT_METHOD(checkPinCode:(NSString *)code)
{
    RCTLog(code);
    [VerifyClient checkPinCode:code];


}


@end
