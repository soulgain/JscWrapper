//
//  TFConsoleWrap.m
//  JscWrapper
//
//  Created by ikamobile on 2/12/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "JscLib.h"
#import "NSString+JSC.h"


JSValueRef consoleLogWrap(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    assert(argumentCount);
    JSValueRef string = arguments[0];
    NSString *logString = [NSString stringWithJSValue:string inContext:ctx];
    NSLog(@"%@", logString);
    
    return JSValueMakeUndefined(ctx);
}

void init_console(JSContextRef context, JSStringRef name)
{
    JSObjectRef globalObject = JSContextGetGlobalObject(context);
    JSObjectRef consoleObj = JSObjectMake(context, NULL, NULL);
    
    JSStringRef propertyName = JSStringCreateWithUTF8CString("log");
    JSObjectRef logFunctionObj = JSObjectMakeFunctionWithCallback(context, propertyName, consoleLogWrap);
    JSValueRef e = NULL;
    JSObjectSetProperty(context, consoleObj, propertyName, logFunctionObj, kJSPropertyAttributeNone, &e);
    JSStringRelease(propertyName);
    assert(!e);
    
    propertyName = JSStringCreateWithUTF8CString("console");
    e = NULL;
    JSObjectSetProperty(context, globalObject, propertyName, consoleObj, kJSPropertyAttributeNone, &e);
    assert(!e);
}