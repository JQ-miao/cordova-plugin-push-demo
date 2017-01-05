//
//  Push.m
//  PushNotification
//
//  Created by himjq on 2016/12/16.
//
//

#import "Push.h"

@implementation Push

-(void) init:(CDVInvokedUrlCommand*)command{
    
    self.registerCallbackId = command.callbackId;
    
    if (command.arguments[0]) {
        NSDictionary *dic = command.arguments[0];
        
        self.url = dic[@"url"];
        self.userID = dic[@"userID"];
        self.deviceID = dic[@"deviceID"];
        self.applicationMode = dic[@"applicationMode"];
        self.clientSecret = dic[@"clientSecret"];
        self.autoClearBadge = dic[@"autoClearBadge"];
        
        [self.commandDelegate runInBackground:^{
            
            UIApplication *application = [UIApplication sharedApplication];
            if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                
                if ([[UIDevice currentDevice].systemVersion floatValue]<8.0) {
                    UIRemoteNotificationType type = UIRemoteNotificationTypeAlert| UIUserNotificationTypeBadge | UIRemoteNotificationTypeSound;
                    [application registerForRemoteNotificationTypes:type];
                }else{
                    UIUserNotificationSettings *settings =[UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
                    [application registerUserNotificationSettings:settings];
                    [application registerForRemoteNotifications];
                }
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerCallBackHandle:) name:@"registerRemoteNotifications" object:nil];
            
            if ([self.autoClearBadge isEqualToString:@"true"]) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearBadge)name:UIApplicationDidBecomeActiveNotification object:nil];
            }
        }];
    }
}
-(void)clearBadge{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

-(void) notificationsListener:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
    self.receiveCallbackId = command.callbackId;
    [self.commandDelegate runInBackground:^{
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCallBackHandle:) name:@"receiveRemoteNotifications" object:nil];}];
    }];
}

-(void) getBadgeNumber:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:[UIApplication sharedApplication].applicationIconBadgeNumber] ;
    [pluginResult argumentsAsJSON];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) reduceBadgeNumber:(CDVInvokedUrlCommand*)command{
 
    NSInteger count = [command.arguments[0] integerValue];
    if ([UIApplication sharedApplication].applicationIconBadgeNumber<=count) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }else{
        [UIApplication sharedApplication].applicationIconBadgeNumber -= count;
    }
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"] ;
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(void) registerCallBackHandle:(NSNotification *)notification{
    
    CDVPluginResult* pluginResult = nil;
    NSDictionary *dic = notification.userInfo;
    if (dic[@"isSuccess"]) {
        [self updateDeviceRegistered:dic[@"value"]];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic[@"value"]] ;
    }else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dic[@"value"]] ;
    }
    [pluginResult argumentsAsJSON];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.registerCallbackId];
}

-(void) receiveCallBackHandle:(NSNotification *)notification{
    
    CDVPluginResult* pluginResult = nil;
    NSDictionary *dic = notification.userInfo;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic] ;
    [pluginResult setKeepCallbackAsBool:true];
    [pluginResult argumentsAsJSON];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.receiveCallbackId];
}

// register deviceToken to bluemix server.
-(void) updateDeviceRegistered:(NSString *) token{
    
    if (self.url&&self.userID&&self.deviceID&&self.applicationMode&&self.clientSecret) {
        
        NSData *postDatas = nil;
        NSMutableDictionary *parsDic = [[NSMutableDictionary alloc] init];
        [parsDic setValue:self.deviceID forKey:@"deviceId"];
        [parsDic setValue:@"A" forKey:@"platform"];
        [parsDic setValue:token forKey:@"token"];
        [parsDic setValue:self.userID forKey:@"userId"];
        
        if ([NSJSONSerialization isValidJSONObject:parsDic]) {
            postDatas = [NSJSONSerialization dataWithJSONObject:parsDic options:NSJSONWritingPrettyPrinted error:nil];
        }

        NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
        
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
        [urlRequest setValue:self.applicationMode forHTTPHeaderField:@"Application-Mode"];
        [urlRequest setValue:self.clientSecret forHTTPHeaderField:@"clientSecret"];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setTimeoutInterval:30.0];
        [urlRequest setHTTPBody:postDatas];
        
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        
        if (error) {
            NSLog(@"Send deviceToken to bluemix server error:%@",error.localizedFailureReason);
        }else{
            NSLog(@"Send deviceToken to bluemix server statusCode :%ld",response.statusCode);
        }
    }
}

@end
