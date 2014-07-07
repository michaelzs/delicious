//
//  SliderMainViewController.m
//  RecipeShare
//
//  Created by D L on 5/5/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "SliderMainViewController.h"
#import <AWSRuntime/AWSRuntime.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Constants.h"
#import "ShowRecipeDetailTableViewController.h"
#import "MBProgressHUD.h"
#import "Constants.h"
@interface SliderMainViewController ()
@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) AmazonDynamoDBClient *ddb;
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) NSDictionary *sendData;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong)NSString *uID;
@property (nonatomic, strong) NSMutableArray *imageData;

@end

@implementation SliderMainViewController

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
    //123
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshRecipe) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    //123
    self.collectionView.alwaysBounceVertical = YES;
    //[self.view addSubview:refreshControl];
    [self loadRecipe];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) refreshRecipe{
    //123
    [self loadRecipe];
    [self.refreshControl endRefreshing];
    //123
}
- (void) loadRecipe
{
    //123
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    [hud show:YES];
    //123
    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    NSMutableArray *tempp = [[NSMutableArray alloc]init];
    @try {
        self.tableData = [[NSMutableArray alloc] init];
        DynamoDBScanRequest *request = [[DynamoDBScanRequest alloc] initWithTableName:@"RecipeData"];
        DynamoDBScanResponse *response = [self.ddb scan:request];
        tempp = response.items;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"Time.s"  ascending:YES];
    self.tableData = [[tempp sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] copy];
    NSMutableArray *temp = [[NSMutableArray alloc]init];
    for(NSDictionary *data in self.tableData){
        DynamoDBAttributeValue *Id= data[@"ID"];
        DynamoDBAttributeValue *time= data[@"Time"];
        //DynamoDBAttributeValue *name= data[@"name"];
        NSString *imagefile1=[NSString stringWithFormat:@"%@%@%@%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",Id.s,@"-",time.s,@".jpeg" ];
        NSData *imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:imagefile1]];
        [temp addObject:imageData];
    }
    self.imageData = temp;
    //123
    [hud hide:YES];
    //123
}
-(NSInteger)numberOfItemsInSlidingMenu{
    // 10 for demo purposes, typically the count of some array
    return self.tableData.count;
}

- (void)customizeCell:(RPSlidingMenuCell *)slidingMenuCell forRow:(NSInteger)row{
    dispatch_async(loadQueue, ^{
        NSDictionary *data = [self.tableData objectAtIndex:self.tableData.count-row-1];
        DynamoDBAttributeValue *Id= data[@"ID"];
        //DynamoDBAttributeValue *time= data[@"Time"];
        DynamoDBAttributeValue *name= data[@"name"];
        //NSString *imagefile1=[NSString stringWithFormat:@"%@%@%@%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",Id.s,@"-",time.s,@".jpeg" ];
        NSData *imageData=[self.imageData objectAtIndex:self.tableData.count-row-1];
        if(imageData){
            UIImage *imageView1 = [UIImage imageWithData:imageData];
            if(imageView1){
                dispatch_sync(dispatch_get_main_queue(), ^{
                    slidingMenuCell.textLabel.text = name.s;
                    slidingMenuCell.detailTextLabel.text = Id.s;
                    slidingMenuCell.backgroundImageView.image = imageView1;
                });
            }
        }
    });
}

- (void)slidingMenu:(RPSlidingMenuViewController *)slidingMenu didSelectItemAtRow:(NSInteger)row{
    self.sendData = [self.tableData objectAtIndex:self.tableData.count-1-row];
    //[super slidingMenu:slidingMenu didSelectItemAtRow:row];
     NSLog(@"perform");
    [self performSegueWithIdentifier:@"MainToDetail" sender:self];
    // when a row is tapped do some action
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Row Tapped"
                                                    message:[NSString stringWithFormat:@"Row %ld tapped.", (long)row]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];*/
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MainToDetail"]) {
         ShowRecipeDetailTableViewController *receiver = [segue destinationViewController];
        receiver.detailData = self.sendData;
        NSLog(@"%@",receiver.detailData);
        receiver.flag = @"fromMain";
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
}


@end
