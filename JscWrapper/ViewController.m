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
    [self.vm evalJSFile:[[NSBundle mainBundle] pathForResource:@"train2" ofType:@"js"]];
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getVerifyCode)];
    self.verifyCodeView.userInteractionEnabled = YES;
    [self.verifyCodeView addGestureRecognizer:tapG];
//    dumpGlobalNamePropertyArray(self.vm.context);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self getVerifyCode];
    });
}


#pragma mark - 

- (void)getVerifyCode
{
    JSC_LOG_FUNCTION;
    
    JscValue *loginValue = [self.vm.globalJSCObject JSValueForPropertyName:@"getLoginVerificationCode"];
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
        
        JscValue *ret = [[self.vm.globalJSCObject JSValueForPropertyName:@"LoginAction"] callAsConstructorWithArgs:@[userName, passWord, verifyCode]];
        
        ret = [ret callFunction:@"run" withArgs:@[]];
//        JscValue *r = JSObjectGetProperty(gContext, gGlobalObject, [@"login" copyToJSStringValue], NULL);
        
        if (ret) {
            NSString *jsonString = [ret stringValue];
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@", d);
        }
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), b);
}


@end
