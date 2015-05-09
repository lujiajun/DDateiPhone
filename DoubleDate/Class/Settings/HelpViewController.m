#import "HelpViewController.h"
#import "IndexViewController.h"
#import "Constants.h"

@implementation HelpViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    self.title=@"Help";
    UILabel *sets=[[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.view.frame.size.width-10
                                                            , 50)];
    sets.text= @"如果有任何和Double Date相关的建议及意见，请联系blackmoonmoon.emily@gmail.com";
    sets.font=[UIFont fontWithName:@"Helvetica" size:12];
    [sets setNumberOfLines:0];
//    sets.lineBreakMode = UILineBreakModeWordWrap;
    [self.view addSubview:sets];
    
    
}

@end