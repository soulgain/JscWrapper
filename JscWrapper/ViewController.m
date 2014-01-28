//
//  ViewController.m
//  JscWrapper
//
//  Created by ikamobile on 1/26/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "ViewController.h"

#import "JscVM.h"
#import "JscValue.h"


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

}


#pragma mark - 

- (void)getVerifyCode
{
    JSC_LOG_FUNCTION;
    
    JscValue *loginValue = [self.vm valueForKey:@"getLoginVerificationCode"];
    JscValue *ret = [loginValue callWithArgs:@[]];
    
    NSData *data = [[NSData alloc] initWithBase64Encoding:[ret stringValue]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.verifyCodeView.image = [UIImage imageWithData:data];
        self.verifyCodeView.contentMode = UIViewContentModeCenter;
    });
}

- (IBAction)login:(id)sender
{
    void (^b)() = ^void() {
        NSString *userName = @"falcon_cjj";
        NSString *passWord = @"asdasd_";
        NSString *verifyCode = self.inputField3.text;
        
        JscValue *ret = [[self.vm valueForKey:@"login"] callWithArgs:@[userName, passWord, verifyCode]];
        
//        JscValue *r = JSObjectGetProperty(gContext, gGlobalObject, [@"login" copyToJSStringValue], NULL);
        
        if (ret) {
            NSString *jsonString = [ret stringValue];
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@", d);
        }
        
//        if (JSValueIsObject(gContext, r)) {
//            JSObjectRef funcObj = JSValueToObject(gContext, r, NULL);
//            
//            JSValueRef v1 = JSValueMakeString(gContext, [userName copyToJSStringValue]);
//            JSValueRef v2 = JSValueMakeString(gContext, [passWord copyToJSStringValue]);
//            JSValueRef v3 = JSValueMakeString(gContext, [verifyCode copyToJSStringValue]);
//            
//            if (JSObjectIsFunction(gContext, funcObj)) {
//                JSValueRef argList[] = {v1, v2, v3};
//                JSValueRef e = NULL;
//                JSValueRef ret = JSObjectCallAsFunction(gContext, funcObj, NULL, 3, argList, &e);
//                
//                if (e) {
//                    dumpJSValue(gContext, e);
//                    assert("e");
//                } else {
//                    //                dumpJSValue(gContext, ret);
//                    NSString *jsonString = [NSString stringWithJSValue:ret inContext:self.vm.context];
//                    NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//                    NSLog(@"%@", d);
//                }
//            }
//        }
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), b);
}


@end
