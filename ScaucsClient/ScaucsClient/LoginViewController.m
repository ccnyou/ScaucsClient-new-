//
//  ViewController.m
//  ScaucsClient
//
//  Created by ccnyou on 14-4-1.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "LoginViewController.h"
#import "ServiceClient.h"
#import "MBProgressHUD.h"
#import "ScaucsSession.h"


@interface LoginViewController () <ServiceClientDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) IBOutlet UITextField* userNameTextField;
@property (nonatomic, strong) IBOutlet UITextField* passwordTextField;

@property (nonatomic, strong) NSCondition* condition;
@property (nonatomic, strong) ServiceClient* client;
@property (nonatomic, strong) MBProgressHUD* hud;

@end

@implementation LoginViewController

- (void)awakeFromNib
{
    _condition = [[NSCondition alloc] init];
    
    _client = [[ServiceClient alloc] init];
    _client.delegate = self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _condition = [[NSCondition alloc] init];
        
        _client = [[ServiceClient alloc] init];
        _client.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
    UITextField* userNameTextField = _userNameTextField;
    userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    userNameTextField.placeholder = @"用户名";
    userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userNameTextField.returnKeyType = UIReturnKeyDone;
    
    UIImageView* userNameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1.png"]];
    userNameTextField.leftView = userNameImageView;
    userNameTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UITextField* passwordTextField = _passwordTextField;
    passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.placeholder = @"●●●●●●●●";
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextField.returnKeyType = UIReturnKeyDone;
    
    UIImageView* passwordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2.png"]];
    passwordTextField.leftView = passwordImageView;
    passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* userName = [userDefaults objectForKey:@"UserName"];
    NSString* psw = [userDefaults objectForKey:@"Password"];
    
    if (userName.length > 0) {
        _userNameTextField.text = userName;
    }
    
    if (psw.length > 0) {
        _passwordTextField.text = psw;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
    [hud removeFromSuperview];
    self.hud = nil;
}

#pragma mark - Action

- (IBAction)lvkang:(id)sender {
    [self performSegueWithIdentifier:@"model" sender:self];
}

- (IBAction)loginClicked:(id)sender
{
    NSString* userName = _userNameTextField.text;
    NSString* psw = _passwordTextField.text;
    NSString* pswMD5 = [ServiceClient getMD5:psw];
    
    //记住密码
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userName forKey:@"UserName"];
    [userDefaults setObject:psw forKey:@"Password"];
    [userDefaults synchronize];
    
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.delegate = self;
    hud.labelText = @"登陆中";
    hud.dimBackground = YES;
    [self.navigationController.view addSubview:hud];
    [hud show:YES];
    _hud = hud;

    [_client userLoginAsync:userName andPswMD5:pswMD5];//这里调用异步登录...主要是跳转部分没发现..后来才发现后面有个loginSuccess;
}

- (void)loginSuccess
{
    [self performSegueWithIdentifier:@"login" sender:self];
}


#pragma mark - Delegate

- (void)serviceClient:(ServiceClient *)client loginCompletedWithResult:(NSString *)result
{
    if (result.length == 3) {
        NSString* msg = [NSString stringWithFormat:@"错误代码: %@", result];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"出错了" message:msg delegate:nil cancelButtonTitle:@"我错了- -" otherButtonTitles:nil];
        [alertView show];
        
    } else {
        ScaucsSession* scaucsClient = [ScaucsSession sharedSession];
        scaucsClient.session = result;
        scaucsClient.userName = _userNameTextField.text;
        
        UIImageView *imageView;
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
        
        _hud.customView = imageView;
        _hud.mode = MBProgressHUDModeCustomView;
        _hud.labelText = @"登陆成功";
    }
    
    [_hud hide:YES afterDelay:1];
    [self performSelector:@selector(loginSuccess) withObject:nil afterDelay:1.5f];
}



- (void)serviceClient:(ServiceClient *)client loginFailedWithError:(NSError *)error
{
    [_hud hide:YES afterDelay:0.5];
}

//以下是我添加的坑爹函数***************************************************************************
- (IBAction)loginForHomework:(id)sender {
    NSString* userName = _userNameTextField.text;
    NSString* psw = _passwordTextField.text;
    NSString* pswMD5 = [ServiceClient getMD5:psw];
    
    //记住密码
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userName forKey:@"UserName"];
    [userDefaults setObject:psw forKey:@"Password"];
    [userDefaults synchronize];
    
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.delegate = self;
    hud.labelText = @"登陆中";
    hud.dimBackground = YES;
    [self.navigationController.view addSubview:hud];
    [hud show:YES];
    _hud = hud;
    
    [_client userLoginForHomeworkAsync:userName andPswMD5:pswMD5];
}





- (void)serviceClient:(ServiceClient *)client loginForHomeworkWithResult:(NSString *)result
{
    if (result.length == 3) {
        NSString* msg = [NSString stringWithFormat:@"错误代码: %@", result];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"出错了" message:msg delegate:nil cancelButtonTitle:@"我错了- -" otherButtonTitles:nil];
        [alertView show];
        
    } else {
        ScaucsSession* scaucsClient = [ScaucsSession sharedSession];
        scaucsClient.session = result;
        scaucsClient.userName = _userNameTextField.text;
        
        UIImageView *imageView;
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
        
        _hud.customView = imageView;
        _hud.mode = MBProgressHUDModeCustomView;
        _hud.labelText = @"登陆成功";
    }
    
    [_hud hide:YES afterDelay:1];
    [self performSelector:@selector(loginSuccessForHomework) withObject:nil afterDelay:1.5f];
}

- (void)loginSuccessForHomework
{
    [self performSegueWithIdentifier:@"loginForHomework" sender:self];
}

@end
