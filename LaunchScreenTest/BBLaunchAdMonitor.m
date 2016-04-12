//
//  BBLaunchAdMonitor.m
//  Search
//
//  Created by iXcoder on 15/4/22.
//  Copyright (c) 2015年 iXcoder. All rights reserved.
//

#import "BBLaunchAdMonitor.h"
@import UIKit.UIScreen;
@import UIKit.UIImage;
@import UIKit.UIImageView;
@import UIKit.UIButton;
@import UIKit.UILabel;
@import UIKit.UIColor;
@import UIKit.UIFont;
@import QuartzCore.CALayer;

NSString *BBLaunchAdDetailDisplayNotification = @"BBShowLaunchAdDetailNotification";

static BBLaunchAdMonitor *monitor = nil;

@interface BBLaunchAdMonitor()<NSURLConnectionDataDelegate, NSURLConnectionDelegate>
{
    
}

@property (nonatomic, assign) BOOL imgLoaded;
@property (nonatomic, strong) NSMutableData *imgData;
@property (nonatomic, strong) NSURLConnection *conn;
@property (nonatomic, strong) NSMutableDictionary *detailParam;

@end


@implementation BBLaunchAdMonitor

+ (void)showAdAtPath:(NSString *)path onView:(UIView *)container timeInterval:(NSTimeInterval)interval detailParameters:(NSDictionary *)param
{
    if (![self validatePath:path]) {
        return ;
    }
    
    [[self defaultMonitor] loadImageAtPath:path];
    while (!monitor.imgLoaded) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    [monitor.detailParam removeAllObjects];
    [monitor.detailParam addEntriesFromDictionary:param];
    [self showImageOnView:container forTime:interval];
}

+ (instancetype)defaultMonitor
{
    @synchronized (self) {
        if (!monitor) {
            monitor = [[BBLaunchAdMonitor alloc] init];
        }
        return monitor;
    }
}

+ (BOOL)validatePath:(NSString *)path
{
    NSURL *url = [NSURL URLWithString:path];
    return url != nil;
}

+ (void)showImageOnView:(UIView *)container forTime:(NSTimeInterval)time
{
    CGRect f = [UIScreen mainScreen].bounds;
    NSLog(@"screen size:%@", NSStringFromCGRect(f));
    UIView *v = [[UIView alloc] initWithFrame:f];
    v.backgroundColor = [UIColor whiteColor];
    
    f.size.height -= 50;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:f];
    iv.image = [UIImage imageWithData:monitor.imgData];
    monitor.conn = nil;
    [monitor.imgData setLength:0];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.clipsToBounds = YES;
    [v addSubview:iv];
    
    [container addSubview:v];
    [container bringSubviewToFront:v];
    
    UIButton *showDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [showDetailBtn setTitle:@"详情>>" forState:UIControlStateNormal];
    [showDetailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showDetailBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    showDetailBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    showDetailBtn.frame = CGRectMake(f.size.width - 70, 30, 60, 30);
    showDetailBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    showDetailBtn.layer.borderWidth = 1.0f;
    showDetailBtn.layer.cornerRadius = 3.0f;
    [showDetailBtn addTarget:self action:@selector(showAdDetail:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:showDetailBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, f.size.height + 10, f.size.width - 20, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"©2015 iXcoder. All Rights Reserved";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    [v addSubview:label];
    label = nil;
    
    [container addSubview:v];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        v.userInteractionEnabled = NO;
        [UIView animateWithDuration:.25
                         animations:^{
                             v.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [v removeFromSuperview];
                         }];
    });
}

+ (void)showAdDetail:(id)sender
{
    UIView *sup = [(UIButton *)sender superview];
    sup.userInteractionEnabled = NO;
    [UIView animateWithDuration:.25
                     animations:^{
                         sup.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [sup removeFromSuperview];
                         [[NSNotificationCenter defaultCenter] postNotificationName:BBLaunchAdDetailDisplayNotification
                                                                             object:monitor.detailParam];
                         [monitor.detailParam removeAllObjects];
                     }];
    
}

- (void)loadImageAtPath:(NSString *)path
{
    NSURL *URL = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    self.conn = [NSURLConnection connectionWithRequest:request delegate:self];
    if (self.conn) {
        [self.conn start];
    }
}

#pragma mark - NSURLConnectionDataDelegate method
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    if (resp.statusCode != 200) {
        self.imgLoaded = YES;
        return ;
    }
    self.imgData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imgData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.imgLoaded = YES;
    [[NSUserDefaults standardUserDefaults]setObject:self.imgData forKey:@"image"];
}

@end

