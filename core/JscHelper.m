//
//  JscHelper.c
//  JscWrapper
//
//  Created by ikamobile on 1/27/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//


#import "JscHelper.h"
#import "NSString+JSC.h"
#import "JscCommon.h"


JSValueRef getJSValueFromNamePropertyArray(JSContextRef ctx, JSStringRef name)
{
    JSObjectRef obj = JSContextGetGlobalObject(ctx);
    JSPropertyNameArrayRef pArr = JSObjectCopyPropertyNames(ctx, obj);
    size_t count = JSPropertyNameArrayGetCount(pArr);
    JSValueRef ret = NULL;
    for (size_t i = 0; i < count; i++) {
        JSStringRef tmp = JSPropertyNameArrayGetNameAtIndex(pArr, i);
        //        NSString *out = (__bridge_transfer NSString *)JSStringCopyCFString(NULL, tmp);
        if (JSStringIsEqual(tmp, name)) {
            ret = JSObjectGetProperty(ctx, obj, name, NULL);
            break;
        }
    }
    
    return ret;
}

void dumpJSObject(JSContextRef c, JSObjectRef obj)
{
    JSC_LOG_FUNCTION;
    
    JSPropertyNameArrayRef pArr = JSObjectCopyPropertyNames(c, obj);
    size_t count = JSPropertyNameArrayGetCount(pArr);
    for (size_t i = 0; i < count; i++) {
        JSStringRef tmp = JSPropertyNameArrayGetNameAtIndex(pArr, i);
        JSValueRef v = JSObjectGetProperty(c, obj, tmp, NULL);
        NSLog(@"%@: %@", (__bridge_transfer NSString *)JSStringCopyCFString(NULL, tmp), [NSString stringWithJSValue:v inContext:c]);
    }
}


void dumpJSValue(JSContextRef c, JSValueRef v)
{
    JSC_LOG_FUNCTION;
    
    if (v == NULL) {
        NSLog(@"value is NULL!");
        return;
    }
    
    switch (JSValueGetType(c, v)) {
        case kJSTypeString:
        {
            JSStringRef jss = JSValueToStringCopy(c, v, NULL);
            
            NSLog(@"%@", JSStringCopyCFString(NULL, jss));
            break;
        }
            
        case kJSTypeObject:
        {
            JSObjectRef obj = JSValueToObject(c, v, NULL);
            if (JSObjectIsFunction(c, obj)) {
                //                JSValueRef v = JSObjectCallAsFunction(c, obj, NULL, 0, NULL, NULL);
                //                dumpJSValue(c, v);
            } else {
                dumpJSObject(c, obj);
            }
            break;
        }
        case kJSTypeBoolean:
        {
            NSNumber *b = [NSNumber numberWithBool:JSValueToBoolean(c, v)];
            NSLog(@"%@", b);
            break;
        }
        case kJSTypeNumber:
        {
            NSNumber *d = [NSNumber numberWithDouble:JSValueToNumber(c, v, NULL)];
            NSLog(@"%@", d);
            break;
        }
        case kJSTypeNull:
        {
            NSLog(@"null");
            break;
        }
        case kJSTypeUndefined:
        {
            NSLog(@"undefined");
            break;
        }
        default:
            break;
    }
}


void dumpGlobalNamePropertyArray(JSContextRef c)
{
    JSC_LOG_FUNCTION;
    
    JSObjectRef obj = JSContextGetGlobalObject(c);
    JSPropertyNameArrayRef pArr = JSObjectCopyPropertyNames(c, obj);
    size_t count = JSPropertyNameArrayGetCount(pArr);
    for (size_t i = 0; i < count; i++) {
        JSStringRef tmp = JSPropertyNameArrayGetNameAtIndex(pArr, i);
        NSLog(@"%@", (__bridge_transfer NSString *)JSStringCopyCFString(NULL, tmp));
    }
}
