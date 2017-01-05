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
        self.platform = dic[@"platform"];
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
                [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"autoClearBadge"];
            }
        }];
    }
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

-(void) deleteDeviceRegistered:(CDVInvokedUrlCommand*)command{
    
    NSString *url = [NSString string];
    NSString *deviceID = [NSString string];
    
    if (command.arguments[0]) {
        url = command.arguments[0][@"url"];
        deviceID = command.arguments[0][@"deviceID"];
    }
    

    if ([[url substringFromIndex:url.length-1] isEqualToString:@"/"]) {
        url = [self.url stringByAppendingString:deviceID];
    }else{
        url = [self.url stringByAppendingString:[NSString stringWithFormat:@"/%@",deviceID]];
    }
    
    [self requestBluemixByHttpMethod:@"DELETE" success:^(NSHTTPURLResponse *response) {
        NSLog(@"Delete registered device from Bluemix with statusCode :%ld",response.statusCode);
    } failure:^(NSError *error) {
        NSLog(@"Delete registered device from Bluemix with error :%@",error.localizedFailureReason);
    } withPars:nil andUrl:url];

}


-(void) registerCallBackHandle:(NSNotification *)notification{
    
    CDVPluginResult* pluginResult = nil;
    NSDictionary *dic = notification.userInfo;
    if (dic[@"isSuccess"]) {
        [self deviceRegister:dic[@"value"]];
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
-(void) deviceRegister:(NSString *) token{
    
    if (self.url&&self.userID&&self.deviceID&&self.applicationMode&&self.clientSecret&&self.platform) {
        
        NSMutableDictionary *parsDic = [[NSMutableDictionary alloc] init];
        [parsDic setValue:self.deviceID forKey:@"deviceId"];
        [parsDic setValue:self.platform forKey:@"platform"];
        [parsDic setValue:token forKey:@"token"];
        [parsDic setValue:self.userID forKey:@"userId"];
        [parsDic setValue:@(true) forKey:@"mfpPushEnableBroadcast"];
        
        [self requestBluemixByHttpMethod:@"POST" success:^(NSHTTPURLResponse *response) {
            NSLog(@"Register device to Bluemix with statusCode :%ld",response.statusCode);
            if (response.statusCode == 409) {
                //device has registered update deviceToken
                [self updateDeviceRegistered:token];
            }
        } failure:^(NSError *error) {
            NSLog(@"Register device to Bluemix with error :%@",error.localizedFailureReason);
        } withPars:parsDic andUrl:self.url];
        
    }
}

-(void) updateDeviceRegistered:(NSString *) token{
    
    NSMutableDictionary *parsDic = [[NSMutableDictionary alloc] init];
    [parsDic setValue:self.deviceID forKey:@"deviceId"];
    [parsDic setValue:self.platform forKey:@"platform"];
    [parsDic setValue:token forKey:@"token"];
    
    NSString *url = [NSString string];
    if ([[self.url substringFromIndex:self.url.length-1] isEqualToString:@"/"]) {
        url = [self.url stringByAppendingString:self.deviceID];
    }else{
        url = [self.url stringByAppendingString:[NSString stringWithFormat:@"/%@",self.deviceID]];
    }
    
    [self requestBluemixByHttpMethod:@"PUT" success:^(NSHTTPURLResponse *response) {
        NSLog(@"Update device infor to Bluemix with statusCode :%ld",response.statusCode);
    } failure:^(NSError *error) {
        NSLog(@"Update device infor to Bluemix with error :%@",error.localizedFailureReason);
    } withPars:parsDic andUrl:url];

}

-(void)requestBluemixByHttpMethod:(NSString *)method success:(void(^)(NSHTTPURLResponse *response))success failure:(void(^)(NSError *error))failure withPars:(NSDictionary *)pars andUrl:(NSString *)url{

    NSHTTPURLResponse *res = nil;
    NSError *err = nil;
    NSData *postDatas = nil;
    
    if (pars) {
        if ([NSJSONSerialization isValidJSONObject:pars]) {
            postDatas = [NSJSONSerialization dataWithJSONObject:pars options:NSJSONWritingPrettyPrinted error:nil];
        }
    }
    
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];
    [urlRequest setValue:self.applicationMode forHTTPHeaderField:@"Application-Mode"];
    [urlRequest setValue:self.clientSecret forHTTPHeaderField:@"clientSecret"];
    [urlRequest setHTTPMethod:method];
    [urlRequest setTimeoutInterval:30.0];
    [urlRequest setHTTPBody:postDatas];
    
    [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&res error:&err];
    
    if (err) {
        failure(err);
        
    }else{
        success(res);
    }
}
@end
