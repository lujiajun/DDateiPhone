#import "DDHeadPicUpdate.h"
#import "IndexViewController.h"
#import "Constants.h"
#import "Util.h"

@implementation DDHeadPicUpdate


-(void)viewDidLoad{
    [super viewDidLoad];
    DDUser *uuser=IndexViewController.instanceDDuser;
    
    //touxiang 修改
    UIImage *img=[UIImage alloc];
    if(uuser && uuser.picPath){
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:uuser.picPath]]];
        img = [UIImage imageWithData:data];
    }else {
        img=[UIImage imageNamed:@"Logo_new.png"];
    }
    UIImageView *imgHead=[[UIImageView alloc] initWithImage:img];
    imgHead.layer.masksToBounds =YES;
    imgHead.layer.cornerRadius =50;
    imgHead.frame=CGRectMake(self.view.frame.size.width/2-50, 10, 100, 100);
    [imgHead setContentMode:UIViewContentModeScaleToFill];
    [self.view addSubview:imgHead] ;
    
    //密码修改
    //修改昵称
    
    
}

@end