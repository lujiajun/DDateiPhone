
#import <UIKit/UIKit.h>
#import "NickNameController.h"
@interface NickNameController()

@property (nonatomic, weak)  UITextField *hashKeyTextField;

@end

@implementation NickNameController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"名字";
//    self.view.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    UITextField *textFiled=[[UITextField alloc]init];
    textFiled.frame=CGRectMake(5, 0, 10, 10);
    textFiled.borderStyle=UITextBorderStyleLine;
    textFiled.placeholder=@"名字";
    
    [self setView:textFiled];
//    [self.contentView addSubview:mylable];
    
}


@end