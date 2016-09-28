#import <Foundation/Foundation.h>
#import "Notification.h"
#import "RCTConvert.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "RCTUtils.h"

#import <UIKit/UILocalNotification.h>

@implementation Notification {
    // Native handle of the notification
    id handle;
}

+(Notification*)create:(NSDictionary*) options {
    Notification* notification = [[Notification alloc] init];

    // Create native handle
    // TODO: iOS 10
    UILocalNotification* handle = [[UILocalNotification alloc] init];
    notification->handle = handle;

    // Maps to `@notification#title`
    handle.alertTitle = [RCTConvert NSString:options[@"subject"]];

    // Maps to `@notification#body`
    handle.alertBody = [RCTConvert NSString:options[@"message"]];

    // TODO: Sound
    handle.soundName = UILocalNotificationDefaultSoundName;

    return notification;
}

-(void)show {
    // TODO: iOS 10
    UILocalNotification* handle = (UILocalNotification*)self->handle;
    [RCTSharedApplication() presentLocalNotificationNow:handle];
}

@end
