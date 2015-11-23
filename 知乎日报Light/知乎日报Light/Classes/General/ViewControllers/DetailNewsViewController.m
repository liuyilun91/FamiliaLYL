//
//  DetailNewsViewController.m
//  知乎日报Light
//
//  Created by 刘奕伦 on 15/11/21.
//  Copyright © 2015年 Yilun Liu. All rights reserved.
//

#import "DetailNewsViewController.h"
#import "AFNetworking.h"
#import "NewsListMode.h"
#import "UIImageView+WebCache.h"
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight ([UIScreen mainScreen].bounds.size.height-49)
#define DetailUrl @"http://news-at.zhihu.com/api/4/story/"
@interface DetailNewsViewController ()
@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) UIView * deepView;
@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) UIScrollView * bigScrollView;
@property (nonatomic, strong) UIImageView * tV;
@property (nonatomic, strong) UILabel * titleInIV;
@property (nonatomic, strong) UILabel * miniLabel;
@property (nonatomic, strong) UILabel * miniImage;
@property (nonatomic, strong) UIButton * nextButton;
@property (nonatomic, strong) UIImageView *deepImage;
@property (nonatomic, strong) UIButton * thirdButton;

//------------[封装声明fk]-------------
@property (nonatomic, strong) UIWebView * fkwebView;
@property (nonatomic, strong) UIView * fkdeepView;
@property (nonatomic, strong) UIButton * fkleftButton;
@property (nonatomic, strong) UIScrollView * fkbigScrollView;
@property (nonatomic, strong) UIImageView * fktV;
@property (nonatomic, strong) UILabel * fktitleInIV;
@property (nonatomic, strong) UILabel * fkminiLabel;
@property (nonatomic, strong) UILabel * fkminiImage;
@property (nonatomic, strong) UIButton * fknextButton;

@end

@implementation DetailNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addDeepView];
    [self parseDetail];
}

//所有自己写的方法都需要调用
-(void)addDeepView{
    //建deepView
    //    self.deepView = [[UIView alloc]initWithFrame:CGRectMake(0, kHeight, kWidth, 49)];
    //    _deepView.backgroundColor = [UIColor whiteColor];
    //    [self.view addSubview:_deepView];
    
    //deepImage
    self.deepImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, kHeight, kWidth, 49)];
    _deepImage.image = [UIImage imageNamed:@"BKLeftMenu.jpg"];
    //设置imageView可按
    _deepImage.userInteractionEnabled = YES;
    [self.view addSubview:_deepImage];
    
    //BIGscrollView
    self.bigScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    _bigScrollView.contentSize = CGSizeMake(kWidth, kHeight+kHeight/3.3);
    _bigScrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_bigScrollView];
    //方头图的imageView
    self.tV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight/3.3)];
    //_tV.backgroundColor = [UIColor blueColor];
    [_bigScrollView addSubview:self.tV];
    
    //建头图上的title
    self.titleInIV = [[UILabel alloc]initWithFrame:CGRectMake(10, kHeight/3.3/3*1.8, kWidth-20, kHeight/3.3/3)];
    _titleInIV.backgroundColor = [UIColor clearColor];
    _titleInIV.numberOfLines = 0;
    _titleInIV.font = [UIFont systemFontOfSize:20];
    _titleInIV.textColor = [UIColor whiteColor];
    _titleInIV.shadowColor = [UIColor colorWithWhite:0.1 alpha:8];
    _titleInIV.shadowOffset = CGSizeMake(2, 2);
    [_tV addSubview:self.titleInIV];
    
    //建头图上的小label
    self.miniLabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/3*2, kHeight/3.65-7, kWidth/3, 30)];
    _miniLabel.backgroundColor = [UIColor clearColor];
    _miniLabel.font = [UIFont systemFontOfSize:10];
    _miniLabel.textColor = [UIColor whiteColor];
    [_tV addSubview:self.miniLabel];
    
    //头图上的小“图片标识符”
    self.miniImage = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/3*2-30, kHeight/3.65-7, kWidth/12, 30)];
    _miniImage.backgroundColor = [UIColor clearColor];
    _miniImage.text = @"图片：";
    _miniImage.font = [UIFont systemFontOfSize:10];
    _miniImage.textColor = [UIColor whiteColor];
    [_tV addSubview:self.miniImage];
    
    //建webView
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, kHeight/3.3, kWidth, kHeight)];
    //把webView放到scrollView上
    [_bigScrollView addSubview:_webView];
    
    
    
    //建左返回键
    self.leftButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    _leftButton.frame = CGRectMake(5, 5, kWidth/5.5, 40);
    _leftButton.backgroundColor = [UIColor clearColor];
    [_leftButton setImage:[UIImage imageNamed:@"reply_30.822085889571px_1187934_easyicon.net"] forState:(UIControlStateNormal)];
    _leftButton.tintColor = [UIColor whiteColor];
    [_leftButton addTarget:self action:@selector(backToHome:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.deepImage addSubview:_leftButton];
    
    //下一个详情页面的跳转Button
    self.nextButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    _nextButton.frame = CGRectMake(kWidth/5.5+10, 5, kWidth/5.5, 40);
    _nextButton.backgroundColor = [UIColor clearColor];
    [_nextButton setImage:[UIImage imageNamed:@"chevron_down_40.829268292683px_1187816_easyicon.net"] forState:(UIControlStateNormal)];
    _nextButton.tintColor = [UIColor whiteColor];
    [_nextButton addTarget:self action:@selector(nextDetailPage:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.deepImage addSubview:_nextButton];
    
    //thirdButton
    self.thirdButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    _thirdButton.frame = CGRectMake(kWidth/5.5*2+15, 5, kWidth/5.5, 40);
    _thirdButton.backgroundColor = [UIColor clearColor];
    [_thirdButton setImage:[UIImage imageNamed:@"chevron_down_40.829268292683px_1187816_easyicon.net"] forState:(UIControlStateNormal)];
    _thirdButton.tintColor = [UIColor whiteColor];
    [self.deepImage addSubview:_thirdButton];
}

-(void)nextDetailPage:(UIButton *)sender{
    [self nextNewsPage];
}

-(void)backToHome:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)parseDetail{
    
    //拼接字符串
    NSString *str = [DetailUrl stringByAppendingString:[NSString stringWithFormat:@"%@",_newsID]];
    NSLog(@"%@",str);
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:str parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NewsListMode *news = [NewsListMode new];
        [news setValuesForKeysWithDictionary:responseObject];
        //头图
        [self.tV sd_setImageWithURL:[NSURL URLWithString:news.image]];
        //头图上的标题
        self.titleInIV.text = news.title;
        //miniLabel
        self.miniLabel.text = news.image_source;
        //webView
        [self.webView loadHTMLString:news.body baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"---failure---");
    }];
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-------------[封装点击进入下一个详情页面的方法]---------------
-(void)nextNewsPage{
    //-----BuildUI-----
    //建deepView
    self.fkdeepView = [[UIView alloc]initWithFrame:CGRectMake(0, kHeight, kWidth, 49)];
    _fkdeepView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_fkdeepView];
    
    //BIGscrollView
    self.fkbigScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    _fkbigScrollView.contentSize = CGSizeMake(kWidth, kHeight+kHeight/3.3);
    _fkbigScrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_fkbigScrollView];
    //方头图的imageView
    self.fktV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight/3.3)];
    //_tV.backgroundColor = [UIColor blueColor];
    [_fkbigScrollView addSubview:self.fktV];
    
    //建头图上的title
    self.fktitleInIV = [[UILabel alloc]initWithFrame:CGRectMake(10, kHeight/3.3/3*1.8, kWidth-20, kHeight/3.3/3)];
    _fktitleInIV.backgroundColor = [UIColor clearColor];
    _fktitleInIV.numberOfLines = 0;
    _fktitleInIV.font = [UIFont systemFontOfSize:20];
    _fktitleInIV.textColor = [UIColor whiteColor];
    [_fktV addSubview:self.fktitleInIV];
    
    //建头图上的小label
    self.fkminiLabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/3*2, kHeight/3.65-7, kWidth/3, 30)];
    _fkminiLabel.backgroundColor = [UIColor clearColor];
    _fkminiLabel.font = [UIFont systemFontOfSize:10];
    _fkminiLabel.textColor = [UIColor whiteColor];
    [_fktV addSubview:self.fkminiLabel];
    
    //头图上的小“图片标识符”
    self.fkminiImage = [[UILabel alloc]initWithFrame:CGRectMake(kWidth/3*2-30, kHeight/3.65-7, kWidth/12, 30)];
    _fkminiImage.backgroundColor = [UIColor clearColor];
    _fkminiImage.text = @"图片：";
    _fkminiImage.font = [UIFont systemFontOfSize:10];
    _fkminiImage.textColor = [UIColor whiteColor];
    [_fktV addSubview:self.fkminiImage];
    
    //建webView
    self.fkwebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, kHeight/3.3, kWidth, kHeight)];
    //把webView放到scrollView上
    [_fkbigScrollView addSubview:_fkwebView];
    
    
    
    //建左返回键
    self.fkleftButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    _fkleftButton.frame = CGRectMake(5, 5, kWidth/5.5, 40);
    _fkleftButton.backgroundColor = [UIColor clearColor];
    [_fkleftButton setImage:[UIImage imageNamed:@"箭头上"] forState:(UIControlStateNormal)];
    [_fkleftButton addTarget:self action:@selector(backToHome:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.fkdeepView addSubview:_fkleftButton];
    
    //下一个详情页面的跳转Button
    self.fknextButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    _fknextButton.frame = CGRectMake(kWidth/5.5+10, 5, kWidth/5.5, 40);
    _fknextButton.backgroundColor = [UIColor redColor];
    [_fknextButton addTarget:self action:@selector(nextDetailPage:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.fkdeepView addSubview:_fknextButton];
    //-----[完成BuildUI]-----
    
    //-----[解析]-----
    //拼接字符串
    
    int temp = [_newsID intValue];
    temp--;
    
    NSString *str = [DetailUrl stringByAppendingString:[NSString stringWithFormat:@"%d",temp]];
    NSLog(@"%@",str);
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:str parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NewsListMode *news = [NewsListMode new];
        [news setValuesForKeysWithDictionary:responseObject];
        //头图
        [self.tV sd_setImageWithURL:[NSURL URLWithString:news.image]];
        //头图上的标题
        self.titleInIV.text = news.title;
        //miniLabel
        self.miniLabel.text = news.image_source;
        //webView
        [self.webView loadHTMLString:news.body baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"---failure---");
    }];
    //-----[完成解析]-----
    
}
//-------------[完成封装]--------------

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
