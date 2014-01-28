//
//  ViewController.m
//  JscWrapper
//
//  Created by ikamobile on 1/26/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "ViewController.h"

#import "JscVM.h"


@interface ViewController ()

@property (strong, nonatomic) JscVM *vm;
@property (weak, nonatomic) IBOutlet UIImageView *verifyCodeView;
@property (weak, nonatomic) IBOutlet UITextField *inputField3;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.vm = [[JscVM alloc] init];
    [self.vm evalJSFile:[[NSBundle mainBundle] pathForResource:@"hello" ofType:@"js"]];
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getVerifyCode)];
    self.verifyCodeView.userInteractionEnabled = YES;
    [self.verifyCodeView addGestureRecognizer:tapG];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self getVerifyCode];
    });
    self.view.backgroundColor = [UIColor redColor];
}


#pragma mark - 

- (void)getVerifyCode
{
    JSC_LOG_FUNCTION;
    JSContextRef gContext = self.vm.context;
    JSObjectRef gGlobalObject = self.vm.globalObject;
    
    JSValueRef loginValue = JSObjectGetProperty(gContext, gGlobalObject, [@"getLoginVerificationCode" copyToJSStringValue], NULL);
    if (JSValueIsObject(gContext, loginValue)) {
        JSObjectRef loginFunc = JSValueToObject(gContext, loginValue, NULL);
        if (JSObjectIsFunction(gContext, loginFunc)) {
            JSValueRef ret = JSObjectCallAsFunction(gContext, loginFunc, NULL, 0, NULL, NULL);
            
            NSData *data = [[NSData alloc] initWithBase64Encoding:[NSString stringWithJSValue:ret inContext:self.vm.context]];
//            dispatch_async(dispatch_get_main_queue(), ^{
                self.verifyCodeView.image = [UIImage imageWithData:data];
            [self.verifyCodeView setNeedsDisplay];
            self.view.backgroundColor = [UIColor blackColor];
                self.verifyCodeView.contentMode = UIViewContentModeCenter;
//            });
        }
    }
}

- (IBAction)login:(id)sender
{
    void (^b)() = ^void() {
        NSString *userName = @"falcon_cjj";
        NSString *passWord = @"asdasd_";
        NSString *verifyCode = self.inputField3.text;
        
        JSContextRef gContext = self.vm.context;
        JSObjectRef gGlobalObject = self.vm.globalObject;
        
        JSValueRef r = JSObjectGetProperty(gContext, gGlobalObject, [@"login" copyToJSStringValue], NULL);
        
        if (JSValueIsObject(gContext, r)) {
            JSObjectRef funcObj = JSValueToObject(gContext, r, NULL);
            
            JSValueRef v1 = JSValueMakeString(gContext, [userName copyToJSStringValue]);
            JSValueRef v2 = JSValueMakeString(gContext, [passWord copyToJSStringValue]);
            JSValueRef v3 = JSValueMakeString(gContext, [verifyCode copyToJSStringValue]);
            
            if (JSObjectIsFunction(gContext, funcObj)) {
                JSValueRef argList[] = {v1, v2, v3};
                JSValueRef e = NULL;
                JSValueRef ret = JSObjectCallAsFunction(gContext, funcObj, NULL, 3, argList, &e);
                
                if (e) {
                    dumpJSValue(gContext, e);
                    assert("e");
                } else {
                    //                dumpJSValue(gContext, ret);
                    NSString *jsonString = [NSString stringWithJSValue:ret inContext:self.vm.context];
                    NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"%@", d);
                }
            }
        }
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), b);
}


@end
