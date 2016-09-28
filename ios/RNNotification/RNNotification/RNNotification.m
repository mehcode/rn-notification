#import "RNNotification.h"
#import "RCTBridge.h"
#import "Notification.h"
#import "RCTConvert.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "RCTUtils.h"

@import UserNotifications;

@implementation RNNotification

+(void) didReceiveLocalNotification:(UILocalNotification *)notification {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ROFL"
                                                    message:@"Dee dee doo doo."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];

    [alert show];
}

// NOTE: Taken from https://github.com/evollu/react-native-fcm/blob/master/ios/RNFIRMesssaging.m#L189-L223
// TODO: Cleanup: requestPermissions

RCT_EXPORT_METHOD(requestPermissions) {
    if (RCTRunningInAppExtension()) {
        return;
    }
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIApplication *app = RCTSharedApplication();
        if ([app respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            //iOS 8 or later
            UIUserNotificationSettings *notificationSettings =
            [UIUserNotificationSettings settingsForTypes:(NSUInteger)allNotificationTypes categories:nil];
            [app registerUserNotificationSettings:notificationSettings];
        } else {
            //iOS 7 or below
            [app registerForRemoteNotificationTypes:(NSUInteger)allNotificationTypes];
        }
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:authOptions
         completionHandler:^(BOOL granted, NSError * _Nullable error) {
         }
         ];
#endif
    }

    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

RCT_REMAP_METHOD(create,
                 options:(NSDictionary*) options
                 payload:(NSDictionary*) payload
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [[Notification create:options] show];

    resolve([NSNull null]);
}

RCT_EXPORT_MODULE();
@end
