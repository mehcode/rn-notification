#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <UIKit/UILocalNotification.h>

@import FirebaseAnalytics;
@import FirebaseInstanceID;
@import FirebaseMessaging;

extern NSString *const RNRemoteNotificationReceived;
extern NSString *const RNLocalNotificationReceived;

@interface RNNotification : NSObject <RCTBridgeModule>
+(void) init:(NSDictionary*)launchOptions;
@end
