//
//  Push.h
//  PushNotification
//
//  Created by himjq on 2016/12/16.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface Push : CDVPlugin 
@property(nonatomic,copy)NSString* registerCallbackId;
@property(nonatomic,copy)NSString* receiveCallbackId;

@property(nonatomic,copy)NSString* applicationMode;
@property(nonatomic,copy)NSString* clientSecret;
@property(nonatomic,copy)NSString* deviceToken;
@property(nonatomic,copy)NSString* deviceID;
@property(nonatomic,copy)NSString* userID;
@property(nonatomic,copy)NSString* url;

@property(nonatomic,copy)NSString* autoClearBadge;

-(void) init:(CDVInvokedUrlCommand*)command;
-(void) notificationsListener:(CDVInvokedUrlCommand*)command;
-(void) getBadgeNumber:(CDVInvokedUrlCommand*)command;
-(void) reduceBadgeNumber:(CDVInvokedUrlCommand*)command;

@end
