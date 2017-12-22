//
//  RJDetailViewController.m
//  RJBadgeKit_Example
//
//  Created by Ryan Jin on 22/12/2017.
//  Copyright © 2017 RylanJIN. All rights reserved.
//

#import "RJDetailViewController.h"
#import "RJBadgeKit.h"

NSString * const RJItemPath1 = @"root.pbdemo.page.item1";
NSString * const RJItemPath2 = @"root.pbdemo.page.item2";

@interface RJDetailViewController ()

@property (weak, nonatomic) IBOutlet UIButton *item1;
@property (weak, nonatomic) IBOutlet UIButton *item2;

@end

@implementation RJDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.badgeController setBadgeForKeyPath:RJItemPath1];
    [self.badgeController setBadgeForKeyPath:RJItemPath2];
    
    [self.badgeController observePath:RJItemPath1 badgeView:self.item1 block:nil];
    [self.badgeController observePath:RJItemPath2 badgeView:self.item2 block:nil];
    
    [self.item1 setBadgeImage:[UIImage imageNamed:@"badgeNew"]];
}

- (IBAction)clickItem1:(UIButton *)sender
{
    BOOL needShow = [self.badgeController statusForKeyPath:RJItemPath1];
    if (needShow) {
        [self.badgeController clearBadgeForKeyPath:RJItemPath1];
    } else {
        [self.badgeController setBadgeForKeyPath:RJItemPath1];
    }
}

- (IBAction)clickItem2:(UIButton *)sender
{
    BOOL needShow = [self.badgeController statusForKeyPath:RJItemPath2];
    if (needShow) {
        [self.badgeController clearBadgeForKeyPath:RJItemPath2];
    } else {
        [self.badgeController setBadgeForKeyPath:RJItemPath2];
    }
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
