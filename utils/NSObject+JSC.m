//
//  NSObject+JSC.m
//  JscWrapper
//
//  Created by ikamobile on 1/28/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "NSObject+JSC.h"
#import "NSString+JSC.h"


@implementation NSObject (JSC)

- (JSValueRef)jsvalueInContext:(JSContextRef)context
{
    JSValueRef ret = NULL;
    
    if ([self isKindOfClass:[NSNumber class]]) {
        ret = JSValueMakeNumber(context, [(NSNumber *)self doubleValue]);
    } else if ([self isKindOfClass:[NSString class]]) {
        JSStringRef jss = [(NSString *)self copyToJSStringValue];
        ret = JSValueMakeString(context, jss);
        JSStringRelease(jss);
    } else if ([self isKindOfClass:[NSValue class]]){
        ret = [(NSValue *)self pointerValue];
    }
    
    return ret;
}

@end
