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


@interface JscValue ()

@property (nonatomic) JSValueRef jsv;
@property (nonatomic) JSContextRef context;
@property (nonatomic, strong) NSObject *innerValue;

@end


@implementation JscValue

#pragma mark - init

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

- (JscValue *)initWithJSValue:(JSValueRef)jsv inContext:(JSContextRef)context
{
    self = [super init];
    
    if (self) {
        self.jsv = jsv;
        self.context = context;
        self.innerValue = [self.class createWithJSValue:jsv inContext:context];
    }
    
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


#pragma mark -

+ (NSObject *)createWithJSValue:(JSValueRef)jsv inContext:(JSContextRef)context
{
    NSObject *ret;
    
    switch (JSValueGetType(context, jsv)) {
        case kJSTypeBoolean:
        {
            bool v = JSValueToBoolean(context, jsv);
            ret = [NSNumber numberWithBool:v==true?YES:NO];
            break;
        }
    
        case kJSTypeNumber:
        {
            JSValueRef e = NULL;
            double v = JSValueToNumber(context, jsv, &e);
            ret = [NSNumber numberWithDouble:v];
            break;
        }
        
        case kJSTypeString:
        {
            JSValueRef e = NULL;
            JSStringRef s = JSValueToStringCopy(context, jsv, &e);
            ret = (__bridge_transfer NSString *)JSStringCopyCFString(NULL, s);
            break;
        }
            
        case kJSTypeNull:
        {
            ret = [NSValue valueWithBytes:(void *)[NSNull null] objCType:"NSNull"];
            break;
        }

        case kJSTypeUndefined:
        {
            ret = nil;
            break;
        }
        
        case kJSTypeObject:
        {
            JSValueRef e = NULL;
            JSObjectRef obj = JSValueToObject(context, jsv, &e);

            if (JSObjectIsFunction(context, obj)) {
                
            } else {
                assert("not support!");
            }
        }
            
        default:
            ret = nil;
            break;
    }
    
    return ret;
}


- (JscValue *)callWithArgs:(NSArray *)args
{
    if (JSValueGetType(self.context, self.jsv) != kJSTypeObject) {
        assert("not a JSObject");
        return nil;
    }
    
    JSValueRef e = NULL;
    JSObjectRef obj = JSValueToObject(self.context, self.jsv, &e);
    if (e) {
        assert("not a JSObject");
        return nil;
    }
    
    if (!JSObjectIsFunction(self.context, obj)) {
        assert("not a function");
        return nil;
    }
    
    e = NULL;
    
    JSValueRef a[10] = {0};
    for (size_t i = 0; i < [args count]; i++) {
        a[i] = [args[i] jsvalueInContext:self.context];
    }
    
    JSValueRef ret = JSObjectCallAsFunction(self.context, obj, NULL, [args count], a, &e);
    if (e) {
        assert("error in call function!");
    }
    
    return [JscValue valueWithJSValue:ret inContext:self.context];
}

- (void)setWithPropertyName:(NSString *)propertyName toJSObject:(JSObjectRef)obj
{
    JSStringRef jss = [propertyName copyToJSStringValue];
    JSValueRef e = NULL;
    JSObjectSetProperty(self.context, obj, jss, self.jsv, kJSPropertyAttributeNone, &e);
    if (e) {
        assert("shit");
    }
}

@end
