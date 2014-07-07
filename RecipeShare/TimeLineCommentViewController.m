//
//  TimeLineCommentViewController.m
//  RecipeShare
//
//  Created by D L on 5/11/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "TimeLineCommentViewController.h"   
#import "Constants.h"
#import <AWSRuntime/AWSRuntime.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "MBProgressHUD.h"
#import "ss4556AppDelegate.h"
#import "TimeLineCommentTableViewCell.h"
#import <QuartzCore/QuartzCore.h>



@interface TimeLineCommentViewController ()
@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSMutableArray *commentTable;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) AmazonDynamoDBClient *ddb;

@end

@implementation TimeLineCommentViewController

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
    //set pull down to refresh
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.comments addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    //set keyboard automatic going up
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeKeyBoard:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //tap to dismiss keyboard
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    //set the share post details
    NSMutableDictionary *data = self.data;
    if ([data objectForKey:@"Image"] != NULL) {
        [self.text2 setHidden:YES];
        self.image.image = [UIImage imageWithData:[data objectForKey:@"Image"]];
        [self.text setText:[data objectForKey:@"String1"]];
    }else{
        [self.image setHidden:YES];
        [self.text setHidden:YES];
        [self.text2 setText:[data objectForKey:@"String1"]];
    }
    self.time.text = [data objectForKey:@"Time"];
    self.user.text = [data objectForKey:@"UID2"];
    NSData *imageData1=[NSData dataWithContentsOfURL:[NSURL URLWithString:self.icon]];
    CGSize size = CGSizeMake(50.0f, 50.0f);
    if(imageData1==NULL){
        UIImage *newImage = [self imageByScalingAndCroppingForSize:size from:[UIImage imageNamed:@"chef-icon"]];
        self.head.image = newImage;
    }else{
        UIImage *newImage = [self imageByScalingAndCroppingForSize:size from:[UIImage imageWithData:imageData1]];
        self.head.image = newImage;
    }
    //get the uid
    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    self.uid= appDelegate.username;
    //initial data loading
    [self loadData:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.comments reloadData];
        });
    }];
}
#pragma mark pull down to refresh method
- (void)refreshTable {
    [self loadData:^{
        //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //[formatter setDateFormat:@"MMM d, h:mm a"];
        //NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
        //self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.comments reloadData];
            //[self.comments reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
            [self.refreshControl endRefreshing];
        });
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark limit textfield charactor length
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newText.length > TEXT_LENGTH) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can only type in 30 charactors" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    } else {
        return YES;
    }
}
#pragma mark load comments method
- (void)loadData:(void(^)())completion
{
    //123
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading comments";
    [hud show:YES];
    //123
    NSMutableDictionary *data = self.data;
    dispatch_async(loadQueue, ^{
        AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        @try {
            DynamoDBCondition *condition = [DynamoDBCondition new];
            condition.comparisonOperator = @"EQ";
            DynamoDBAttributeValue * ID= [[DynamoDBAttributeValue alloc] initWithS:[NSString stringWithFormat:@"%@%@",[data objectForKey:@"UID2"],[data objectForKey:@"Time"]]];
            
            [condition addAttributeValueList:ID];
            
            NSMutableDictionary *queryStartKey = nil;
            do {
                DynamoDBQueryRequest *queryRequest = [DynamoDBQueryRequest new];
                queryRequest.tableName = @"TimeLineComment";
                queryRequest.exclusiveStartKey = queryStartKey;
                queryRequest.keyConditions = [NSMutableDictionary dictionaryWithObject:condition forKey:@"CID"];
                DynamoDBQueryResponse *queryResponse = [ self.ddb query:queryRequest];
                
                // Each item in the result set is a NSDictionary of DynamoDBAttributeValue
                for (NSDictionary *item in queryResponse.items) {
                    //DynamoDBAttributeValue *time = [item objectForKey:@"Time"];
                    //NSLog(@"Type = '%@'", item);
                    NSMutableDictionary *oneItem = [[NSMutableDictionary alloc]init];
                    DynamoDBAttributeValue *itemTime = item[@"Time"];
                    [oneItem setValue:itemTime.s forKey:@"Time"];
                    DynamoDBAttributeValue *itemUID = item[@"UID"];
                    [oneItem setValue:itemUID.s forKey:@"UID"];
                    DynamoDBAttributeValue *itemString = item[@"String"];
                    [oneItem setValue:itemString.s forKey:@"String"];
                    [temp addObject:oneItem];
                    NSLog(@"Type = '%@'", [oneItem objectForKey:@"UID"]);
                    NSLog(@"Time = '%@'", [oneItem objectForKey:@"Time"]);
                    NSLog(@"string1 = '%@'",[oneItem objectForKey:@"String"]);
                }
                
                queryStartKey = queryResponse.lastEvaluatedKey;
            } while ([queryStartKey count] != 0);
            self.commentTable=temp;
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        @finally {
            dispatch_sync(dispatch_get_main_queue(), ^{
                //123
                [hud hide:YES];
                //123
            });
        }
        completion();
    });
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentTable.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier=@"TimeLineCommentCell";
    TimeLineCommentTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[TimeLineCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    NSMutableDictionary *data=[self.commentTable objectAtIndex:self.commentTable.count-1-indexPath.row];
    cell.name.text = [data objectForKey:@"UID"];
    cell.comment.text = [data objectForKey:@"String"];
    cell.time.text =[data objectForKey:@"Time"];
    //get the icon in the image
    NSData *imageData1=[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",[data objectForKey:@"UID"],@"-profile.jpeg"]]];
    CGSize size = CGSizeMake(50.0f, 50.0f);
    if(imageData1==NULL){
        UIImage *newImage = [self imageByScalingAndCroppingForSize:size from:[UIImage imageNamed:@"chef-icon"]];
        cell.head.image = newImage;
    }else{
        UIImage *newImage = [self imageByScalingAndCroppingForSize:size from:[UIImage imageWithData:imageData1]];
        cell.head.image = newImage;
    }

    return cell;
}

#pragma mark dismiss keyboard
-(void)handleTap:(UIGestureRecognizer *)gesture
{
    [self.myComment endEditing:YES];
}
#pragma mark send text
- (void) textUpload: (NSString *)uid2 time: (NSString *) time :(void(^)())completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Uploading";
        [hud show:YES];
        DynamoDBPutItemRequest *putItemRequest = [DynamoDBPutItemRequest new];
        putItemRequest.tableName = @"TimeLineComment";
        
        DynamoDBAttributeValue *value = [[DynamoDBAttributeValue alloc] initWithS:self.uid];
        [putItemRequest.item setValue:value forKey:@"UID"];
        value = [[DynamoDBAttributeValue alloc] initWithS:time];
        [putItemRequest.item setValue:value forKey:@"Time"];
        value = [[DynamoDBAttributeValue alloc] initWithS:[NSString stringWithFormat:@"%@%@",[self.data objectForKey:@"UID2"],[self.data objectForKey:@"Time"]]];
        [putItemRequest.item setValue:value forKey:@"CID"];
        value = [[DynamoDBAttributeValue alloc] initWithS:self.myComment.text];
        [putItemRequest.item setValue:value forKey:@"String"];
        [self.ddb putItem:putItemRequest];
        
        [hud hide:YES];
        completion();
        
    });
    
    
}
#pragma mark detect keyboard change so the list view would go up if keyboard appears
-(void)changeKeyBoard:(NSNotification *)aNotifacation
{
    
    NSValue *keyboardBeginBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyboardBeginBounds CGRectValue];
    NSValue *keyboardEndBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect endRect=[keyboardEndBounds CGRectValue];
    
    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
    
    NSLog(@"deltaY:%f",deltaY);
    [CATransaction begin];
    [UIView animateWithDuration:0.4f animations:^{
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+deltaY, self.view.frame.size.width, self.view.frame.size.height)];
        [self.comments setContentInset:UIEdgeInsetsMake(self.comments.contentInset.top-deltaY, 0, 0, 0)];
        
    } completion:^(BOOL finished) {
        
    }];
    [CATransaction commit];
    
}
#pragma mark resize image method
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize from:(UIImage*)image
{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)send:(id)sender {
    if([self.myComment.text isEqualToString: @""]){
        return;
    }
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd-HH:mm:ss";
    NSString *time = [dateFormatter stringFromDate:now];
    [self textUpload:self.uid time:time:^{
        [self loadData:^{
            //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            //[formatter setDateFormat:@"MMM d, h:mm a"];
            //NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
            //self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.comments reloadData];
                self.myComment.text = @"";
            });
        }];
    }];
}
@end
