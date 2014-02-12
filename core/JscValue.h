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

@property (nonatomic, readonly, getter = prototype) JscValue *prototype;
@property (nonatomic) JSValueRef jsv;
@property (nonatomic) JSContextRef context;

- (JscValue *)initWithJSValue:(JSValueRef)jsv inContext:(JSContextRef)context;
+ (JscValue *)valueWithJSValue:(JSValueRef)jsv inContext:(JSContextRef)context;

- (JscValue *)initWithDouble:(double)number inContext:(JSContextRef)context;
+ (JscValue *)valueWithDouble:(double)number inContext:(JSContextRef)context;

- (JscValue *)initWithString:(NSString *)string inContext:(JSContextRef)context;
+ (JscValue *)valueWithString:(NSString *)string inContext:(JSContextRef)context;

- (JscValue *)callWithArgs:(NSArray *)args;
- (JscValue *)callAsConstructorWithArgs:(NSArray *)args;
- (JscValue *)callFunction:(NSString *)functionName withArgs:(NSArray *)args;
//- (void)setWithPropertyName:(NSString *)propertyName toJSObject:(JSObjectRef)obj;
//- (void)setWithPropertyName:(NSString *)propertyName toJSObjectPrototype:(JSObjectRef)obj;

- (void)setJSValue:(JscValue *)value forPropertyName:(NSString *)name;
- (JscValue *)JSValueForPropertyName:(NSString *)name;

- (NSString *)stringValue;
- (NSNumber *)numberValue;
- (JSValueRef)JSValue;
- (JSObjectRef)JSObject;

@end
