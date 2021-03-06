//
//  JscVM.m
//  JscWrapper
//
//  Created by ikamobile on 1/26/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "JscVM.h"
#import "JscHelper.h"
#import "JscLib.h"


@interface JscVM ()

@end


@implementation JscVM

- (instancetype)init
{
    self = [super init];
    
    self.context = JSGlobalContextCreate(NULL);
    self.exceptionHandler = ^void(JSContextRef c, JSValueRef e){
        dumpJSValue(c, e);
    };
    init_libs(self.context);
    
    return self;
}


- (JSValueRef)evalJSFile:(NSString *)filePath
{
    assert(filePath);
    NSError *error = nil;
    NSString *script = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    return [self evalJSString:script];
}


- (JSValueRef)evalJSString:(NSString *)script;
{
    JSStringRef t = JSStringCreateWithUTF8CString([script UTF8String]);
    JSValueRef exception = NULL;
    JSValueRef ret = JSEvaluateScript(self.context, t, NULL, NULL, 0, &exception);
    JSStringRelease(t);
    
    if (exception && self.exceptionHandler) {
        self.exceptionHandler(self.context, exception);
    }
    
    return ret;
}

- (JscValue *)objectInGlobalObjectAtIndex:(NSUInteger)index
{
    JSObjectRef globalObject = JSContextGetGlobalObject(self.context);
    JSPropertyNameArrayRef nameArr = JSObjectCopyPropertyNames(self.context, globalObject);
    size_t count = JSPropertyNameArrayGetCount(nameArr);
    
    JSValueRef ret = NULL;
    if (index < count) {
        JSValueRef e = NULL;
        ret = JSObjectGetPropertyAtIndex(self.context, globalObject, index, &e);
        if (e) {
            self.exceptionHandler(self.context, e);
        }
    }
    
    if (ret) {
        return [JscValue valueWithJSValue:ret inContext:self.context];
    }
    
    return nil;
}

- (JscValue *)globalJSCObject
{
    return [JscValue valueWithJSValue:JSContextGetGlobalObject(self.context) inContext:self.context];
}

@end
