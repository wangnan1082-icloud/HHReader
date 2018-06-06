//
//  WifiUploadBookViewController.m
//  HHReader
//
//  Created by 王楠 on 2018/5/31.
//  Copyright © 2018年 王楠. All rights reserved.
//  WiFi传书

#import "WifiUploadBookViewController.h"
#import "IPTool.h"

#import <GCDWebUploader.h>
#import <GCDWebServerDataRequest.h>
#import <GCDWebServerDataResponse.h>
#import <GCDWebServerURLEncodedFormRequest.h>

@interface WifiUploadBookViewController ()<GCDWebUploaderDelegate>
{
    UILabel *_label;
    GCDWebUploader* _webServer;
}

@end

@implementation WifiUploadBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WiFi传书";
    [self setUI];
    [self wifiUpLoadBook];
}

- (void)setUI {
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 150)/2, 80, 150, 150)];
    imgView.image = [UIImage imageNamed:@"icon_wifi"];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imgView];

    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(30, CGRectGetMaxY(imgView.frame) + 10, self.view.bounds.size.width - 60, 50);
    tipLabel.text = @"上传过程中请勿离开此页面或者锁屏";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(30, CGRectGetMaxY(tipLabel.frame) + 50, self.view.bounds.size.width - 60, 180);
    _label.textAlignment = NSTextAlignmentCenter;
    _label.numberOfLines = 0;
    [self.view addSubview:_label];
}

- (void)wifiUpLoadBook {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _webServer = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    _webServer.delegate = self;
    _webServer.allowHiddenItems = YES;
    // 限制文件上传类型
    //  @"doc", @"docx", @"xls", @"xlsx", @"pdf", @"png", @"jpg", @"jpeg"
    _webServer.allowedFileExtensions = @[@"txt"];
    // 设置网页标题
    _webServer.title = @"HHReader";
    // 设置展示在网页上的文字(开场白)
    _webServer.prologue = @"拖拽文件到窗口或者点击“上传书籍”按钮选择您要上传的书籍，上传完成后就可以在书架上看到您上传的书啦，赶紧上传吧！";
    _webServer.footer = @"HHReader 1.0";
    if ([_webServer start]) {
        _label.text = [NSString stringWithFormat:@"确保电脑与手机在同一WiFi网络下\n在电脑浏览器地址栏输入\n http://%@:%zd/", [IPTool deviceIPAdress], _webServer.port];
    } else {
        _label.text = NSLocalizedString(@"GCDWebServer not running!", nil);
    }
    
    NSLog(@"documentsPath:    %@",documentsPath);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_webServer stop];
    _webServer = nil;
}

#pragma mark -

- (void)setGCDWebServer{
    
    _webServer = [[GCDWebServer alloc] init];
    _webServer.delegate = self;
    
    // POST
    [_webServer addHandlerForMethod:@"POST"
                               path:@"/connection" //请求路径
                       requestClass:[GCDWebServerDataRequest class]
                       processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                           
                           //   NSLog(@"jsonObject:%@",[(GCDWebServerDataRequest *)request jsonObject]);//获取 post 的请求体body
                           //   NSString* deviceName = [[(GCDWebServerDataRequest*)request jsonObject] objectForKey:@"deviceName"];
                           //   NSString* deviceuuid = [[(GCDWebServerDataRequest*)request jsonObject] objectForKey:@"uuid"];
                           
                           NSLog(@"query:%@",[request query]); ////获取请求的 query
                           NSString* deviceName = [[request query] objectForKey:@"deviceName"];
                           NSString* deviceuuid = [[request query] objectForKey:@"uuid"];
                           
                           NSLog(@"remoteAddressString:%@",[(GCDWebServerRequest *)request remoteAddressString]);//远程IP
                           NSLog(@"localAddressString:%@",[(GCDWebServerRequest *)request localAddressString]);//本地IP
                           NSLog(@"path:%@",[(GCDWebServerRequest *)request path]);//请求路径
                           
                           return [GCDWebServerDataResponse responseWithJSONObject:@{@"status":@"1"}];
                       }];
    
    
    //GET
    [_webServer addHandlerForMethod:@"GET"
                               path:@"/status" //请求路径
                       requestClass:[GCDWebServerRequest class]
                       processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                           NSLog(@"%@",[request query]);
                           
                           //16位的MD5 IDFV
                           NSString *MD5Bit16IDFV = [NSString stringWithFormat:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
                           //[NSString getMd5_16Bit_String:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
                           //返回 Json 信息
                           return [GCDWebServerDataResponse responseWithJSONObject:@{@"username":@"App name", @"uid":@"App uid", @"os":@"ios", @"mac":MD5Bit16IDFV}];
                       }];
    
    // Start server on port 9526   端口号:9526
    [_webServer startWithPort:[@"5678" integerValue] bonjourName:nil];
    NSLog(@"Visit %@ in your web browser", _webServer.serverURL);
}


#pragma mark -

- (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path {
    NSString *string = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:string error:nil]];
    
    NSLog(@"[arr] %@", arr);
    
    NSLog(@"[UPLOAD] %@", path);
}

- (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
    NSLog(@"[MOVE] %@ -> %@", fromPath, toPath);
}

- (void)webUploader:(GCDWebUploader*)uploader didDeleteItemAtPath:(NSString*)path {
    NSLog(@"[DELETE] %@", path);
}

- (void)webUploader:(GCDWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path {
    NSLog(@"[CREATE] %@", path);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
