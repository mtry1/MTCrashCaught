//
//  MTCrashCaught.m
//  MTCrashCaughtDemo
//
//  Created by zhourongqing on 15/12/30.
//  Copyright © 2015年 mtry. All rights reserved.
//

#import "MTCrashCaught.h"
#include <sys/signal.h>
#include <execinfo.h>

static MTCompletionHandler exceptionCompletionHandler;

@implementation MTCrashCaught

+ (void)installCompletionHandler:(MTCompletionHandler)completionHandler
{
    exceptionCompletionHandler = completionHandler;
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    signal(SIGABRT, signalExceptionHandler);
    signal(SIGILL,  signalExceptionHandler);
    signal(SIGSEGV, signalExceptionHandler);
    signal(SIGFPE,  signalExceptionHandler);
    signal(SIGBUS,  signalExceptionHandler);
    signal(SIGPIPE, signalExceptionHandler);
}

+ (void)unInstall
{
    if(exceptionCompletionHandler)
    {
        exceptionCompletionHandler = nil;
    }
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL,  SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE,  SIG_DFL);
    signal(SIGBUS,  SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
}

+ (void)handleExceptionDescription:(NSString *)exceptionDescription
{
    __block BOOL isFinished = NO;
    if(exceptionCompletionHandler)
    {
        exceptionCompletionHandler(exceptionDescription, ^(void){
            isFinished = YES;
        });
    }
    else
    {
        isFinished = YES;
    }
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    while(!isFinished)
    {
        [runLoop runMode:NSRunLoopCommonModes beforeDate:[NSDate distantFuture]];
    }
    
    [MTCrashCaught unInstall];
}

void signalExceptionHandler(int signal)
{
    NSMutableString *exceptionDescription = [NSMutableString string];
    [exceptionDescription appendFormat:@"reason:Signal %d was raise\n", signal];
    [exceptionDescription appendString:@"callStackSymbols:\n"];
    
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    for(int i = 0; i < frames; ++i)
    {
        [exceptionDescription appendFormat:@"%s\n", strs[i]];
    }
    
    [MTCrashCaught handleExceptionDescription:exceptionDescription];
}

void uncaughtExceptionHandler(NSException *exception)
{
    NSMutableString *exceptionDescription = [NSMutableString string];
    
    [exceptionDescription appendFormat:@"name:%@\n", exception.name];
    [exceptionDescription appendFormat:@"reason:%@\n",exception.reason];
    [exceptionDescription appendFormat:@"callStackSymbols:%@\n",exception.callStackSymbols];
    
    [MTCrashCaught handleExceptionDescription:exceptionDescription];
}

@end
