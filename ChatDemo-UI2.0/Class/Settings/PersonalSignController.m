//
//  PushNotificationViewController.m
//  ChatDemo-UI2.0
//
//  Created by dhcdht on 14-7-21.
//  Copyright (c) 2014年 dhcdht. All rights reserved.
//

#import "PersonalController.h"
#include "UsernickController.h"
#import "NewSettingViewController.h"
#import "AliCloudController.h"
#import "DDBDynamoDB.h"
#import "Constants.h"
#import "PersonalSignController.h"



@interface PersonalSignController ()
{
    EMPushNotificationDisplayStyle _pushDisplayStyle;
    EMPushNotificationNoDisturbStatus _noDisturbingStatus;
    NSInteger _noDisturbingStart;
    NSInteger _noDisturbingEnd;
    NSString *_nickName;
}

@property (strong, nonatomic) UISwitch *pushDisplaySwitch;
@property (strong,nonatomic)  NSString *username;
@property (strong,nonatomic)  UITextField *nicktext;


@end

@implementation PersonalSignController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _noDisturbingStart = -1;
        _noDisturbingEnd = -1;
        _noDisturbingStatus = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"个性签名";
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [saveButton setTitle:NSLocalizedString(@"save", @"Save") forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(savePushOptions) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
    _username = [loginInfo objectForKey:kSDKUsername];
    //查询
    DDBDynamoDB *ddbDynamoDB=[DDBDynamoDB new];
    [ddbDynamoDB addNewUser:_username];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UISwitch *)pushDisplaySwitch
{
    if (_pushDisplaySwitch == nil) {
        _pushDisplaySwitch = [[UISwitch alloc] init];
        [_pushDisplaySwitch addTarget:self action:@selector(pushDisplayChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _pushDisplaySwitch;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return YES;
    }
    
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return NSLocalizedString(@"setting.notDisturb", @"No disturbing");
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            _nicktext = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, cell.frame.size.width, 30)];
            [_nicktext setBorderStyle:UITextBorderStyleBezel]; //外框类型
            
            _nicktext.placeholder = _username; //默认显示的字
            [cell.contentView addSubview:_nicktext];
            
            
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 40;
    }
    
    return 0;
}


#pragma mark - action

- (void)savePushOptions
{
    //查询出dduser ,并修改
    //查询
    DDBDynamoDB *ddbDynamoDB=[DDBDynamoDB new];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    [[dynamoDBObjectMapper load:[DDUser class] hashKey:_username rangeKey:nil] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"The request failed. Error: [%@]", task.error);
        }
        if (task.exception) {
            NSLog(@"The request failed. Exception: [%@]", task.exception);
        }
        if (task.result) {
            DDUser *dduser = task.result;
            if(dduser.UID!=nil){
                dduser.university=_nicktext.text;
                [ddbDynamoDB updateTable:dduser];
                
                
            }
            
            //Do something with the result.
        }
        //        PersonalController *pushController = [[PersonalController alloc] initWithStyle:UITableViewStylePlain];
        //
        //        [self.navigationController pushViewController:pushController animated:YES];
        
        
        return nil;
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


@end
