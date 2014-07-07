//
//  ManageFollowViewController.m
//  RecipeShare
//
//  Created by D L on 5/11/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "ManageFollowViewController.h"
#import "Constants.h"
#import <AWSRuntime/AWSRuntime.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "MBProgressHUD.h"
#import "ss4556AppDelegate.h"
#import "ManageFollowTableViewCell.h"
@interface ManageFollowViewController ()
@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) AmazonDynamoDBClient *ddb;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSMutableArray *followee;
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSMutableArray *deleteData;
@end

@implementation ManageFollowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    self.uid= appDelegate.username;
    self.deleteData =  [[NSMutableArray alloc]init];
    //load follow list
    [self loadFollowee:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table reloadData];
        });
        //NSLog(@"view did load, reload");
    }];
    [super viewDidLoad];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark load follow list
-(void)loadFollowee:(void(^)())completion
{
    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    NSMutableArray *followee = [[NSMutableArray alloc]init];
    @try {
        DynamoDBCondition *condition = [DynamoDBCondition new];
        condition.comparisonOperator = @"EQ";
        DynamoDBAttributeValue * ID= [[DynamoDBAttributeValue alloc] initWithS:self.uid];
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
    self.tableData = followee;
    completion();
}
#pragma mark cell button delegate
-(void)cellDeleteAtIndexpath:(NSIndexPath*)path{
    NSLog(@"delete button pressed");
    NSString *fol = self.tableData[path.row];
    [self.deleteData addObject:fol];
}
#pragma mark cell botton delegate
-(void)cellCancelDeleteAtIndexpath:(NSIndexPath*)path{
    NSString *fol = self.tableData[path.row];
    for (NSString *s in self.deleteData) {
        if ([fol isEqualToString:s]) {
            //NSLog(s);
            [self.deleteData removeObject:s];
            break;
        }
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}
#pragma mark set cell information
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if (indexPath.row >= self.tableData.count) {
     return NULL;
     }*/
    static NSString * identifier=@"ManageCell";
    ManageFollowTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[ManageFollowTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.delegate = self;
    NSString * name = [self.tableData objectAtIndex:indexPath.row];
    //[cell setMessage:data[@"String1"]];
    cell.name.text = name;
    //NSLog(name);
    NSData *imageData1=[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",name,@"-profile.jpeg"]]];
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
#pragma mark resize images
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

- (IBAction)confirm:(id)sender {
    for (NSString *s in self.deleteData) {
        NSLog(@"%@",s);
        
        
    }
    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    dispatch_async(loadQueue, ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Uploading";
        [hud show:YES];
        for (NSString* uid in self.deleteData) {
            DynamoDBDeleteItemRequest *deleteItemRequest = [DynamoDBDeleteItemRequest new];
            deleteItemRequest.tableName = @"Follow";
            DynamoDBAttributeValue *value = [[DynamoDBAttributeValue alloc] initWithS:self.uid];
            [deleteItemRequest.key setValue:value forKey:@"UID1"];
            value = [[DynamoDBAttributeValue alloc] initWithS:uid];
            [deleteItemRequest.key setValue:value forKey:@"UID2"];
            [self.ddb deleteItem:deleteItemRequest];
            deleteItemRequest = [DynamoDBDeleteItemRequest new];
            deleteItemRequest.tableName = @"Followed";
            
            // Need to specify the key of our item, which is an NSDictionary of our primary key attribute(s)
            value = [[DynamoDBAttributeValue alloc] initWithS:uid];
            [deleteItemRequest.key setValue:value forKey:@"UID2"];
            value = [[DynamoDBAttributeValue alloc] initWithS:self.uid];
            [deleteItemRequest.key setValue:value forKey:@"UID1"];
            [self.ddb deleteItem:deleteItemRequest];
        }
        [self loadFollowee:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.table reloadData];
            });
            //NSLog(@"view did load, reload");
        }];
        [hud hide:YES];
    });
}
@end
