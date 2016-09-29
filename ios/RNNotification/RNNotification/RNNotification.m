#import "RNNotification.h"
#import "RCTBridge.h"
#import "Notification.h"
#import "RCTConvert.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "RCTUtils.h"

#import "FTNotificationIndicator.h"

#import "UserNotifications/UserNotifications.h"

#import <AudioToolbox/AudioToolbox.h>

NSString *const RNRemoteNotificationReceived = @"RNRemoteNotificationReceived";
NSString *const RNLocalNotificationReceived = @"RNLocalNotificationReceived";

NSDictionary const* LaunchNotificationData = nil;

NSMutableSet* localRemoteNotificationID;

@implementation RNNotification {
    bool isConnected;
}

@synthesize bridge = _bridge;

+ (id)alloc
{
    static RNNotification *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super alloc];
    });
    return sharedInstance;
}

// init (from AppDelegate)
+ (void)init:(NSDictionary *)launchOptions {
    RNNotification* sharedInstance = [[RNNotification alloc] init];

    // Initialize lrnid set
    localRemoteNotificationID = [[NSMutableSet alloc] init];

    [FIRApp configure];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        // [...]
    } else {
        // Only iOS 10
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        [[UNUserNotificationCenter currentNotificationCenter] setDelegate:sharedInstance];
#endif
    }

    // Check launchOptions
    id remoteLaunch = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteLaunch) {
        // App was launched (from death) by tapping on a (remote) notification
        NSError *error = nil;
        NSData *jsonRaw = [[remoteLaunch objectForKey:@"notification"] dataUsingEncoding:NSUTF8StringEncoding];
        id object = [NSJSONSerialization
                     JSONObjectWithData:(NSString*)jsonRaw
                     options:0
                     error:&error];

        LaunchNotificationData = object;
    } else {
        id localLaunch = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localLaunch) {
            // App was launched (from death) by tapping on a (local) notification
            UILocalNotification* ln = localLaunch;
            LaunchNotificationData = ln.userInfo;
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setBridge:(RCTBridge *)bridge
{
    _bridge = bridge;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRemoteNotificationReceived:)
                                                 name:RNRemoteNotificationReceived
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLocalNotificationReceived:)
                                                 name:RNLocalNotificationReceived
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
    if (isConnected) return;

    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
            isConnected = true;
        }
    }];
}

- (void)disconnectFCM
{
    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");
    isConnected = false;
}

// .getRegistrationToken (FCM/GCM)
RCT_EXPORT_METHOD(getRegistrationToken:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    resolve([[FIRInstanceID instanceID] token]);
}

- (void) onTokenRefresh {
    [_bridge.eventDispatcher sendDeviceEventWithName:@"RNNotification:registration" body:[[FIRInstanceID instanceID] token]];
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
                 clearAll:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [RCTSharedApplication() cancelAllLocalNotifications];

    resolve([NSNull null]);
}

// .getInitialNotificationPress – Get launch event
RCT_REMAP_METHOD(getInitialNotificationPress,
                 getInitialNotificationPress:(RCTResponseSenderBlock)callback) {
    if (LaunchNotificationData) {
        NSDictionary* event = @{@"payload": (NSDictionary*)[LaunchNotificationData objectForKey:@"payload"]};

        callback(@[event]);
    }
}

// Handle press
- (void)handlePress:(NSDictionary*)data {
    NSDictionary* event = @{@"payload": [data objectForKey:@"payload"]};

    [_bridge.eventDispatcher sendDeviceEventWithName:@"RNNotification:press" body:event];
}

// Local notification received
- (void)handleLocalNotificationReceived:(NSNotification *)notification {
    NSMutableDictionary *data = [[NSMutableDictionary alloc]initWithDictionary: notification.userInfo];

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        // IFF this notification was received remotely while the app was inactive we need to act
        id uid = [((NSDictionary*)data) objectForKey:@"id"];

        if (uid) {
            if ([localRemoteNotificationID containsObject:uid]) {
                [localRemoteNotificationID removeObject:uid];
                return;
            }
        }

        // PRESS
        [self handlePress:data];
    } else {
        // Recieved while in application
        // Show alert

        // Play sound
        // TODO: Handle default sound
        NSString *soundName = [RCTConvert NSString:data[@"sound"]];
        if (![soundName isEqualToString:@"default"]) {
            NSArray *parts = [soundName componentsSeparatedByString:@"."];
            if ([parts count] == 2) {
                NSString *soundPath = [[NSBundle mainBundle] pathForResource:[parts objectAtIndex:0] ofType:[parts objectAtIndex:1]];
                if (soundPath) {
                    SystemSoundID soundID;
                    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundPath], &soundID);
                    AudioServicesPlaySystemSound(soundID);

                    // TODO: Dispose? (do we need to with ARC)
                }
            }
        }

        NSString* subject = [RCTConvert NSString:data[@"subject"]];
        NSString* message = [RCTConvert NSString:data[@"message"]];

        [FTNotificationIndicator setNotificationIndicatorStyle:UIBlurEffectStyleDark];
        [FTNotificationIndicator showNotificationWithImage:[UIImage imageNamed:@"AppIcon76x76"]
                                         title:subject
                                       message:message
                                    tapHandler:^{
                                        // handle user tap
                                        [self handlePress:data];
                                    } completion:^{
                                        // handle completion
                                    }];
    }
}

// Remote notification received
- (void)handleRemoteNotificationReceived:(NSNotification *)notification {
    NSMutableDictionary *data = [[NSMutableDictionary alloc]initWithDictionary: notification.userInfo];

    NSError *error = nil;
    NSData *jsonRaw = [[data objectForKey:@"notification"] dataUsingEncoding:NSUTF8StringEncoding];
    id object = [NSJSONSerialization
                 JSONObjectWithData:(NSString*)jsonRaw
                 options:0
                 error:&error];

    if (!error && [object isKindOfClass:[NSDictionary class]]) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive && !isConnected) {
            // Press on a remote initiated notification
            [self handlePress:(NSDictionary*)object];
            return;
        }

        NSMutableDictionary *options = [[NSMutableDictionary alloc]initWithDictionary: object];

        // Remember that this notification (by UID)
        NSString* uid = [data objectForKey:@"gcm.message_id"];
        [options setObject:uid forKey:@"id"];

        // If we are inactive - we need TWO local events to fire in order to trigger a press
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
            [localRemoteNotificationID addObject:uid];
        }

        [[Notification create:(NSDictionary*)options] show];
    }
}

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    id container = response.notification.request.content.userInfo;

    NSError *error = nil;
    NSData *jsonRaw = [[container objectForKey:@"notification"] dataUsingEncoding:NSUTF8StringEncoding];
    id object = [NSJSONSerialization
                 JSONObjectWithData:(NSString*)jsonRaw
                 options:0
                 error:&error];

    if (!error && [object isKindOfClass:[NSDictionary class]]) {
        [self handlePress:(NSDictionary*)object];
    }

    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}
#endif

RCT_EXPORT_MODULE();
@end
