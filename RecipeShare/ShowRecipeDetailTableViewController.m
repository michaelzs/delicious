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
#import <AWSS3/AWSS3.h>
#import "Constants.h"
#import "CommentCell.h"
#import "FollowLikeCell.h"
#import "ss4556AppDelegate.h"
#import "Entity.h"
#import "DetailCommentViewController.h"
#import <AWSRuntime/AWSRuntime.h>

@interface ShowRecipeDetailTableViewController ()

@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation ShowRecipeDetailTableViewController
@synthesize detailData;
@synthesize ddb;
// Get comment all the comment of the recipe
- (void )getcomment:(NSString *)recipeID{
    
    NSLog(@"The recipeID is %@",recipeID);

    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
    
    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    @try {
        self.commentdata = [[NSMutableArray alloc] init];
        DynamoDBCondition *condition = [DynamoDBCondition new];
        condition.comparisonOperator = @"EQ";
        DynamoDBAttributeValue * recipeIDAtr= [[DynamoDBAttributeValue alloc] initWithS:recipeID];
        [condition addAttributeValueList:recipeIDAtr];
        
        NSMutableDictionary *queryStartKey = nil;
        do {
            DynamoDBQueryRequest *queryRequest = [DynamoDBQueryRequest new];
            queryRequest.tableName = @"Comment";
            queryRequest.exclusiveStartKey = queryStartKey;
            queryRequest.keyConditions = [NSMutableDictionary dictionaryWithObject:condition forKey:@"RecipeID"];
            
            DynamoDBQueryResponse *queryResponse = [ self.ddb query:queryRequest];
            
            // Each item in the result set is a NSDictionary of DynamoDBAttributeValue
            for (NSDictionary *item in queryResponse.items) {
                //DynamoDBAttributeValue *time = [item objectForKey:@"Time"];
                [self.commentdata addObject:item];
                NSLog(@"Commentor = '%@'", item[@"Commentor"] );
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
    
}

// Implement the Like function
- (IBAction)like:(id)sender {
    NSLog(@"%@",@"like");
    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    DynamoDBPutItemRequest *putItemRequest = [DynamoDBPutItemRequest new];
    putItemRequest.tableName = @"";


   
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    NSError *saveError = [NSError new];
    NSError *error;
    
    // check if added
    DynamoDBAttributeValue *name= self.detailData[@"name"];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Entity"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name = %@", name.s];
    [fetchRequest setPredicate:predicate];
    NSArray *entityArray =[_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if([entityArray count] > 0){
        return;
    }
    
    // add new entry
    Entity *ent =[NSEntityDescription insertNewObjectForEntityForName:@"Entity" inManagedObjectContext:self.managedObjectContext];

    ent.name = name.s;
    DynamoDBAttributeValue *ingredient= self.detailData[@"Ingredients"];
    ent.ingredient= ingredient.s;
    DynamoDBAttributeValue *process1= self.detailData[@"process1"];
    ent.process1= process1.s;
    DynamoDBAttributeValue *process2= self.detailData[@"process2"];
    ent.process2= process2.s;
    DynamoDBAttributeValue *process3= self.detailData[@"process3"];
    ent.process3= process3.s;
    DynamoDBAttributeValue *time= self.detailData[@"Time"];
    NSString *datetime= time.s;
    DynamoDBAttributeValue *rId= self.detailData[@"ID"];
    ent.image=[NSString stringWithFormat:@"%@%@%@%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",rId.s,@"-",datetime,@".jpeg" ];
    
    [self.managedObjectContext save:&saveError];
    NSLog (@"name:%@", ent.name);
    NSLog (@"ingredient:%@", ent.ingredient);
    NSLog (@"image:%@", ent.image);
    NSLog (@"process1:%@", ent.process1);
    NSLog (@"process2:%@", ent.process2);
    NSLog (@"process3:%@", ent.process3);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Like success!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];

    
}
//Implement follow function
- (IBAction)follow:(id)sender {
    NSLog(@"%@",@"follow");
    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    DynamoDBPutItemRequest *putItemRequest = [DynamoDBPutItemRequest new];
    putItemRequest.tableName = @"Follow";
    
    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    NSString *selfId= appDelegate.username;
    
    // Each attribute will be a DynamoDBAttributeValue

    DynamoDBAttributeValue *fId= self.detailData[@"ID"];
    DynamoDBAttributeValue *value = [[DynamoDBAttributeValue alloc] initWithS:selfId];
    [putItemRequest.item setValue:value forKey:@"UID1"];
                            value = [[DynamoDBAttributeValue alloc] initWithS:fId.s];
    [putItemRequest.item setValue:value forKey:@"UID2"];
    [self.ddb putItem:putItemRequest];
    
    putItemRequest = [DynamoDBPutItemRequest new];
    putItemRequest.tableName =@"Followed";
    value=[[DynamoDBAttributeValue alloc] initWithS:fId.s];
    [putItemRequest.item setValue:value forKey:@"UID2"];
    value = [[DynamoDBAttributeValue alloc] initWithS:selfId];
    [putItemRequest.item setValue:value forKey:@"UID1"];
    [self.ddb putItem:putItemRequest];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Follow success!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

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
    
    DynamoDBAttributeValue *rId= self.detailData[@"ID"];
    DynamoDBAttributeValue *rtime= self.detailData[@"Time"];
    NSString *recipeID = [NSString stringWithFormat:@"%@-%@",rId.s,rtime.s];
    [self getcomment:recipeID];
    
    
    
    
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
    if([self.flag isEqualToString:@"fromMain"])
    return 3+[self.commentdata count];
    else
        return 2+[self.commentdata count];
    
}

//For different row display different cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    if([self.flag isEqualToString:@"fromMain"]){
    
    if(indexPath.row==2){
        static NSString *TableIdentifier =@"FollowLike";
        FollowLikeCell *cell=(FollowLikeCell  *)[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
        if(cell==nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FollowLike" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        UIImage *background = [UIImage imageNamed:@"like.png"];;
        
        UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
        cellBackgroundView.image = background;
        [cell.like setBackgroundImage:background forState:UIControlStateNormal];
        
        UIImage *followbackground = [UIImage imageNamed:@"follow.png"];;
        
        UIImageView *followcellBackgroundView = [[UIImageView alloc] initWithImage:followbackground];
        followcellBackgroundView.image = followbackground;
        [cell.follow setBackgroundImage:followbackground forState:UIControlStateNormal];
        
        UIImage *commentbackground = [UIImage imageNamed:@"comment.png"];;
        
        UIImageView *commentcellBackgroundView = [[UIImageView alloc] initWithImage:commentbackground];
        commentcellBackgroundView.image = commentbackground;
        [cell.comment setBackgroundImage:commentbackground forState:UIControlStateNormal];
        
        
        return cell;
        
    }

    if(indexPath.row==0){
    static NSString *TableIdentifier =@"RecipeImageCell";
    RecipeImageCell *cell=(RecipeImageCell  *)[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    if(cell==nil){
       NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecipeImageCell" owner:self options:nil];
       cell = [nib objectAtIndex:0];
    }
        DynamoDBAttributeValue *rId= self.detailData[@"ID"];
        DynamoDBAttributeValue *rtime= self.detailData[@"Time"];
        
        NSString *imagefile=[NSString stringWithFormat:@"%@%@%@%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",rId.s,@"-",rtime.s,@".jpeg" ];
        dispatch_async(loadQueue, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            NSData *imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:imagefile]];
            
            if(imageData){
                UIImage *imageView = [UIImage imageWithData:imageData];
                if(imageView){
                    RecipeImageCell *updatecell = (id) [tableView cellForRowAtIndexPath:indexPath];
                    updatecell.RecipeImage.image=imageView;
                }
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
        DynamoDBAttributeValue *ruser= self.detailData[@"ID"];
        DynamoDBAttributeValue *rname= self.detailData[@"name"];
        DynamoDBAttributeValue *rIngredients= self.detailData[@"Ingredients"];
        DynamoDBAttributeValue *rprocess1= self.detailData[@"process1"];
        DynamoDBAttributeValue *rprocess2= self.detailData[@"process2"];
        DynamoDBAttributeValue *rprocess3= self.detailData[@"process3"];
        cell.user.text=ruser.s;
        cell.name.text=rname.s;
        cell.ingredient.text=rIngredients.s;
        cell.process1.text=rprocess1.s;
        cell.process2.text=rprocess2.s;
        cell.process3.text=rprocess3.s;
        
        return cell;
 }
    
    else{
        static NSString *TableIdentifier =@"comment";
        CommentCell *cell=(CommentCell *)[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
        if(cell==nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"comment" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        NSDictionary *item= [self.commentdata objectAtIndex:(indexPath.row-3)];
        
        DynamoDBAttributeValue *commentor= item[@"Commentor"];
        DynamoDBAttributeValue *comment= item[@"CommentText"];

        cell.name.text=commentor.s;
        cell.comment.text=comment.s;
        
        NSLog(@"The commentor is %@",commentor.s);
        NSLog(@"The comment is %@",comment.s);
        

        
        NSString *imagefile=[NSString stringWithFormat:@"%@%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",commentor.s,@"-profile.jpeg" ];
        dispatch_async(loadQueue, ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                NSData *imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:imagefile]];
                
                if(imageData){
                    UIImage *imageView = [UIImage imageWithData:imageData];
                    if(imageView){
                        CGSize size= CGSizeMake(100.0f, 100.0f);
                        imageView=[self imageByScalingAndCroppingForSize:size image:imageView];
                       CommentCell *updatecell = (id) [tableView cellForRowAtIndexPath:indexPath];
                        updatecell.userImage.image=imageView;
                    }
                }
                
            });
        });


       /*
        UIImage *background = [UIImage imageNamed:@"gray_background.png"];
        
        UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
        cellBackgroundView.image = background;
        cell.backgroundView = cellBackgroundView;
        */

        return cell;
        
        
    }
    }
    else {
    
        if(indexPath.row==0){
            static NSString *TableIdentifier =@"RecipeImageCell";
            RecipeImageCell *cell=(RecipeImageCell  *)[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
            if(cell==nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecipeImageCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            DynamoDBAttributeValue *rId= self.detailData[@"ID"];
            DynamoDBAttributeValue *rtime= self.detailData[@"Time"];
            
            NSString *imagefile=[NSString stringWithFormat:@"%@%@%@%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",rId.s,@"-",rtime.s,@".jpeg" ];
            dispatch_async(loadQueue, ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    NSData *imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:imagefile]];
                    
                    if(imageData){
                        UIImage *imageView = [UIImage imageWithData:imageData];
                        if(imageView){
                            RecipeImageCell *updatecell = (id) [tableView cellForRowAtIndexPath:indexPath];
                            updatecell.RecipeImage.image=imageView;
                        }
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
            DynamoDBAttributeValue *ruser= self.detailData[@"ID"];
            DynamoDBAttributeValue *rname= self.detailData[@"name"];
            DynamoDBAttributeValue *rIngredients= self.detailData[@"Ingredients"];
            DynamoDBAttributeValue *rprocess1= self.detailData[@"process1"];
            DynamoDBAttributeValue *rprocess2= self.detailData[@"process2"];
            DynamoDBAttributeValue *rprocess3= self.detailData[@"process3"];
            cell.user.text=ruser.s;
            cell.name.text=rname.s;
            cell.ingredient.text=rIngredients.s;
            cell.process1.text=rprocess1.s;
            cell.process2.text=rprocess2.s;
            cell.process3.text=rprocess3.s;
            
            return cell;
        }
        
        else{
            static NSString *TableIdentifier =@"comment";
            CommentCell *cell=(CommentCell *)[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
            if(cell==nil){
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"comment" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            NSDictionary *item= [self.commentdata objectAtIndex:(indexPath.row-2)];
            
            DynamoDBAttributeValue *commentor= item[@"Commentor"];
            DynamoDBAttributeValue *comment= item[@"CommentText"];
            
            cell.name.text=commentor.s;
            cell.comment.text=comment.s;
            NSLog(@"Comment is %@",cell.comment.text);
            
            NSString *imagefile=[NSString stringWithFormat:@"%@%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",commentor.s,@"-profile.jpeg" ];
            dispatch_async(loadQueue, ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    NSData *imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:imagefile]];
                    
                    if(imageData){
                        UIImage *imageView = [UIImage imageWithData:imageData];
                        if(imageView){
                            CGSize size= CGSizeMake(100.0f, 100.0f);
                            imageView=[self imageByScalingAndCroppingForSize:size image:imageView];
                           CommentCell *updatecell = (id) [tableView cellForRowAtIndexPath:indexPath];
                            updatecell.userImage.image=imageView;
                        }
                    }
                    
                });
            });
            
            /*
            
            UIImage *background = [UIImage imageNamed:@"gray_background.png"];
            
            UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
            cellBackgroundView.image = background;
            cell.backgroundView = cellBackgroundView;
             */
            
            return cell;
            
            
        }
    
    }
    
    

    
    
}

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize image:(UIImage*) userImage
{
    UIImage *sourceImage = userImage;
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.flag isEqualToString:@"fromMain"]){
        if(indexPath.row==2)return 50.0;
    else if(indexPath.row==0)return 157.0;
    else if(indexPath.row==1) return 300.0;
    else return 100.0;
    }
    else {
        if(indexPath.row==0)return 157.0;
        else if(indexPath.row==1) return 300.0;
        else return 100.0;
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Comment"]) {
        DetailCommentViewController *receiver = [segue destinationViewController];
        DynamoDBAttributeValue *rId= self.detailData[@"ID"];
        DynamoDBAttributeValue *rtime= self.detailData[@"Time"];
        receiver.ruid = rId.s;
        receiver.rtime =rtime.s;
        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

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
