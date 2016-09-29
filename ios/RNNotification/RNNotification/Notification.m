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

    // Construct `alertBody` (subject + ":" + message)
    // Maps to `@notification#body`
    NSString* subject = [RCTConvert NSString:options[@"subject"]];
    NSString* message = [RCTConvert NSString:options[@"message"]];
    NSString* alertBody = [NSString stringWithFormat:@"%@: %@", subject, message];
    handle.alertBody = alertBody;

    // TODO: Sound
    handle.soundName = UILocalNotificationDefaultSoundName;

    // Store options object as userInfo (so it gets forwarded around)
    handle.userInfo = options;

    return notification;
}

-(void)show {
    // TODO: iOS 10
    UILocalNotification* handle = (UILocalNotification*)self->handle;
    [RCTSharedApplication() presentLocalNotificationNow:handle];
}

@end
