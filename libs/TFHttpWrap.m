//
//  TFHttpWrap.m
//  JscWrapper
//
//  Created by ikamobile on 1/27/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "JscLib.h"
#import "TFHttp2.h"
#import "NSString+JSC.h"


JSValueRef sendRequestWrap(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    if (argumentCount == 0) {
        assert("arg error");
        return JSValueMakeUndefined(ctx);
    }
    
    JSValueRef jsReqString = arguments[0];
    NSString *reqString = (__bridge_transfer NSString *)JSStringCopyCFString(NULL, JSValueToStringCopy(ctx, jsReqString, NULL));
    
    NSString *ret = [TFHttp2 sendRequest:reqString];
    
    return JSValueMakeString(ctx, [ret copyToJSStringValue]);
}


JSValueRef getStreamWrap(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    if (argumentCount == 0) {
        assert("arg error");
        return JSValueMakeUndefined(ctx);
    }
    
    JSValueRef jsReqString = arguments[0];
    NSString *reqString = (__bridge_transfer NSString *)JSStringCopyCFString(NULL, JSValueToStringCopy(ctx, jsReqString, NULL));
    
    NSData *ret = [TFHttp2 getStream:reqString];
    NSString *retString = [ret base64Encoding];
    
    return JSValueMakeString(ctx, [retString copyToJSStringValue]);
}


void init_http(JSContextRef context, JSStringRef name)
{
    JSObjectRef globalObj = JSContextGetGlobalObject(context);
    JSObjectRef httpObj = JSObjectMake(context, NULL, NULL);
    JSObjectRef sendFunctionObj = JSObjectMakeFunctionWithCallback(context, NULL, sendRequestWrap);
    JSObjectRef getStreamFunctionObj = JSObjectMakeFunctionWithCallback(context, NULL, getStreamWrap);
    
    JSObjectSetProperty(context, httpObj, [@"sendRequest" copyToJSStringValue], sendFunctionObj, 0, NULL);
    JSObjectSetProperty(context, httpObj, [@"getStream" copyToJSStringValue], getStreamFunctionObj, 0, NULL);
    JSObjectSetProperty(context, globalObj, name, httpObj, 0, NULL);
}
