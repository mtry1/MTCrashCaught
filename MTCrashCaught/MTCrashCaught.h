//
//  MTCrashCaught.h
//  MTCrashCaughtDemo
//
//  Created by zhourongqing on 15/12/30.
//  Copyright © 2015年 mtry. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MTResponseCallback)(void);
typedef void(^MTCompletionHandler)(NSString *exceptionDescription, MTResponseCallback responseCallback);

@interface MTCrashCaught : NSObject

+ (void)installCompletionHandler:(MTCompletionHandler)completionHandler;

@end
