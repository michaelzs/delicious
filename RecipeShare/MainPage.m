//
//  MainPage.m
//  RecipeShare
//
//  Created by SongShiyu on 4/25/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "MainPage.h"
#import <AWSRuntime/AWSRuntime.h>
#import "Constants.h"
#import "RecipeMainCell.h"
#import "ss4556AppDelegate.h"

@interface MainPage ()

@end

@implementation MainPage


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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    

}

- (void)viewDidAppear:(BOOL)animated{
    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
    
    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    [self loadRecipe];
    
}

- (void) loadRecipe
{
    @try {
        self.tableData = [[NSMutableArray alloc] init];
        
       
        DynamoDBScanRequest *request = [[DynamoDBScanRequest alloc] initWithTableName:@"RecipeData"];
        DynamoDBScanResponse *response = [self.ddb scan:request];
        self.tableData = response.items;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableIdentifier =@"RecipeMainCell";
    RecipeMainCell *cell=(RecipeMainCell *)[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    if(cell==nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecipeMainCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    
    
    
    // Configure the cell...
    dispatch_async(loadQueue, ^{
        NSDictionary *data = self.tableData[indexPath.row];
        DynamoDBAttributeValue *Id= data[@"ID"];
        DynamoDBAttributeValue *time= data[@"Time"];
        NSString *imagefile1=[NSString stringWithFormat:@"%@%@%@%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",Id.s,@"-",time.s,@".jpeg" ];
        NSData *imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:imagefile1]];
        
        if(imageData){
            UIImage *imageView = [UIImage imageWithData:imageData];
            if(imageView){
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    RecipeMainCell *updatecell = (id) [tableView cellForRowAtIndexPath:indexPath];
                    
                    if(updatecell){
                        
                        updatecell.recipeImage.image = imageView;

                    }
                    
                });
                
            }
            
        }

        
        
    });
    
    return cell;
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
