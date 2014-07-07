//
//  SendTextTimeLineViewController.m
//  RecipeShare
//
//  Created by D L on 5/3/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "SendTextTimeLineViewController.h"
#import "Constants.h"
#import <AWSRuntime/AWSRuntime.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "MBProgressHUD.h"
#import "ss4556AppDelegate.h"

@interface SendTextTimeLineViewController ()
@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) AmazonDynamoDBClient *ddb;
@property (nonatomic, strong) NSMutableArray *tempFollower;
@property (nonatomic, strong) NSString *UID;
@property (nonatomic, strong) NSMutableArray *followers;
@end

@implementation SendTextTimeLineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self.textField becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.charactorCounter.text=[NSString stringWithFormat:@"%i/%i",TEXTVIEW_LENGTH,TEXTVIEW_LENGTH];
    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    self.UID= appDelegate.username;
    self.followers = appDelegate.followed;
    self.tempFollower = [[NSMutableArray alloc]init];
    [self.tempFollower addObject:@"123@123.com"];
    [self.tempFollower addObject:@"222@123.com"];
    
}

#pragma mark limit textview charactor length
- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString*)aText {
    NSString* newText = [aTextView.text stringByReplacingCharactersInRange:aRange withString:aText];
    if (newText.length > TEXTVIEW_LENGTH) {
        return NO;
    } else {
        return YES;
    }
}
#pragma mark textview charactor count
-(void)textViewDidChange:(UITextView *)textView
{
    int len = textView.text.length;
    self.charactorCounter.text=[NSString stringWithFormat:@"%i/%i",TEXTVIEW_LENGTH-len,TEXTVIEW_LENGTH];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark send text
- (void) textUpload: (NSString *)uid2 time: (NSString *) time type:(NSString *)type {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
        
        AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Uploading";
        [hud show:YES];
        DynamoDBPutItemRequest *putItemRequest = [DynamoDBPutItemRequest new];
        putItemRequest.tableName = @"TimeLine";
        
        // Each attribute will be a DynamoDBAttributeValue
        
        DynamoDBAttributeValue *value = [[DynamoDBAttributeValue alloc] initWithS:uid2];
        [putItemRequest.item setValue:value forKey:@"UID"];
        
        // The item is an NSMutableDictionary, keyed by the attribute name
        value = [[DynamoDBAttributeValue alloc] initWithS:time];
        [putItemRequest.item setValue:value forKey:@"Time"];
        
        if(YES){
            value = [[DynamoDBAttributeValue alloc] initWithN:type];
            [putItemRequest.item setValue:value forKey:@"type"];
        }
        
        if(YES){
            value = [[DynamoDBAttributeValue alloc] initWithS:uid2];
            [putItemRequest.item setValue:value forKey:@"UID2"];
        }
        if(self.textField.text!=NULL){
            value = [[DynamoDBAttributeValue alloc] initWithS:self.textField.text];
            [putItemRequest.item setValue:value forKey:@"String1"];
        }
        [self.ddb putItem:putItemRequest];

        for (NSString* uid in self.followers) {
            DynamoDBPutItemRequest *putItemRequest = [DynamoDBPutItemRequest new];
            putItemRequest.tableName = @"TimeLine";
            
            // Each attribute will be a DynamoDBAttributeValue
            
            DynamoDBAttributeValue *value = [[DynamoDBAttributeValue alloc] initWithS:uid];
            [putItemRequest.item setValue:value forKey:@"UID"];
            
            // The item is an NSMutableDictionary, keyed by the attribute name
            value = [[DynamoDBAttributeValue alloc] initWithS:time];
            [putItemRequest.item setValue:value forKey:@"Time"];
            
            if(YES){
                value = [[DynamoDBAttributeValue alloc] initWithN:type];
                [putItemRequest.item setValue:value forKey:@"type"];
            }
            
            if(YES){
                value = [[DynamoDBAttributeValue alloc] initWithS:uid2];
                [putItemRequest.item setValue:value forKey:@"UID2"];
            }
            if(self.textField.text!=NULL){
                value = [[DynamoDBAttributeValue alloc] initWithS:self.textField.text];
                [putItemRequest.item setValue:value forKey:@"String1"];
            }
            [self.ddb putItem:putItemRequest];
        }
        [hud hide:YES];
        [self.navigationController popViewControllerAnimated:YES];
        // create the request, specify the table
        
    });
    
    
}
- (IBAction)sendText:(id)sender {
    //get data
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd-HH:mm:ss";
    NSString *time = [dateFormatter stringFromDate:now];
    [self textUpload:self.UID time:time type:[NSString stringWithFormat:@"%i",TEXT_TYPE]];
}

- (IBAction)cancelEdit:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
