#import "RNNotification.h"
#import "RCTBridge.h"
#import "Notification.h"
#import "RCTConvert.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "RCTUtils.h"

#import "UserNotifications/UserNotifications.h"

NSString *const FCMNotificationReceived = @"FCMNotificationReceived";

@implementation RNNotification

@synthesize bridge = _bridge;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setBridge:(RCTBridge *)bridge
{
    _bridge = bridge;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotificationReceived:)
                                                 name:FCMNotificationReceived
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disconnectFCM)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectToFCM)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onTokenRefresh)
     name:kFIRInstanceIDTokenRefreshNotification object:nil];

    // For iOS 10 data message (sent via FCM)
    [[FIRMessaging messaging] setRemoteMessageDelegate:self];
}

- (void)connectToFCM
{
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}

- (void)disconnectFCM
{
    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");
}

+(void) didReceiveLocalNotification:(UILocalNotification *)notification {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ROFL"
                                                    message:@"Dee dee doo doo."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];

    [alert show];
}

// .getRegistrationToken (FCM/GCM)
RCT_EXPORT_METHOD(getRegistrationToken:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([[FIRInstanceID instanceID] token]);
}

- (void) onTokenRefresh {
    [_bridge.eventDispatcher sendAppEventWithName:@"RNNotification:registration" body:[[FIRInstanceID instanceID] token]];
}

// .requestPermission (iOS only)
RCT_EXPORT_METHOD(requestPermission) {
    if (RCTRunningInAppExtension()) {
        return;
    }

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIApplication *app = RCTSharedApplication();
        if ([app respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            // iOS 8 or later
            UIUserNotificationSettings *notificationSettings =
            [UIUserNotificationSettings settingsForTypes:(NSUInteger)allNotificationTypes categories:nil];
            [app registerUserNotificationSettings:notificationSettings];
        } else {
            // iOS 7 or below
            [app registerForRemoteNotificationTypes:(NSUInteger)allNotificationTypes];
        }
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        UNAuthorizationOptions authOptions = (UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge);
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions
                                                                            completionHandler:^(BOOL granted, NSError * _Nullable error) { }
         ];
#endif
    }

    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

// .create – Create/Show local notification
RCT_REMAP_METHOD(create,
                 options:(NSDictionary*) options
                 payload:(NSDictionary*) payload
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [[Notification create:options] show];

    resolve([NSNull null]);
}

// .clearAll – Clear all local notifications
RCT_REMAP_METHOD(clearAll,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [RCTSharedApplication() cancelAllLocalNotifications];

    resolve([NSNull null]);
}

// Remote notification received
- (void)handleNotificationReceived:(NSNotification *)notification {
    NSLog(@"handleNotificationReceived");
//    NSMutableDictionary *data = [[NSMutableDictionary alloc]initWithDictionary: notification.userInfo];
//    [data setValue:@(RCTSharedApplication().applicationState == UIApplicationStateInactive) forKey:@"opened_from_tray"];
//    [_bridge.eventDispatcher sendDeviceEventWithName:FCMNotificationReceived body:data];
}

RCT_EXPORT_MODULE();
@end
