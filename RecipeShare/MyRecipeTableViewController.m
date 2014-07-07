//
//  MyRecipeTableViewController.m
//  RecipeShare
//
//  Created by Zhan Shu on 4/29/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "MyRecipeTableViewController.h"
#import <AWSRuntime/AWSRuntime.h>
#import "Constants.h"
#import "RecipeViewCell.h"

#import "ss4556AppDelegate.h"
#import "ShowRecipeDetailTableViewController.h"

@interface MyRecipeTableViewController ()

@end

@implementation MyRecipeTableViewController
@synthesize tableData;
@synthesize recipeTableview;
@synthesize uID;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_logoutbutton setStyleType:ACPButtonCancel];
    [_logoutbutton setCornerRadius:100];
    [_addreciepe setStyleType:ACPButtonCancel];
    [_addreciepe setCornerRadius:100];


    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    self.uID= appDelegate.username;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    //refreshControl.tintColor = [UIColormagentaColor];
    self.refreshControl = refreshControl;
   [refreshControl addTarget:self action:@selector(loadRecipe) forControlEvents:UIControlEventValueChanged];

    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
    
    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    [self loadRecipe];
    NSLog(@"%@",@"load recipe");

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Load all recipe for the user
- (void) loadRecipe
{
    @try {
        self.tableData = [[NSMutableArray alloc] init];
        DynamoDBCondition *condition = [DynamoDBCondition new];
        condition.comparisonOperator = @"EQ";
        DynamoDBAttributeValue * ID= [[DynamoDBAttributeValue alloc] initWithS:self.uID];
        [condition addAttributeValueList:ID];
        
        NSMutableDictionary *queryStartKey = nil;
        do {
            DynamoDBQueryRequest *queryRequest = [DynamoDBQueryRequest new];
            queryRequest.tableName = @"RecipeData";
            queryRequest.exclusiveStartKey = queryStartKey;
            queryRequest.keyConditions = [NSMutableDictionary dictionaryWithObject:condition forKey:@"ID"];
            
            DynamoDBQueryResponse *queryResponse = [ self.ddb query:queryRequest];
            
            // Each item in the result set is a NSDictionary of DynamoDBAttributeValue
            for (NSDictionary *item in queryResponse.items) {
                //DynamoDBAttributeValue *time = [item objectForKey:@"Time"];
                [self.tableData addObject:item];
                NSLog(@"Time = '%@'", item[@"name"] );
            }
            
            // If the response lastEvaluatedKey has contents, that means there are more results
            queryStartKey = queryResponse.lastEvaluatedKey;
            
        } while ([queryStartKey count] != 0);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    
    // reload
        [self.recipeTableview reloadData];
        
        [self.refreshControl endRefreshing];

    
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
    if([self.tableData count]%2==0)
    return [self.tableData count]/2;
    else return [self.tableData count]/2+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableIdentifier =@"MyRecipe";
    RecipeViewCell *cell=(RecipeViewCell *)[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    if(cell==nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyRecipe" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    RecipeViewCell *upcell = (id) [tableView cellForRowAtIndexPath:indexPath];
    upcell.load1.titleLabel.text=@"loading...";
    upcell.load2.titleLabel.text=@"loading...";
    
    
    
    dispatch_async(loadQueue, ^{
        
        if ((indexPath.row*2)<[self.tableData count])
        {
        
        NSDictionary *data1 = self.tableData[indexPath.row*2];
        DynamoDBAttributeValue *Id1= data1[@"ID"];
        DynamoDBAttributeValue *time1= data1[@"Time"];
        NSString *imagefile1=[NSString stringWithFormat:@"%@%@%@%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",Id1.s,@"-",time1.s,@".jpeg" ];
        NSData *imageData1=[NSData dataWithContentsOfURL:[NSURL URLWithString:imagefile1]];
       
        
        if(imageData1){
        UIImage *imageView1 = [UIImage imageWithData:imageData1];
            if(imageView1){
                dispatch_sync(dispatch_get_main_queue(), ^{
                
                    RecipeViewCell *updatecell = (id) [tableView cellForRowAtIndexPath:indexPath];
                    
                    if(updatecell){
                        
                        updatecell.recipeImage1.image = imageView1;
                        updatecell.detailData1=data1;
                        updatecell.load1.tag=indexPath.row;
                    }
                    
                });
        
            }
            
        }
            NSLog(@"%@",imagefile1);
    }
        
        if ((indexPath.row*2+1)<[self.tableData count])
        
    {
        NSDictionary *data2 = self.tableData[indexPath.row*2+1];
        DynamoDBAttributeValue *Id2= data2[@"ID"];
        DynamoDBAttributeValue *time2= data2[@"Time"];
        NSString *imagefile2=[NSString stringWithFormat:@"%@%@%@%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",Id2.s,@"-",time2.s,@".jpeg" ];
        NSData *imageData2=[NSData dataWithContentsOfURL:[NSURL URLWithString:imagefile2]];
        
        if(imageData2){
            UIImage *imageView2 = [UIImage imageWithData:imageData2];
            if(imageView2){
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    RecipeViewCell *updatecell = (id) [tableView cellForRowAtIndexPath:indexPath];
                    if(updatecell){
                        updatecell.recipeImage2.image = imageView2;
                        updatecell.detailData2=data2;
                        updatecell.load2.tag=indexPath.row;
                    }
                    
                });
                
            }
            
        }
                 NSLog(@"%@",imagefile2);
    }

    });
    
    
    
    upcell.load1.titleLabel.text=@" ";
    upcell.load2.titleLabel.text=@" ";
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.cellSelect=indexPath;

    return indexPath;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.cellSelect=indexPath;
    
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender{
   /* UIViewController *viewControler=segue.destinationViewController;
    RecipeDetailViewController *detail=(RecipeDetailViewController *)viewControler;
    NSLog(@"The row selected is %ld",(long)self.cellSelect.row);*/
    UITableViewController *viewControler=segue.destinationViewController;
    ShowRecipeDetailTableViewController *detail =(ShowRecipeDetailTableViewController *)viewControler;
    
    if ([[segue identifier] isEqualToString:@"Recipe1"]) {
        
        detail.detailData= self.tableData[sender.tag*2];
        
    }
    if ([[segue identifier] isEqualToString:@"Recipe2"]) {
       
        detail.detailData= self.tableData[sender.tag*2+1];
         
    }
    /*if (self.choose==1){
        detail.detailData=self.detailData1;
        NSLog(@"%@",self.detailData1);
    }
    else{
        detail.detailData=self.detailData2;
        NSLog(@"%@",self.detailData2);
    }*/
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
