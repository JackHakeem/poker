//
//  BLWebView.m
//  cangzhoumajiang
//
//  Created by 罗昊 on 2017/9/13.
//
//

#import <Foundation/Foundation.h>
#import "BLWebView.h"
#import "LuaEventProxy.h"
@implementation BLWebView{
    UIWebView * webView;
    UIButton * closeBtn;
    NJKWebViewProgress * webViewProgress;
    NJKWebViewProgressView * webViewProgressView;
    UIView * mParent;
}
static BLWebView* instance = nil;
+(id)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
        
    });
    
    return instance;
}

-(id)init{
    if(self=[super init]) {
    }
    return self;
}
+ (int) getScale
{
    int scale = 1.0;
    UIScreen *screen = [UIScreen mainScreen];
    if([screen respondsToSelector:@selector(scale)])
        scale = screen.scale;
    return scale;
}
-(void)initWebView:(UIView *)parent{
    mParent = parent;
    
}

-(void)createWebView{
    if (webView) return;
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    
    [mParent addSubview: webView];
    [webView setHidden:YES];
    webViewProgress = [[NJKWebViewProgress alloc] init];
    webView.delegate = webViewProgress;
    webViewProgress.webViewProxyDelegate = self;
    webViewProgress.progressDelegate = self;
    
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    
    CGRect barFrame = CGRectMake(0,
                                 0,
                                 300,
                                 2);
    webViewProgressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    webViewProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [webViewProgressView setProgress:0 animated:NO];
    [webView addSubview:webViewProgressView];
    webView.scrollView.bounces=NO;
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image=[UIImage imageNamed:@"btn_close2.png"];
    [closeBtn setBackgroundImage:image forState:UIControlStateNormal];
    [closeBtn addTarget:self action: @selector(btn_Click:) forControlEvents:UIControlEventTouchUpInside];
    [webView addSubview:closeBtn];
}

-(void)btn_Click:(UIButton*)buttom
{
    [self dismissWebView];
}

-(void)releaseWebView{
    if(webView) {
        [webView removeFromSuperview];
        webView = NULL;
    }
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [webViewProgressView setProgress:progress animated:NO];
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError:%@", error);
}
// 如果返回NO，代表不允许加载这个请求
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // 说明协议头是ios
    if ([@"tianyoumajiang" isEqualToString:request.URL.scheme]) {
        
        return NO;
    }
    
    return YES;
}

-(void)displayWebView:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height showClose:(Boolean)showClose {
    if (!webView) [self createWebView];
    int scale = [BLWebView getScale];
    [webView setFrame:CGRectMake(x/scale, y/scale, width/scale, height/scale)];
    [webView setHidden:NO];
    if (showClose) {
        [closeBtn setFrame:CGRectMake(width/scale - height/scale/10 - height/scale/40, height/scale/40, height/scale/10, height/scale/10)];
        [closeBtn setHidden:NO];
    }else{
        [closeBtn setHidden:YES];
    }
}

-(void)dismissWebView{
    if (webView) [self releaseWebView];
}
-(void)webViewLoadUrl:(NSString *)url{
    if (!webView) [self createWebView];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [webView loadRequest:request];
}
-(int)isWebViewVisible{
    if (webView) {
        if ([webView isHidden]){
            return 0;
        }else{
            return 1;
        }
    }
    return 0;
}
@end

