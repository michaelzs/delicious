//
//  ShowRecipeDetailTableViewController.m
//  RecipeShare
//
//  Created by Zhan Shu on 5/5/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "ShowRecipeDetailTableViewController.h"
#import "RecipeImageCell.h"
#import "RecipeTextCell.h"
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Constants.h"
#import "CommentCell.h"

@interface ShowRecipeDetailTableViewController ()


@end

@implementation ShowRecipeDetailTableViewController
@synthesize detailData;

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
    DynamoDBAttributeValue *comment= self.detailData[@"comment"];
    
    return 2+[comment.sS count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 

    if(indexPath.row==0){
    static NSString *TableIdentifier =@"RecipeImageCell";
    RecipeImageCell *cell=(RecipeImageCell  *)[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    if(cell==nil){
       NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecipeImageCell" owner:self options:nil];
       cell = [nib objectAtIndex:0];
    }
        DynamoDBAttributeValue *rId= self.detailData[@"ID"];
        DynamoDBAttributeValue *rtime= self.detailData[@"Time"];
        
        NSString *imagefile=[NSString stringWithFormat:@"%@%@%@%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",rId.s,@"-",rtime.s,@".jepg" ];
        dispatch_async(loadQueue, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSData *imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:imagefile]];
            
            if(imageData){
                UIImage *imageView = [UIImage imageWithData:imageData];
                if(imageView)
                    cell.RecipeImage.image=imageView;
            }
            
        });
        });

        
        return cell;
 
 }
    
    else if(indexPath.row==1){
    static NSString *TableIdentifier =@"RecipeTextCell";
       RecipeTextCell *cell=(RecipeTextCell *)[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
        if(cell==nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecipeTextCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        DynamoDBAttributeValue *rname= self.detailData[@"name"];
        DynamoDBAttributeValue *rIngredients= self.detailData[@"Ingredients"];
        DynamoDBAttributeValue *rprocess1= self.detailData[@"process1"];
        DynamoDBAttributeValue *rprocess2= self.detailData[@"process2"];
        DynamoDBAttributeValue *rprocess3= self.detailData[@"process3"];
        cell.name.text=rname.s;
        cell.ingredient.text=rIngredients.s;
        cell.process1.text=rprocess1.s;
        cell.process2.text=rprocess2.s;
        cell.process3.text=rprocess3.s;
       
        

        UIImage *background = [UIImage imageNamed:@"gray_background.png"];;
        
        UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
        cellBackgroundView.image = background;
        cell.backgroundView = cellBackgroundView;
        
        return cell;
 }
    
    else{
        static NSString *TableIdentifier =@"comment";
        CommentCell *cell=(CommentCell *)[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
        if(cell==nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"comment" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        DynamoDBAttributeValue *comment= self.detailData[@"comment"];
        NSString *tmp=[comment.sS objectAtIndex:(indexPath.row-2)];
        NSArray *name_comment=[tmp componentsSeparatedByString:@":"];
        cell.name.text=[[name_comment objectAtIndex:0] stringByAppendingString:@":"];
        cell.comment.text=[name_comment objectAtIndex:1];


        
        UIImage *background = [UIImage imageNamed:@"gray_background.png"];
        
        UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
        cellBackgroundView.image = background;
        cell.backgroundView = cellBackgroundView;

        return cell;
        
        
    }
    
    
    // Configure the cell...
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)return 157.0;
    else if(indexPath.row==1) return 276.0;
    else return 74.0;
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

- (IBAction)backToMain:(id)sender {
    [self performSegueWithIdentifier:@"BackToMain" sender:self];
}
@end
