//
//  SendImageViewController.m
//  RecipeShare
//
//  Created by D L on 5/4/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "SendImageViewController.h"
#import <AWSRuntime/AWSRuntime.h>
#import "MBProgressHUD.h"
#import "ss4556AppDelegate.h"
#import "Constants.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface SendImageViewController ()
@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) AmazonDynamoDBClient *ddb;
@property (nonatomic, strong) NSMutableArray *tempFollower;
@property (nonatomic, strong) NSString *UID;
@property (nonatomic, strong) NSMutableArray *followers;
@property (nonatomic, strong) NSString *flag;
@property (nonatomic, strong) UIImage*savedImage;
@end

@implementation SendImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //get the uid and the follow information
    self.charactorCounter.text=[NSString stringWithFormat:@"%i/%i",TEXTVIEW_LENGTH1,TEXTVIEW_LENGTH1];
    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    self.UID= appDelegate.username;
    self.followers = appDelegate.followed;
    [self.imageLeft setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapl = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftImageTapped)];
    [tapl setNumberOfTouchesRequired:1];
    [tapl setNumberOfTapsRequired:1];
    [self.imageLeft addGestureRecognizer:tapl];
    self.tempFollower = [[NSMutableArray alloc]init];
    [self.tempFollower addObject:@"123@123.com"];
    [self.tempFollower addObject:@"222@123.com"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)leftImageTapped{
    [self showPhotoLibary];
}
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
    
    [mediaUI setDelegate:self] ;
    [self presentViewController:mediaUI animated:YES completion:nil];
    //[self.navigationController presentModalViewController: mediaUI animated: YES];
}

- (void)imageUpload:(NSData *)imageData filename:(NSString *)filename
{
    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Uploading";
    [hud show:YES];
    dispatch_async(loadQueue, ^{
        
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
                //[self showAlertMessage:@"The new recipe was successfully uploaded." withTitle:@"Upload Completed"];
            [hud hide:YES];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

#pragma mark send text
- (void) textUpload: (NSString *)uid2 time: (NSString *) time type:(NSString *)type filename:(NSString *)filename {
    
    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Uploading";
    [hud show:YES];
    DynamoDBPutItemRequest *putItemRequest = [DynamoDBPutItemRequest new];
    putItemRequest.tableName = @"TimeLine";
    
    // Each attribute will be a DynamoDBAttributeValue
    
    DynamoDBAttributeValue *value = [[DynamoDBAttributeValue alloc] initWithS:uid2];
    [putItemRequest.item setValue:value forKey:@"UID"];
    
    // The item is an NSMutableDictionary, keyed by the attribute name
    value = [[DynamoDBAttributeValue alloc] initWithS:time];
    [putItemRequest.item setValue:value forKey:@"Time"];
    
    if(YES){
        value = [[DynamoDBAttributeValue alloc] initWithN:type];
        [putItemRequest.item setValue:value forKey:@"type"];
    }
    
    if(YES){
        value = [[DynamoDBAttributeValue alloc] initWithS:uid2];
        [putItemRequest.item setValue:value forKey:@"UID2"];
    }
    if(self.textView.text!=NULL){
        value = [[DynamoDBAttributeValue alloc] initWithS:self.textView.text];
        [putItemRequest.item setValue:value forKey:@"String1"];
    }
    
    value = [[DynamoDBAttributeValue alloc] initWithS:filename];
    [putItemRequest.item setValue:value forKey:@"String2"];
    [self.ddb putItem:putItemRequest];
    dispatch_async(loadQueue, ^{
        for (NSString* uid in self.tempFollower) {
            DynamoDBPutItemRequest *putItemRequest = [DynamoDBPutItemRequest new];
            putItemRequest.tableName = @"TimeLine";
            
            // Each attribute will be a DynamoDBAttributeValue
            
            DynamoDBAttributeValue *value = [[DynamoDBAttributeValue alloc] initWithS:uid];
            [putItemRequest.item setValue:value forKey:@"UID"];
            
            // The item is an NSMutableDictionary, keyed by the attribute name
            value = [[DynamoDBAttributeValue alloc] initWithS:time];
            [putItemRequest.item setValue:value forKey:@"Time"];
            
            if(YES){
                value = [[DynamoDBAttributeValue alloc] initWithN:type];
                [putItemRequest.item setValue:value forKey:@"type"];
            }
            
            if(YES){
                value = [[DynamoDBAttributeValue alloc] initWithS:uid2];
                [putItemRequest.item setValue:value forKey:@"UID2"];
            }
            if(self.textView.text!=NULL){
                value = [[DynamoDBAttributeValue alloc] initWithS:self.textView.text];
                [putItemRequest.item setValue:value forKey:@"String1"];
            }
            value = [[DynamoDBAttributeValue alloc] initWithS:filename];
            [putItemRequest.item setValue:value forKey:@"String2"];
            [self.ddb putItem:putItemRequest];
        }
        // create the request, specify the table
    });
    [hud hide:YES];
    
}
#pragma mark select image from the library
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    UIImage *originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    //save image
    self.savedImage = originalImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
    //make selected image fit
    float oldHeight = originalImage.size.height;
    float oldWidth = originalImage.size.width;
    float newHeight = self.imageLeft.frame.size.height;
    float scaleFactor =  newHeight / oldHeight;
    float newWidth = oldWidth * scaleFactor;
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [originalImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageLeft.image = newImage;
    self.flag = @"new";
    [self.textView becomeFirstResponder];
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
#pragma mark limit textview charactor length
- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString*)aText {
    NSString* newText = [aTextView.text stringByReplacingCharactersInRange:aRange withString:aText];
    if (newText.length > TEXTVIEW_LENGTH1) {
        return NO;
    } else {
        return YES;
    }
}
#pragma mark textview charactor count
-(void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"text view checked");
    int len = textView.text.length;
    self.charactorCounter.text=[NSString stringWithFormat:@"%i/%i",TEXTVIEW_LENGTH1-len,TEXTVIEW_LENGTH1];
}
- (IBAction)sendImage:(id)sender {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd-HH:mm:ss";
    NSString *time = [dateFormatter stringFromDate:now];
    NSString *ID=self.UID;
    NSString *filename = [NSString stringWithFormat:@"%@-%@.jpeg", ID,time];
    if([self.flag isEqualToString:@"new"]){
       [self textUpload:self.UID time:time type:[NSString stringWithFormat:@"%i",IMAGE_TYPE] filename:filename];
        NSData *imageData = UIImageJPEGRepresentation(self.savedImage, 0.5);
        [self imageUpload:imageData filename:filename];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
