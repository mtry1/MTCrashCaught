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
#include <mach-o/dyld.h>
#include <mach-o/ldsyms.h>
#import <Foundation/Foundation.h>

static MTCompletionHandler exceptionCompletionHandler;
static NSUncaughtExceptionHandler *previousUncaughtExceptionHandler;

@implementation MTCrashCaught

+ (void)installCompletionHandler:(MTCompletionHandler)completionHandler
{
    exceptionCompletionHandler = completionHandler;
    
    previousUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
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
    
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL,  SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE,  SIG_DFL);
    signal(SIGBUS,  SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    NSSetUncaughtExceptionHandler(previousUncaughtExceptionHandler);
}

void handleExceptionDescription(NSMutableString *exceptionDescription)
{
    [exceptionDescription appendFormat:@"\nUUID: %@\n", get_uuid()];
    [exceptionDescription appendFormat:@"loadAddress: 0x%lx\n", get_load_address()];
    
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
    
    handleExceptionDescription(exceptionDescription);
}

void uncaughtExceptionHandler(NSException *exception)
{
    NSMutableString *exceptionDescription = [NSMutableString string];
    [exceptionDescription appendFormat:@"name:%@\n", exception.name];
    [exceptionDescription appendFormat:@"reason:%@\n",exception.reason];
    for(NSString *symbol in exception.callStackSymbols)
    {
        [exceptionDescription appendFormat:@"%@\n", symbol];
    }
    
    handleExceptionDescription(exceptionDescription);
    
    if(previousUncaughtExceptionHandler != NULL)
    {
        previousUncaughtExceptionHandler(exception);
    }
}

#pragma mark - symbolicating

uintptr_t get_load_address(void)
{
    const struct mach_header *exe_header = NULL;
    for(uint32_t idx = 0; idx < _dyld_image_count(); ++idx)
    {
        const struct mach_header *header = _dyld_get_image_header(idx);
        if (header->filetype == MH_EXECUTE)
        {
            exe_header = header;
            break;
        }
    }
    return (uintptr_t)exe_header;
}

NSString *get_uuid(void)
{
    const uint8_t *command = (const uint8_t *)(&_mh_execute_header + 1);
    for(uint32_t idx = 0; idx < _mh_execute_header.ncmds; ++idx)
    {
        if(((const struct load_command *)command)->cmd == LC_UUID)
        {
            command += sizeof(struct load_command);
            return [NSString stringWithFormat:@"%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
                    command[0], command[1], command[2], command[3],
                    command[4], command[5],
                    command[6], command[7],
                    command[8], command[9],
                    command[10], command[11], command[12], command[13], command[14], command[15]];
        }
        else
        {
            command += ((const struct load_command *)command)->cmdsize;
        }
    }
    return @"";
}

@end
