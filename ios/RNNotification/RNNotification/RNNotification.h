#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"
#import <UIKit/UILocalNotification.h>

@import FirebaseAnalytics;
@import FirebaseInstanceID;
@import FirebaseMessaging;

extern NSString *const FCMNotificationReceived;

@interface RNNotification : NSObject <RCTBridgeModule>
@end
