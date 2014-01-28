//
//  JscValue.h
//  JscWrapper
//
//  Created by ikamobile on 1/28/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JavaScriptCore.h"


@interface JscValue : NSObject

- (JscValue *)initWithJSValue:(JSValueRef)jsv inContext:(JSContextRef)context;
+ (JscValue *)valueWithJSValue:(JSValueRef)jsv inContext:(JSContextRef)context;

- (JscValue *)initWithDouble:(double)number inContext:(JSContextRef)context;
+ (JscValue *)valueWithDouble:(double)number inContext:(JSContextRef)context;

- (JscValue *)initWithString:(NSString *)string inContext:(JSContextRef)context;
+ (JscValue *)valueWithString:(NSString *)string inContext:(JSContextRef)context;

- (JscValue *)callWithArgs:(NSArray *)args;
- (void)setWithPropertyName:(NSString *)propertyName toJSObject:(JSObjectRef)obj;

@end
