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

- (id)objectInGlobalObjectAtIndex:(NSUInteger)index
{
    JSObjectRef globalObject = JSContextGetGlobalObject(self.context);
    JSPropertyNameArrayRef nameArr = JSObjectCopyPropertyNames(self.context, globalObject);
    size_t count = JSPropertyNameArrayGetCount(nameArr);
    
    if (index < count) {
        JSValueRef e = NULL;
        JSValueRef ret = JSObjectGetPropertyAtIndex(self.context, globalObject, index, &e);
        if (e) {
            self.exceptionHandler(self.context, e);
//            return nil;
        }
    }
    
    if (ret) {
         JSValueGetType(self.context, ret);
    }
    
    return nil;
}


-(void)setValue:(id)value forKey:(NSString *)key
{

}

-(instancetype)valueForKey:(NSString *)key
{
    return nil;
}


#pragma mark -


@end
