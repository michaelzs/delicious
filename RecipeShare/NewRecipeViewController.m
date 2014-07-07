//
//  NewRecipeViewController.m
//  RecipeShare
//
//  Created by Zhan Shu on 4/28/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "NewRecipeViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Constants.h"
#import <AWSRuntime/AWSRuntime.h>
#import "MBProgressHUD.h"
#import "ss4556AppDelegate.h"

@interface NewRecipeViewController ()
- (IBAction)Save:(id)sender;
- (IBAction)Cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *recipeImageView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *ingredientTextField;

@property (weak, nonatomic) IBOutlet UITextField *process1TextField;

@property (weak, nonatomic) IBOutlet UITextField *process2TextField;

@property (weak, nonatomic) IBOutlet UITextField *process3TextField;

@end

@implementation NewRecipeViewController

@synthesize s3 = _s3;
@synthesize ddb = _ddb;


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

    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    self.uID= appDelegate.username;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
    
    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
}

//show photo library
- (void)showPhotoLibary
{
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays saved pictures from the Camera Roll album.
    mediaUI.mediaTypes = @[(NSString*)kUTTypeImage];
    
    // Hides the controls for moving & scaling pictures
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = self;
    
    [self presentViewController:mediaUI animated:YES completion:nil];
}
// pick a image from photo library
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    UIImage *originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    self.recipeImageView.image = originalImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if (indexPath.row == 0) {
        [self showPhotoLibary];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


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
// upload the image data
- (void)imageUpload:(NSData *)imageData filename:(NSString *)filename
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Uploading";
    [hud show:YES];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:filename
                                                                 inBucket:@"jaycolumbia12345"];
        por.cannedACL = [S3CannedACL publicRead];
        por.contentType = @"image/jpeg";
        por.data        = imageData;
        
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
        
       
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(putObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.error);
                [self showAlertMessage:[putObjectResponse.error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
            }

            if(putObjectResponse.exception != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.exception);
                [self showAlertMessage:[putObjectResponse.error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
            }
            
            if(putObjectResponse.error ==nil && putObjectResponse.exception ==nil)
            [self showAlertMessage:@"The new recipe was successfully uploaded." withTitle:@"Upload Completed"];
            [hud hide:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

//upload the text infomation
- (void) textUpload: (NSString *)ID time: (NSString *) time{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // create the request, specify the table
        DynamoDBPutItemRequest *putItemRequest = [DynamoDBPutItemRequest new];
        putItemRequest.tableName = @"RecipeData";
        
        // Each attribute will be a DynamoDBAttributeValue
        
        DynamoDBAttributeValue *value = [[DynamoDBAttributeValue alloc] initWithS:ID];
        [putItemRequest.item setValue:value forKey:@"ID"];
        
        // The item is an NSMutableDictionary, keyed by the attribute name
        value = [[DynamoDBAttributeValue alloc] initWithS:time];
        [putItemRequest.item setValue:value forKey:@"Time"];
        
        if(self.nameTextField.text!=NULL){
        value = [[DynamoDBAttributeValue alloc] initWithS:self.nameTextField.text];
        [putItemRequest.item setValue:value forKey:@"name"];
        }
        
        if(self.ingredientTextField.text!=NULL){
        value = [[DynamoDBAttributeValue alloc] initWithS:self.ingredientTextField.text];
            [putItemRequest.item setValue:value forKey:@"Ingredients"];
        }
        if(self.process1TextField.text!=NULL){
        value = [[DynamoDBAttributeValue alloc] initWithS:self.process1TextField.text];
        [putItemRequest.item setValue:value forKey:@"process1"];
        }
        
        if(self.process2TextField.text!=NULL){
        value = [[DynamoDBAttributeValue alloc] initWithS:self.process2TextField.text];
        [putItemRequest.item setValue:value forKey:@"process2"];
        }
        
        if(self.process3TextField.text!=NULL){
        value = [[DynamoDBAttributeValue alloc] initWithS:self.process3TextField.text];
        [putItemRequest.item setValue:value forKey:@"process3"];
        }
        
        [self.ddb putItem:putItemRequest];
       
    });

    
}

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil] ;
    [alertView show];
}
// save the recipe
- (IBAction)Save:(id)sender {
    
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd-HH:mm:ss";
    NSString *time = [dateFormatter stringFromDate:now];
    
    NSData *imageData = UIImageJPEGRepresentation(_recipeImageView.image, 0.5);
    NSString *ID=self.uID;
    NSString *filename = [NSString stringWithFormat:@"%@-%@.jpeg", ID,time];
    [self textUpload:ID time:time];
    [self imageUpload:imageData filename:filename];
    
}

- (IBAction)Cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
