//
//  RJDemoViewController.m
//  RJBadgeKit_Example
//
//  Created by Ryan Jin on 22/12/2017.
//  Copyright © 2017 RylanJIN. All rights reserved.
//

#import "RJDemoViewController.h"
#import "RJBadgeKit.h"

@interface RJDemoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *pageButton;

@end

@implementation RJDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *demoPath = @"root.pbdemo.page";
    
    [RJBadgeController setBadgeForKeyPath:demoPath];
    
    [self.badgeController observePath:demoPath badgeView:self.pageButton block:nil];
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
