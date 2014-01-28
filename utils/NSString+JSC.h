//
//  NSString+JSC.h
//  JscWrapper
//
//  Created by ikamobile on 1/26/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JavaScriptCore.h"


@interface NSString (JSValue)

+ (NSString *)stringWithJSValue:(JSValueRef)jsv inContext:(JSContextRef)context;

@end


@interface NSString (JSString)

- (JSStringRef)copyToJSStringValue;
+ (NSString *)stringWithJSString:(JSStringRef)jss;

@end
