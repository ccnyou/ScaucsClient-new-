//
//  HomeworkViewController.m
//  ScaucsClient
//
//  Created by yufu on 14-5-11.
//  Copyright (c) 2014年 ccnyou. All rights reserved.
//

#import "HomeworkViewController.h"
#import "PullingRefreshTableView.h"
#import "ScaucsSession.h"
#import "ServiceClient.h"
#import "HomeworkDetailViewController.h"

@interface HomeworkViewController ()<UITableViewDataSource, UITableViewDelegate,
PullingRefreshTableViewDelegate, ServiceClientDelegate>

@property (nonatomic, strong) PullingRefreshTableView* tableView;
@property (nonatomic, strong) NSArray* courses;
@property (nonatomic, strong) ServiceClient* client;
@property (nonatomic, strong) NSIndexPath* lastSelectedIndexPath;

@end


@implementation HomeworkViewController

- (void)awakeFromNib//如果不用xib文件的话用initWithFrame做初始化，用xib的化用awakeFromNib初始化,这样的理解没问题吧。。
{
    _client = [[ServiceClient alloc] init];
    _client.delegate = self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil//也是使用xib时候使用的初始化方法。
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _client = [[ServiceClient alloc] init];
        _client.delegate = self;
    }
    return self;
}

- (void)viewDidLoad     //当view对象被加载到内存时就会执行viewDidLoad,所以不管是通过.nib文件还是以代码的方式创建对象都会执行viewDidLoad。
{
    [super viewDidLoad];
	// Do any addition setup after loading the view.
    
    //设置PullingRefreshTablevie 各种属性
    _tableView = [[PullingRefreshTableView alloc] initWithFrame:self.view.bounds pullingDelegate:self];
    _tableView.frame = CGRectMake(0, 65, 350, 700);
    _tableView.headerOnly = YES;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [_tableView launchRefreshing];//手动控制出现下拉刷新界面
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender //是在跳转时，新的View显示之前被调用。
{
    HomeworkDetailViewController* dest = segue.destinationViewController;
    NSArray* arr = [_courses objectAtIndex:_lastSelectedIndexPath.row];
    NSString* className = arr[1];
    NSString* jobName = arr[2];
    NSString* type = arr[3];
    NSString* time = arr[4];
    NSString* subFileType = arr[5];
    NSString* subState = arr[6];
    NSString* htmlS = [[NSString alloc] initWithFormat:@"%@%@ <br> %@%@ <br> %@%@ <br> %@%@ <br> %@%@ <br> %@%@ <br>",@"课程名称", className, @"作业名称：", jobName, @"作业类型：", type, @"截止时间：", time,@"需提交文件：",subFileType,@"提交状态:",subState];
    
    dest.htmlString = htmlS;
    NSLog(@"%s %d %@", __FUNCTION__, __LINE__, time);
    NSLog(@"%s %d %@", __FUNCTION__, __LINE__, htmlS);
}

- (void)loadData//下拉时的更新函数
{
    ScaucsSession* session = [ScaucsSession sharedSession];
    [_client getMyHomeWorkDetailAsync:session.userName andSession:session.session];
}

#pragma mark - Service Delegate
- (void)serviceClient:(ServiceClient *)client getMyHomeWorkDetailCompletedWithResult:(NSArray *)result
{
    _courses = result;
    [_tableView tableViewDidFinishedLoading];
    [_tableView reloadData];
}

- (void)serviceClient:(ServiceClient *)client getMyHomeWorkDetailFailedWithError:(NSError *)error
{
    NSLog(@"%s %d %@", __FUNCTION__, __LINE__, error);
    [_tableView tableViewDidFinishedLoadingWithMessage:error.localizedDescription];
}

#pragma mark - ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.tableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.tableView tableViewDidEndDragging:scrollView];
}

#pragma mark - TableView

- (void)onSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* arr = [_courses objectAtIndex:indexPath.row];
    NSString* htmlString = arr[4];
     NSLog(@"%s %d %@", __FUNCTION__, __LINE__, htmlString);
    
    if (htmlString.length) {
        _lastSelectedIndexPath = indexPath;
        [self performSegueWithIdentifier:@"viewDetailForHomework" sender:self];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSelector:@selector(onSelectRowAtIndexPath:) withObject:indexPath afterDelay:0.5f];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _courses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identify = @"Course Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    int row = indexPath.row;
    if (row > _courses.count) {
        cell.textLabel.text = @"出错了";
        return cell;
    }
    
    NSArray* arr = [_courses objectAtIndex:row];
    if (arr.count == 1) {
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"出错了" message:arr[0] delegate:nil cancelButtonTitle:@"我错了- -" otherButtonTitles:nil];
        [alertView show];
        
        return cell;
    }
    
    NSArray* stuff = @[arr[0], arr[1], arr[2]];
    NSString* text = [stuff componentsJoinedByString:@" - "];
    
    cell.textLabel.text = text;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    return cell;
}

#pragma mark - Pulling Refresh Table View Delegate
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView
{
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];
}

- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView
{
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];
}

@end
