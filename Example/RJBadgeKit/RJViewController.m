//
//  RJViewController.h
//  RJBadgeKit
//
//  Created by RylanJIN on 08/03/2017.
//  Copyright (c) 2017 RylanJIN. All rights reserved.
//

#import "RJViewController.h"
#import "RJBadgeKit.h"

NSString * const DEMO_PARENT_PATH = @"root.p365";
NSString * const DEMO_CHILD_PATH1 = @"root.p365.test1";
NSString * const DEMO_CHILD_PATH2 = @"root.p365.test2";

@interface RJViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel     *countLabel;
@property (weak, nonatomic) IBOutlet UILabel     *pathLabel;
@property (weak, nonatomic) IBOutlet UITextField *countField;
@property (weak, nonatomic) IBOutlet UIButton    *parentButton;
@property (weak, nonatomic) IBOutlet UIButton    *childButton1;
@property (weak, nonatomic) IBOutlet UIButton    *childButton2;

@end

@implementation RJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.countField setDelegate:self];
    [self.countField setKeyboardType:UIKeyboardTypeNumberPad];
    
    [self.pathLabel setText:DEMO_CHILD_PATH1];
    
    // self.parentButton.badgeOffset = CGPointMake(-50, 0);
    self.parentButton.badgeRadius    = 5.f;
    self.parentButton.badgeBgColor   = [UIColor blueColor];

    // observe parent button 'root.p365'
    [self.badgeController observePath:DEMO_PARENT_PATH
                            badgeView:self.parentButton
                                block:^(id observer, NSDictionary *info) {
        NSLog(@"root.p365 => %@", info);
    }];
    
    // observe child button 'root.p365.test1'
    [self.badgeController observePath:DEMO_CHILD_PATH1
                            badgeView:self.childButton1
                                block:^(RJViewController *observer, NSDictionary *info) {
        NSUInteger count = [info[RJBadgeCountKey] unsignedIntegerValue];
        [observer.countLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)count]];
    }];
    
    NSUInteger count = [RJBadgeController countForKeyPath:DEMO_CHILD_PATH1];
    [self.countLabel setText:[@(count) stringValue]];
    
    /**
     DEBUG FOR PARENT BADGE COUNTING
     */
    [RJBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH2 count:2];
    
    // observe child button 'root.p365.test2'
    [self.badgeController observePath:DEMO_CHILD_PATH2 badgeView:self.childButton2 block:nil];
}

#pragma mark - Click Button
- (IBAction)setBadgePathWithCount:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if (!self.countField.text) return;
    
    [RJBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH1
                                    count:[self.countField.text integerValue]];
}

- (IBAction)setBadgePath:(UIButton *)sender {
    [RJBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH1];
}

- (IBAction)clearBadgePath:(UIButton *)sender {
    [RJBadgeController clearBadgeForKeyPath:DEMO_CHILD_PATH1];
}

- (IBAction)clickChildButton1:(UIButton *)sender
{
    BOOL needShow = [RJBadgeController statusForKeyPath:DEMO_CHILD_PATH1];
    if (needShow) {
        [RJBadgeController clearBadgeForKeyPath:DEMO_CHILD_PATH1];
    } else {
        [RJBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH1];
    }
}

- (IBAction)clickChildButton2:(UIButton *)sender
{
    BOOL needShow = [RJBadgeController statusForKeyPath:DEMO_CHILD_PATH2];
    if (needShow) {
        [RJBadgeController clearBadgeForKeyPath:DEMO_CHILD_PATH2];
    } else {
        [RJBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH2 count:2];
    }
}

- (IBAction)clickParentButton:(UIButton *)sender {
    [RJBadgeController clearBadgeForKeyPath:DEMO_PARENT_PATH forced:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    return [self validateNumber:string];
}

- (BOOL)validateNumber:(NSString *)number
{
    BOOL res = YES;
    int i    = 0;
    
    NSCharacterSet *tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) { res = NO; break; }
        
        i++;
    }
    return res;
}

@end
