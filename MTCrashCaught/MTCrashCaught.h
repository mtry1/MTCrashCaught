//
//  MTCrashCaught.h
//  MTCrashCaughtDemo
//
//  Created by zhourongqing on 15/12/30.
//  Copyright © 2015年 mtry. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 使用说明（必须要dSYM符号表文件）
 
 捕获的闪退日志内容如下
 name:NSInternalInconsistencyException
 reason:Invalid update: invalid number of rows in section 0.  The number of rows contained in an existing section after the update (2) must be equal to the number of rows contained in that section before the update (1), plus or minus the number of rows inserted or deleted from that section (1 inserted, 1 deleted) and plus or minus the number of rows moved into or out of that section (0 moved in, 0 moved out).
 0   CoreFoundation                      0x0000000183dc2dc8 <redacted> + 148
 1   libobjc.A.dylib                     0x0000000183427f80 objc_exception_throw + 56
 2   CoreFoundation                      0x0000000183dc2c80 <redacted> + 0
 3   Foundation                          0x0000000184748154 <redacted> + 112
 4   UIKit                               0x0000000189115808 <redacted> + 12624
 5   UIKit                               0x00000001891301d0 <redacted> + 360
 6   InterviewEvaluation                 0x00000001001273a0 InterviewEvaluation + 177056
 7   UIKit                               0x0000000189053dc4 <redacted> + 1316
 8   UIKit                               0x00000001891117d4 <redacted> + 376
 9   UIKit                               0x00000001891cf0c8 <redacted> + 292
 10  UIKit                               0x00000001891dca80 <redacted> + 92
 11  UIKit                               0x0000000188f0e5a4 <redacted> + 96
 12  CoreFoundation                      0x0000000183d78728 <redacted> + 32
 13  CoreFoundation                      0x0000000183d764cc <redacted> + 372
 14  CoreFoundation                      0x0000000183d768fc <redacted> + 928
 15  CoreFoundation                      0x0000000183ca0c50 CFRunLoopRunSpecific + 384
 16  GraphicsServices                    0x0000000185588088 GSEventRunModal + 180
 17  UIKit                               0x0000000188f86088 UIApplicationMain + 204
 18  InterviewEvaluation                 0x00000001001151f8 InterviewEvaluation + 102904
 19  libdyld.dylib                       0x000000018383e8b8 <redacted> + 4
 
 UUID: 5FFEDD96-E4E1-3008-8D92-D22C2054D9C8
 loadAddress: 0x1000fc000
 
 步骤：
 1、确保当前闪退日志的UUID和dSYM的UUID一致
 终端命令：dwarfdump --uuid appName.app.dSYM
 例如：dwarfdump --uuid /Users/zhourongqing/Desktop/155401/InterviewEvaluation.app.dSYM
 结果：UUID: E1F36C5C-5F16-3FC4-8F51-BE25B49C0B1D (armv7)
      UUID: 5FFEDD96-E4E1-3008-8D92-D22C2054D9C8 (arm64)
 2、查看关键错误（错误列表行号为3的错误）
 终端命令：atos [-o AppName.app/AppName] [-l loadAddress] [-arch architecture] [address1 address2 ..]
 例如：atos -o /Users/zhourongqing/Desktop/155401/InterviewEvaluation.app/InterviewEvaluation -l 0x1000fc000 -arch arm64 0x00000001001273a0
 结果：-[IECandidateFilterPopView tableView:didSelectRowAtIndexPath:] (in InterviewEvaluation) (IECandidateFilterPopView.m:382)
 */

typedef void(^MTResponseCallback)(void);
typedef void(^MTCompletionHandler)(NSString *exceptionDescription, MTResponseCallback responseCallback);

@interface MTCrashCaught : NSObject

+ (void)installCompletionHandler:(MTCompletionHandler)completionHandler;

@end