//
//  NewsListController.m
//  知乎日报Light
//
//  Created by 刘奕伦 on 15/11/21.
//  Copyright © 2015年 Yilun Liu. All rights reserved.
//

#import "NewsListController.h"
#import "NewsListController.h"
#import "NewsListCell.h"
#import "AFNetworking.h"
#import "NewsListMode.h"
#import "ScrollViewMode.h"
#import "UIImageView+WebCache.h"
#import "DetailNewsViewController.h"
#import "UINavigationBar+Awesome.h"
#import "MJRefresh.h"
//OldNewsUrl
#define kOldNewsUrl @"http://news-at.zhihu.com/api/3/stories/before/"
//屏幕宽度的宏
#define kWidth [UIScreen mainScreen].bounds.size.width
//屏幕高度的宏
#define kHeight [UIScreen mainScreen].bounds.size.height

#define NAVBAR_CHANGE_POINT 20
@interface NewsListController ()
//设置全局scrollView
@property (nonatomic,retain)UIScrollView *scrollView;
@property (nonatomic, strong)UIPageControl *pageControl;
@property (nonatomic,retain)NSTimer *timer;
@property (nonatomic,assign)int a;
@property (nonatomic,strong)NSMutableArray * listArray; //今日新闻
@property (nonatomic,strong)NSMutableArray * scrollArray;
@property (nonatomic,strong)ScrollViewMode * scModel;
@property (nonatomic, strong) NewsListMode * nlModel;

@property (nonatomic, assign) NSInteger todayDate;  // 今天的日期

@property (nonatomic, retain) NSMutableArray *oldArray;  // 旧新闻

@property (nonatomic, strong) NSMutableArray *sectionArray;//分组

@property (nonatomic, strong) NSMutableArray * rowArray;//大数组

// 解析出来的所有的日期
@property (nonatomic, retain) NSMutableArray *dateArray;

@end

static NSString * identifier = @"cell";

@implementation NewsListController

//解析今日新闻
- (void)parsingWithblock:(myBlock)block{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    [manager GET:@"http://news-at.zhihu.com/api/4/stories/latest" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil);
    }];
    
}

//---------------解析往日新闻----------------
- (void)parsingOldNewsWithblock:(myBlock)block{
    
//    for (int i = 0; i < 5; i++) {
    
       NSString *url = [NSString stringWithFormat:@"%@%@", kOldNewsUrl, self.dateArray.lastObject];
        NSLog(@"%@", url);
    
    AFHTTPRequestOperationManager *managerOld = [AFHTTPRequestOperationManager manager];
    [managerOld GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject);
        
        
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil);
    }];
    
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //第三方实现透明BAR必要代码
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    
    self.tableView.dataSource = self;
    
    //-----设置navigationBar-----
    self.title = @"今日热闻";
    //设置NavigationBar标题
    NSDictionary *attribute =[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attribute];
    //设置左按钮及颜色
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"archive_24px_1194443_easyicon.net"] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    //navigationBar背景图
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"BKLeftMenu.jpg"] forBarMetrics:UIBarMetricsDefault];
    
    //注册cell信息
    [self.tableView registerClass:[NewsListCell class] forCellReuseIdentifier:identifier];
    
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    NSLog(@"%@",self.navigationController.navigationBar);
    //    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    
    
    
    // 获取ListCell解析的数据
    [self parsingWithblock:^(id block) {
        
        NSDictionary *allDic = (NSDictionary *)block;

        //获取到的日期
        NSString *date = allDic[@"date"];
        [self.dateArray addObject:date];
        
        NSArray *array = allDic[@"stories"];
        for (NSDictionary *dic in array) {
            NewsListMode *model = [NewsListMode new];
            [model setValuesForKeysWithDictionary:dic];
            //获取到的所有list数据
            [self.listArray addObject:model];
        }
        
        [self.rowArray addObject:[self.listArray copy]];
        [self.tableView reloadData];
    }];
    
    //获取ScrollView解析的数据
    [self parsingWithblock:^(id block) {
        
        
        NSArray *array1 = [(NSDictionary *)block objectForKey:@"top_stories"];
        
        for (NSDictionary *dict in array1) {
            ScrollViewMode *model1 = [ScrollViewMode new];
            [model1 setValuesForKeysWithDictionary:dict];
            [self.scrollArray addObject:model1];
        }
        [self addTopScollView];
        [self.tableView reloadData];
    }];
    
    
    
    
    // 下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [self parsingWithblock:^(id block) {
            NSArray *array = [(NSDictionary *)block objectForKey:@"stories"];
            for (NSDictionary *dic in array) {
                NewsListMode *model = [NewsListMode new];
                [model setValuesForKeysWithDictionary:dic];
                [self.listArray addObject:model];
            }
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];
        }];

    }];
    
    
    //上拉加载
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        [self parsingOldNewsWithblock:^(id block) {
            
            if (self.listArray.count) {
                [self.listArray removeAllObjects];
            }
            
            NSDictionary *dic3 = (NSDictionary *)block;
            
            NSString *dateString = dic3[@"date"];
            [self.dateArray addObject:dateString];
            
            NSArray *tempArray = dic3[@"stories"];
            //储存数据到数组
            for (NSDictionary *dic in tempArray) {
                NewsListMode *model = [NewsListMode new];
                [model setValuesForKeysWithDictionary:dic];
                [self.listArray addObject:model];
            }
            [self.rowArray addObject:[self.listArray copy]];
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
        }];
        }];
}



//懒加载scrollView
-(NSMutableArray *)scrollArray{
    if (!_scrollArray) {
        _scrollArray = [NSMutableArray array];
    }
    return _scrollArray;
}

//懒加载cell
- (NSMutableArray *)listArray{
    if (!_listArray) {
        _listArray = [NSMutableArray array];
    }
    return _listArray;
}

//懒加载oldNews
- (NSMutableArray *)oldArray{
    if (!_oldArray) {
        _oldArray = [NSMutableArray array];
    }
    return _oldArray;
}

//懒加载sectionArray
- (NSMutableArray *)sectionArray{
    if (!_sectionArray) {
        _sectionArray = [NSMutableArray array];
    }
    return _sectionArray;
}

- (NSMutableArray *)dateArray{
    if (!_dateArray) {
        _dateArray = [NSMutableArray array];
    }
    return _dateArray;
}

- (NSMutableArray *)rowArray{
    if (!_rowArray) {
        _rowArray = [NSMutableArray array];
    }
    return _rowArray;
}

- (void)addTopScollView{
    //建一个headerView
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, -64, kWidth, kHeight/3.3-64)];
    //设置为tableHeaderView
    headerView.backgroundColor = [UIColor redColor];
    self.tableView.tableHeaderView = headerView;
    
    //建ScrollView轮播图
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, -64, kWidth, kHeight/3.3)];
    //ScrollView背景颜色
    _scrollView.backgroundColor = [UIColor whiteColor];
    //ScrollView内容尺寸
    _scrollView.contentSize = CGSizeMake(kWidth * 5, kHeight/3.3);
    //ScrollView控件是否可以整页翻动
    _scrollView.pagingEnabled = YES;
    //设置代理可用，用于下面的方法
    _scrollView.delegate = self;
    //把scrollView放到视图上
    [headerView addSubview:_scrollView];
    
    for (int i = 0; i<5; i++) {
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kWidth*i, 0, kWidth, kHeight/3.3)];
        ScrollViewMode *scModel = self.scrollArray[i];
        [imageView sd_setImageWithURL:[NSURL URLWithString:scModel.image]];
        [_scrollView addSubview:imageView];
        
        //scrollView上的title
        UILabel *scrollLabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth*i+10, kHeight/3.3/3*1.8, kWidth-20, kHeight/3.3/3)];
        scrollLabel.text = scModel.title;
        scrollLabel.backgroundColor = [UIColor clearColor];
        scrollLabel.textColor = [UIColor whiteColor];
        //scrollLabel.highlightedTextColor = [UIColor whiteColor];
//        [scrollLabel.shadowColor = [UIColor colorWithWhite:0.1 alpha:0.8f];
        scrollLabel.shadowColor = [UIColor colorWithWhite:0.1 alpha:8];
        scrollLabel.shadowOffset = CGSizeMake(2, 2);
        scrollLabel.font = [UIFont boldSystemFontOfSize:20];
        scrollLabel.numberOfLines = 0;
        [_scrollView addSubview:scrollLabel];
        
    }
    
    //把imageView们放进scrollView
    //    [_scrollView addSubview:imageView1];
    //    [_scrollView addSubview:imageView2];
    //    [_scrollView addSubview:imageView3];
    //    [_scrollView addSubview:imageView4];
    //    [_scrollView addSubview:imageView5];
    
    //设置pageControll小圆点
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(kWidth/3, kHeight/3.65-64, kWidth/3, 20)];
    //设置小圆点的个数
    _pageControl.numberOfPages = 5;
    //设置当前页
    _pageControl.currentPage = 0;
    //设置小圆点颜色
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    //小圆点选中颜色
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    //设置小圆点事件
    [_pageControl addTarget:self action:@selector(pageAction:) forControlEvents:(UIControlEventValueChanged)];
    //把小圆点放在scrollView上
    [headerView addSubview:_pageControl];
    
    //设置NSTimer(5秒)
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timeGo:) userInfo:nil repeats:YES];
    _a = 0;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIColor * color = [UIColor colorWithRed:153/255.0 green:204/255.0 blue:51/255.0 alpha:0];
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY == -64) {
        [self.navigationController.navigationBar lt_setBackgroundColor: [UIColor clearColor]];
    }
    if (offsetY > NAVBAR_CHANGE_POINT) {
        CGFloat alpha = MIN(1, 1 - ((NAVBAR_CHANGE_POINT + 64 - offsetY) / 64));
        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
    } else {
        //[self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
    }
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.tableView.delegate = self;
    //[self scrollViewDidScroll:self.tableView];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tableView.delegate = nil;
    [self.navigationController.navigationBar lt_reset];
}

//手动滑动图标，小圆点跟着移动 (代理方法)
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _pageControl.currentPage = _scrollView.contentOffset.x/kWidth;
}

//设置NSTimer
-(void)timeGo:(NSTimer *)sender{
    _a++;
    if (_a > 4) {
        _a = 0;
    }
    [_scrollView setContentOffset:CGPointMake(kWidth*_a, 0)];
    _pageControl.currentPage = _a;
}

//设置scrollView的偏移量随着pageControl移动
-(void)pageAction:(UIPageControl *)sender{
    // NSInteger index = sender.currentPage;
    _scrollView.contentOffset = CGPointMake(kWidth * sender.currentPage, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"%ld", self.dateArray.count);
    return self.dateArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%ld", [self.rowArray[section] count]);
    return [self.rowArray[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    NSArray *array = self.rowArray[indexPath.section];
    NSLog(@"------%ld", array.count);
    
    //cell.textLabel.text = @"啦啦
    cell.model = array[indexPath.row];
    //选中无灰色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //return kHeight/6.2;
    return 92;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailNewsViewController *detailVC = [[DetailNewsViewController alloc]init];
    NewsListMode * lModel = _listArray[indexPath.row];
    //用DetailNewsViewController里面建的newsID来承接
    detailVC.newsID = lModel.ID;
    
    [self presentViewController:detailVC animated:YES completion:nil];
    
    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
