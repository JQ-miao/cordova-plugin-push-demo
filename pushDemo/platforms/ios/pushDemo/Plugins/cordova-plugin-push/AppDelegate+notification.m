//
//  AppDelegate+notification.m
//  PushNotification
//
//  Created by himjq on 2016/12/18.
//
//

#import "AppDelegate+notification.h"

@implementation AppDelegate (notification)

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString* token = [[[[deviceToken description]
                         stringByReplacingOccurrencesOfString:@"<" withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString:@" " withString:@" "];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"registerRemoteNotifications" object:nil userInfo:@{@"isSuccess":@YES ,@"value":token}]];
    NSLog(@"%s:%@",__func__,token);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"registerRemoteNotifications" object:nil userInfo:@{@"isSuccess":@NO ,@"value":error.localizedDescription}]];
    NSLog(@"%s:%@",__func__,error.localizedFailureReason);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"receiveRemoteNotifications" object:nil userInfo:userInfo]];
    NSLog(@"%s:%@",__func__,userInfo);
}

-(void) applicationDidBecomeActive:(UIApplication *)application{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"autoClearBadge"] isEqualToString:@"true"]) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

@end
