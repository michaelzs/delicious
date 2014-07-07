//
//  DetailCommentViewController.m
//  RecipeShare
//
//  Created by D L on 5/5/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "DetailCommentViewController.h"
#import "Constants.h"
#import "ss4556AppDelegate.h"
#import <AWSRuntime/AWSRuntime.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "MBProgressHUD.h"

@interface DetailCommentViewController ()
@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) AmazonDynamoDBClient *ddb;



@end

@implementation DetailCommentViewController

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
    self.charactorCount.text=[NSString stringWithFormat:@"%i/%i",TEXTVIEW_LENGTH1,TEXTVIEW_LENGTH1];
    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    //get the userid from delegate
    self.uid= appDelegate.username;
    // Do any additional setup after loading the view.
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
    self.charactorCount.text=[NSString stringWithFormat:@"%i/%i",TEXTVIEW_LENGTH1-len,TEXTVIEW_LENGTH1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark send text
- (void) textUpload {
        @try {
            AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
            self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
            NSString *recipeID=[NSString stringWithFormat:@"%@-%@",self.ruid,self.rtime];
            NSDate *now = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd-HH:mm:ss";
            NSString *time = [dateFormatter stringFromDate:now];
            DynamoDBPutItemRequest *putItemRequest = [DynamoDBPutItemRequest new];
            putItemRequest.tableName = @"Comment";
            
            DynamoDBAttributeValue *value = [[DynamoDBAttributeValue alloc] initWithS:recipeID];
            [putItemRequest.item setValue:value forKey:@"RecipeID"];
            
            value = [[DynamoDBAttributeValue alloc] initWithS:time];
            [putItemRequest.item setValue:value forKey:@"Time"];
            
            value = [[DynamoDBAttributeValue alloc] initWithS:self.uid];
            [putItemRequest.item setValue:value forKey:@"Commentor"];
            
            value = [[DynamoDBAttributeValue alloc] initWithS:self.textField.text];
            [putItemRequest.item setValue:value forKey:@"CommentText"];
            
            [self.ddb putItem:putItemRequest];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        @finally {
            
        }
    
    
    
}
- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)send:(id)sender {
    //get the recent time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd-HH:mm:ss";
    [self textUpload];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
