//
//  TFDomWrap.m
//  JscWrapper
//
//  Created by ikamobile on 1/27/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "JscLib.h"
#import "TFDom.h"
#import "JavaScriptCore.h"
#import "NSString+JSC.h"

JSValueRef selectNodeTextWrap(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    if (argumentCount != 2) {
        return JSValueMakeNull(ctx);
    }
    
    JSValueRef html = arguments[0];
    JSValueRef xpath = arguments[1];
    
    NSString *ret = [TFDom stringWithXPathQuery:[NSString stringWithJSValue:xpath inContext:ctx] inHtml:[NSString stringWithJSValue:html inContext:ctx]];
    JSValueRef r = JSValueMakeString(ctx, [ret copyToJSStringValue]);
    
    return r;
}


JSValueRef selectNodeSetWrap(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    if (argumentCount != 2) {
        return JSValueMakeNull(ctx);
    }
    
    JSValueRef html = arguments[0];
    JSValueRef xpath = arguments[1];
    
    NSString *ret = [TFDom stringsWithXPathQuery:[NSString stringWithJSValue:xpath inContext:ctx] inHtml:[NSString stringWithJSValue:html inContext:ctx]];
    JSValueRef r = JSValueMakeString(ctx, [ret copyToJSStringValue]);
    
    return r;
}


void init_dom(JSContextRef context, JSStringRef name)
{
    JSObjectRef globalObj = JSContextGetGlobalObject(context);
    JSObjectRef domObj = JSObjectMake(context, NULL, NULL);
    JSObjectRef domFunctionObj = JSObjectMakeFunctionWithCallback(context, NULL, selectNodeTextWrap);
    JSObjectRef domFunctionObj2 = JSObjectMakeFunctionWithCallback(context, NULL, selectNodeSetWrap);
    
    JSStringRef propertyName = JSStringCreateWithUTF8CString("selectNodeText");
    JSObjectSetProperty(context, domObj, propertyName, domFunctionObj, 0, NULL);
    JSStringRelease(propertyName);
    propertyName = JSStringCreateWithUTF8CString("selectNodeSet");
    JSObjectSetProperty(context, domObj, propertyName, domFunctionObj2, 0, NULL);
    JSStringRelease(propertyName);
    JSObjectSetProperty(context, globalObj, name, domObj, 0, NULL);
}
