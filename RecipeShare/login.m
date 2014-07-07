//
//  login.m
//  RecipeShare
//
//  Created by SongShiyu on 4/25/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//
#import "login.h"
#import "ss4556AppDelegate.h"
#import "Constants.h"

@interface login ()

@end

@implementation login

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.password.secureTextEntry=YES;

    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    [self.loginbutton setStyleType:ACPButtonOK];
    [self.loginbutton setLabelTextColor:[UIColor whiteColor] highlightedColor:[UIColor greenColor] disableColor:nil];
    [self.loginbutton setLabelFont:[UIFont fontWithName:@"Trebuchet MS" size:20]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)loginin:(id)sender {
    
    @try {
        if([self.username.text isEqual: @""]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Username cannot be empty!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        };
        if([self.password.text isEqual: @""]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password cannot be empty!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        };
        //get record from dynamo db
        DynamoDBGetItemRequest *getItemRequest = [DynamoDBGetItemRequest new];
        getItemRequest.tableName = @"UserLogin";
        DynamoDBAttributeValue *userId = [[DynamoDBAttributeValue alloc] initWithS:self.username.text];
        getItemRequest.key = [NSMutableDictionary dictionaryWithObjectsAndKeys:userId, @"ID",nil];
        DynamoDBGetItemResponse *getItemResponse = [self.ddb getItem:getItemRequest];
        DynamoDBAttributeValue  *password = [getItemResponse.item valueForKey:@"password"];
        
        if (![self.password.text isEqual:password.s]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No such user or password is incorrect!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [self performSegueWithIdentifier:@"loginin" sender:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self) return;
    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    NSMutableArray *followee = [[NSMutableArray alloc]init];
    @try {
        DynamoDBCondition *condition = [DynamoDBCondition new];
        condition.comparisonOperator = @"EQ";
        DynamoDBAttributeValue * ID= [[DynamoDBAttributeValue alloc] initWithS:self.username.text];
        [condition addAttributeValueList:ID];
        NSMutableDictionary *queryStartKey = nil;
        do {
            DynamoDBQueryRequest *queryRequest = [DynamoDBQueryRequest new];
            queryRequest.tableName = @"Follow";
            queryRequest.exclusiveStartKey = queryStartKey;
            queryRequest.keyConditions = [NSMutableDictionary dictionaryWithObject:condition forKey:@"UID1"];
            DynamoDBQueryResponse *queryResponse = [ self.ddb query:queryRequest];
            for (NSDictionary *dic in  queryResponse.items) {
                DynamoDBAttributeValue *flag = [dic objectForKey:@"Flag"];
                if ([flag.s isEqualToString:@"1"]) {
                    
                }
                DynamoDBAttributeValue *uid =[dic objectForKey:@"UID2"];
                [followee addObject:uid.s];
                NSLog(@"%@",uid.s);
                
            }
            queryStartKey = queryResponse.lastEvaluatedKey;
            NSLog(@"lastevaluatedkey = '%@'", queryStartKey );
        } while ([queryStartKey count] != 0);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    NSMutableArray *follower = [[NSMutableArray alloc]init];
    @try {
        DynamoDBCondition *condition = [DynamoDBCondition new];
        condition.comparisonOperator = @"EQ";
        DynamoDBAttributeValue * ID= [[DynamoDBAttributeValue alloc] initWithS:self.username.text];
        [condition addAttributeValueList:ID];
        NSMutableDictionary *queryStartKey = nil;
        do {
            DynamoDBQueryRequest *queryRequest = [DynamoDBQueryRequest new];
            queryRequest.tableName = @"Followed";
            queryRequest.exclusiveStartKey = queryStartKey;
            queryRequest.keyConditions = [NSMutableDictionary dictionaryWithObject:condition forKey:@"UID2"];
            DynamoDBQueryResponse *queryResponse = [ self.ddb query:queryRequest];
            for (NSDictionary *dic in  queryResponse.items) {
                DynamoDBAttributeValue *flag = [dic objectForKey:@"Flag"];
                if ([flag.s isEqualToString:@"1"]) {
                    
                }
                DynamoDBAttributeValue *uid =[dic objectForKey:@"UID1"];
                [follower addObject:uid.s];
            }
            queryStartKey = queryResponse.lastEvaluatedKey;
            NSLog(@"lastevaluatedkey = '%@'", queryStartKey );
        } while ([queryStartKey count] != 0);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.follow = followee;
    appDelegate.followed = follower;
    appDelegate.username=self.username.text;
    appDelegate.password=self.password.text;
}

//dispose the keyboard
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.username|| theTextField == self.password) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

@end
