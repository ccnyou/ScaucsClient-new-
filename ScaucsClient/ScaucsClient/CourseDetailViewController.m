//
//  CourseDetailViewController.m
//  ScaucsClient
//
//  Created by ccnyou on 14-4-7.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "CourseDetailViewController.h"

@interface CourseDetailViewController ()

@property (nonatomic, strong) IBOutlet UIWebView* webView;

@end

@implementation CourseDetailViewController

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
    [_webView loadHTMLString:_htmlString baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
