//
//  JscValue.m
//  JscWrapper
//
//  Created by ikamobile on 1/28/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "JscValue.h"
#import "NSObject+JSC.h"
#import "NSString+JSC.h"
#import "JscHelper.h"


@interface JscValue ()

@end


@implementation JscValue

#pragma mark - init

/*
 static wrapper
 */
+ (JscValue *)valueWithJSValue:(JSValueRef)jsv inContext:(JSContextRef)context
{
    return [[self alloc] initWithJSValue:jsv inContext:context];
}

+ (JscValue *)valueWithDouble:(double)number inContext:(JSContextRef)context
{
    return [[self alloc] initWithDouble:number inContext:context];
}

+ (JscValue *)valueWithString:(NSString *)string inContext:(JSContextRef)context
{
    return [[self alloc] initWithString:string inContext:context];
}

/*
 common initializer
 */
- (JscValue *)initWithJSValue:(JSValueRef)jsv inContext:(JSContextRef)context
{
    self = [super init];
    
    if (self) {
        self.jsv = jsv;
        self.context = context;   }
    
    return self;
}

- (JscValue *)initWithDouble:(double)number inContext:(JSContextRef)context
{
    JSValueRef jsv = JSValueMakeNumber(context, number);
    
    return [self initWithJSValue:jsv inContext:context];
}


- (JscValue *)initWithString:(NSString *)string inContext:(JSContextRef)context
{
    JSStringRef jss = [string copyToJSStringValue];
    JSValueRef jsv = JSValueMakeString(context, jss);
    JSStringRelease(jss);
    
    return [self initWithJSValue:jsv inContext:context];
}


#pragma mark - public

- (JscValue *)callFunction:(NSString *)functionName withArgs:(NSArray *)args
{
    if (JSValueGetType(self.context, self.jsv) != kJSTypeObject) {
        assert(0);
        return nil;
    }
    
    JSValueRef e = NULL;
    JSObjectRef obj = JSValueToObject(self.context, [self JSValueForPropertyName:functionName].jsv, &e);
    assert(!e);
    if (e) {
        dumpJSValue(self.context, e);
        return nil;
    }
    
    if (!JSObjectIsFunction(self.context, obj)) {
        assert(0);
        return nil;
    }
    
    e = NULL;
    
    JSValueRef a[10] = {0};
    for (size_t i = 0; i < [args count]; i++) {
        a[i] = [args[i] jsvalueInContext:self.context];
    }
    
    JSObjectRef thisObj = JSValueToObject(self.context, self.jsv, &e);
    assert(!e);
    
    JSValueRef ret = JSObjectCallAsFunction(self.context, obj, thisObj, [args count], a, &e);
    if (e) {
        dumpJSValue(self.context, e);
    }
    
    return [JscValue valueWithJSValue:ret inContext:self.context];
}

- (JscValue *)callWithArgs:(NSArray *)args
{
    if (JSValueGetType(self.context, self.jsv) != kJSTypeObject) {
        assert(0);
        return nil;
    }
    
    JSValueRef e = NULL;
    JSObjectRef obj = JSValueToObject(self.context, self.jsv, &e);
    if (e) {
        assert(0);
        return nil;
    }
    
    if (!JSObjectIsFunction(self.context, obj)) {
        assert(0);
        return nil;
    }
    
    e = NULL;
    
    JSValueRef a[10] = {0};
    for (size_t i = 0; i < [args count]; i++) {
        a[i] = [args[i] jsvalueInContext:self.context];
    }
    
    JSValueRef ret = JSObjectCallAsFunction(self.context, obj, NULL, [args count], a, &e);
    if (e) {
        dumpJSValue(self.context, e);
    }
    
    return [JscValue valueWithJSValue:ret inContext:self.context];
}

- (JscValue *)callAsConstructorWithArgs:(NSArray *)args
{
    if (JSValueGetType(self.context, self.jsv) != kJSTypeObject) {
        assert(0);
        return nil;
    }
    
    JSValueRef e = NULL;
    JSObjectRef obj = JSValueToObject(self.context, self.jsv, &e);
    if (e) {
        assert(0);
        return nil;
    }
    
    if (!JSObjectIsConstructor(self.context, obj)) {
        assert(0);
        return nil;
    }
    
    e = NULL;
    
    JSValueRef a[10] = {0};
    for (size_t i = 0; i < [args count]; i++) {
        a[i] = [args[i] jsvalueInContext:self.context];
    }
    
    JSValueRef ret = JSObjectCallAsConstructor(self.context, obj, [args count], a, &e);
    if (e) {
        dumpJSValue(self.context, e);
    }
    
    return [JscValue valueWithJSValue:ret inContext:self.context];
}

- (void)setWithPropertyName:(NSString *)propertyName toJSObject:(JSObjectRef)obj
{
    JSStringRef jss = [propertyName copyToJSStringValue];
    JSValueRef e = NULL;
    JSObjectSetProperty(self.context, obj, jss, self.jsv, kJSPropertyAttributeNone, &e);
    assert(!e);
}

- (void)setWithPropertyName:(NSString *)propertyName toJSObjectPrototype:(JSObjectRef)obj
{
    JSValueRef e = NULL;
    JSObjectRef o = JSValueToObject(self.context, obj, &e);
    assert(!e);
    JSStringRef name = [propertyName copyToJSStringValue];
    setPrototypeProptertyForObject(self.context, o, obj, name);
    JSStringRelease(name);
}

- (void)setJSValue:(JscValue *)value forPropertyName:(NSString *)name
{
    JSValueRef e = NULL;
    JSObjectRef o = JSValueToObject(self.context, self.jsv, &e);
    JSStringRef names = [name copyToJSStringValue];
    assert(!e);
    
    e = NULL;
    JSObjectSetProperty(self.context, o, names, value.jsv, kJSPropertyAttributeNone, &e);
    JSStringRelease(names);
    assert(!e);
}

- (JscValue *)JSValueForPropertyName:(NSString *)name
{
    JSValueRef e = NULL;
    JSObjectRef o = JSValueToObject(self.context, self.jsv, &e);
    JSStringRef sname = [name copyToJSStringValue];
    assert(!e);
    
    e = NULL;
    JSValueRef ret = JSObjectGetProperty(self.context, o, sname, &e);
    JSStringRelease(sname);
    return [JscValue valueWithJSValue:ret inContext:self.context];
}

- (JscValue *)prototype
{
    JSValueRef e = NULL;
    JSObjectRef o = JSValueToObject(self.context, self.jsv, &e);
    assert(!e);
    
    if (!e) {
        JSValueRef ret = JSObjectGetPrototype(self.context, o);
        return [JscValue valueWithJSValue:ret inContext:self.context];
    } else {
        return nil;
    }
}

- (NSString *)stringValue
{
    if (JSValueGetType(self.context, self.jsv) == kJSTypeString) {
        return [NSString stringWithJSValue:self.jsv inContext:self.context];
    } else {
        assert(0);
        return nil;
    }
}

- (NSNumber *)numberValue
{
    if (JSValueGetType(self.context, self.jsv) == kJSTypeNumber) {
        JSValueRef e = NULL;
        double number = JSValueToNumber(self.context, self.jsv, &e);
        
        assert(!e);
        if (e) {
            
            return nil;
        }
        
        return [NSNumber numberWithDouble:number];
    } else {
        assert(0);
        return nil;
    }
}


@end
