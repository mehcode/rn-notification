#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"
#import <UIKit/UILocalNotification.h>

@interface RNNotification : NSObject <RCTBridgeModule>

+(void)didReceiveLocalNotification:(UILocalNotification*)notification;

@end
