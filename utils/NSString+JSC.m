//
//  NSString+JSC.m
//  JscWrapper
//
//  Created by ikamobile on 1/26/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "NSString+JSC.h"


@implementation NSString (JSValue)

+ (NSString *)stringWithJSValue:(JSValueRef)jsv inContext:(JSContextRef)context
{
    JSStringRef jss = JSValueToStringCopy(context, jsv, NULL);
    return [self stringWithJSString:jss];
}

@end


@implementation NSString (JSString)

- (JSStringRef)copyToJSStringValue
{
    return JSStringCreateWithUTF8CString([self UTF8String]);
}

+ (NSString *)stringWithJSString:(JSStringRef)jss
{
    return (__bridge_transfer NSString *)JSStringCopyCFString(NULL, jss);
}

@end

