//
//  Favorite.m
//  RecipeShare
//
//  Created by SongShiyu on 5/5/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "Favorite.h"
#import "ss4556AppDelegate.h"
#import "FavoriteCell.h"
#import "Entity.h"



@interface Favorite ()
@property (strong, nonatomic) IBOutlet UITableView *listView;


@end

@implementation Favorite

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

-(void)viewDidAppear:(BOOL)animated{
    //Load Entities from Core Data.
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    
    NSError *error;
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity =[NSEntityDescription entityForName:@"Entity" inManagedObjectContext: _managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *temp = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    _entityArray=[temp mutableCopy];
    
    NSLog(@"%lu",(unsigned long)[_entityArray count]);
    //for (int i=0; i<(unsigned long)[_entityArray count]; i++) {
        //Entity *pEnt = (Entity*) _entityArray[i];
        /*NSLog (@"name:%@", pEnt.name);
        NSLog (@"ingredient:%@", pEnt.ingredient);
        NSLog (@"image:%@", pEnt.image);
        NSLog (@"process1:%@", pEnt.process1);
        NSLog (@"process2:%@", pEnt.process2);
        NSLog (@"process3:%@", pEnt.process3);*/

    //}
    
    if ([self.entityArray count]==0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There is no result" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
  [self.listView reloadData];
    
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
    NSLog (@"menu size: %lu", (unsigned long)[self.entityArray count]);
    
    return [self.entityArray count];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *TableIdentifier =@"FavoriteCell";
    FavoriteCell *cell=(FavoriteCell *)[tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    if(cell==nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FavoriteCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    Entity *ent= self.entityArray[indexPath.row];
    //NSData* data = [Base64 decode:ent.image];
    //cell.foodimage.image = [UIImage imageWithData:data];
    id image =ent.image;
    NSLog(@"caonima:%@",ent.image);
    if ([image isKindOfClass:[NSString class]]) {
        NSData *imageData=[NSData dataWithContentsOfURL:[NSURL URLWithString:image]];
        UIImage *imageView = [UIImage imageWithData:imageData];
        cell.foodimage.image = imageView;
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.cellChosen=indexPath;
    
    Entity *ent= self.entityArray[self.cellChosen.row];
    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.entity=ent;
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
}

@end
