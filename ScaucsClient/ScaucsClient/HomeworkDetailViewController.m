//
//  HomeworkDetailViewController.m
//  ScaucsClient
//
//  Created by yufu on 14-5-11.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "HomeworkDetailViewController.h"

@interface HomeworkDetailViewController ()


@property (strong, nonatomic) IBOutlet UIWebView *webView;


@end

@implementation HomeworkDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"%s %d", __FUNCTION__, __LINE__);
    NSString* time = @"截止时间为：";
    [_webView loadHTMLString:time baseURL:nil];
    [_webView loadHTMLString:_htmlString baseURL:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
