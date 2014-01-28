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
#import "JscValue.h"


@interface JscVM ()

@end


@implementation JscVM

- (instancetype)init
{
    self = [super init];
    self.context = JSGlobalContextCreate(NULL);
    self.globalObject = JSContextGetGlobalObject(self.context);
    self.exceptionHandler = ^void(JSContextRef c, JSValueRef e){
        dumpJSValue(c, e);
    };
    init_libs(self.context);
    
    return self;
}


- (JSValueRef)evalJSFile:(NSString *)filePath
{
    NSError *error = nil;
    NSString *script = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@", error);
        assert("js file error!");
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
//    dumpJSValue(self.context, ret);
    
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
//            return nil;
        }
    }
    
    if (ret) {
        return [JscValue valueWithJSValue:ret inContext:self.context];
    }
    
    return nil;
}

- (id)valueForKey:(NSString *)key
{
    JSStringRef jss = [key copyToJSStringValue];
    JSValueRef value = getJSValueFromNamePropertyArray(self.context, jss);
    JSStringRelease(jss);
    
    if (value) {
        return [JscValue valueWithJSValue:value inContext:self.context];
    } else {
        assert("shit!");
        return nil;
    }
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    JscValue *_value;
    
    if ([value isKindOfClass:[JscValue class]]) {
        _value = (JscValue *)value;
    } else if ([value isKindOfClass:[NSString class]]) {
        _value = [JscValue valueWithString:value inContext:self.context];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        _value = [JscValue valueWithDouble:[value doubleValue] inContext:self.context];
    } else {
        assert("value class not support!");
    }
    
    [_value setWithPropertyName:key toJSObject:self.globalObject];
}


#pragma mark -


@end
