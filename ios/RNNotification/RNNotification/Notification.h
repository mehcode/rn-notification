#import <Foundation/Foundation.h>

@interface Notification : NSObject

// Create a new notification from options object
+(Notification*)create:(NSDictionary*) options;

// Show
-(void)show;

@end
