//
//  Register.m
//  RecipeShare
//
//  Created by Zhan Shu on 5/4/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "Register.h"
#import "ss4556AppDelegate.h"
#import "Constants.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AWSRuntime/AWSRuntime.h>
#import "MBProgressHUD.h"

@interface Register ()

//@property (strong, nonatomic) IBOutlet UIButton *register1;
@property (strong, nonatomic) IBOutlet UIImageView *photo;

@end

@implementation Register
@synthesize registerbutton=_registerbutton;

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
    // Do any additional setup after loading the view.
    //[self addDifferentTypesOfButton];
    self.password.secureTextEntry=YES;
    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    
    [self.registerbutton setStyleType:ACPButtonOK];
    [self.registerbutton setLabelTextColor:[UIColor whiteColor] highlightedColor:[UIColor blueColor] disableColor:nil];
    [self.registerbutton setLabelFont:[UIFont fontWithName:@"Trebuchet MS" size:20]];
    //[self.registerbutton setStyle:[UIColor blueColor]  andBottomColor:[UIColor greenColor]];
    
    
    //ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    self.uID = self.username.text;
    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];

}
- (IBAction)addphoto:(id)sender {
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
    
    mediaUI.delegate = self;
    
    [self presentViewController:mediaUI animated:YES completion:nil];
}

- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    UIImage *originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    self.photo.image = originalImage;
    CGSize size = CGSizeMake(100.0f, 100.0f);
    _photo.image=[self imageByScalingAndCroppingForSize:size];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)registerbutton:(id)sender {
    
    @try{
        if([self.username.text isEqual: @""]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Username cannot be empty!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        };
        if([self.password.text isEqual: @""]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password cannot be empty!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        };
        
        DynamoDBGetItemRequest *getItemRequest = [DynamoDBGetItemRequest new];
        getItemRequest.tableName = @"UserLogin";
        DynamoDBAttributeValue *userId = [[DynamoDBAttributeValue alloc] initWithS:self.username.text];
        getItemRequest.key = [NSMutableDictionary dictionaryWithObjectsAndKeys:userId, @"ID",nil];
        DynamoDBGetItemResponse *getItemResponse = [self.ddb getItem:getItemRequest];
        NSLog(@"%@",getItemResponse);
        DynamoDBAttributeValue *password=[getItemResponse.item valueForKey:@"password"];
        NSLog(@"paassword:%@",password.s);
        if(password!=NULL){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The user name has already been existed!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        else{
            DynamoDBPutItemRequest *putItemRequest = [DynamoDBPutItemRequest new];
            putItemRequest.tableName = @"UserLogin";
            

            DynamoDBAttributeValue *value = [[DynamoDBAttributeValue alloc] initWithS:self.username.text];
            [putItemRequest.item setValue:value forKey:@"ID"];

            
            value = [[DynamoDBAttributeValue alloc] initWithS:self.password.text];
            [putItemRequest.item setValue:value forKey:@"password"];
            NSString *s1=self.password.text;
            NSString *s2=self.passwordagain.text;
            if (![s1 isEqualToString: s2]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your input passwords are not consistent!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            if([self.passwordagain.text isEqual: @""]||[self.age.text isEqual: @""]||[self.sex.text isEqual: @""]||[self.email.text isEqual: @""]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your information is not complete!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            };
            value = [[DynamoDBAttributeValue alloc] initWithS:self.sex.text];
            [putItemRequest.item setValue:value forKey:@"sex"];
            value = [[DynamoDBAttributeValue alloc] initWithS:self.age.text];
            [putItemRequest.item setValue:value forKey:@"age"];
            value = [[DynamoDBAttributeValue alloc] initWithS:self.email.text];
            [putItemRequest.item setValue:value forKey:@"email"];
            [self.ddb putItem:putItemRequest];
            
            //NSDate *now = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd-HH:mm:ss";
            //NSString *time = [dateFormatter stringFromDate:now];
            
            NSData *imageData = UIImageJPEGRepresentation(_photo.image, 0.5);
            NSString *ID=self.username.text;
            NSString *filename = [NSString stringWithFormat:@"%@-profile.jpeg", ID];
            [self imageUpload:imageData filename:filename];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Congratulations! You have been successfully registered!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        [self performSegueWithIdentifier:@"registerin" sender:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }

}



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self) return;
    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    appDelegate.username=self.username.text;
    appDelegate.password=self.password.text;
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.username|| theTextField == self.password||theTextField==self.passwordagain||self.sex||self.age||self.email) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    [self.email resignFirstResponder];
    [self.passwordagain resignFirstResponder];
    [self.age resignFirstResponder];
    [self.sex resignFirstResponder];
}
/*
-(void)addDifferentTypesOfButton
{
    // A rounded Rect button created by using class method
    UIButton *roundRectButton = [UIButton buttonWithType:
                                 UIButtonTypeRoundedRect];
    [roundRectButton setFrame:CGRectMake(60, 50, 200, 40)];
    // sets title for the button
    [roundRectButton setTitle:@"Rounded Rect Button" forState:
     UIControlStateNormal];
    [self.view addSubview:roundRectButton];
    
    UIButton *customButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [customButton setBackgroundColor: [UIColor lightGrayColor]];
    [customButton setTitleColor:[UIColor blackColor] forState:
     UIControlStateHighlighted];
    //sets background image for normal state
    [customButton setBackgroundImage:[UIImage imageNamed:
                                      @"Button_Default.png"]
                            forState:UIControlStateNormal];
    //sets background image for highlighted state
    [customButton setBackgroundImage:[UIImage imageNamed:
                                      @"Button_Highlighted.png"]
                            forState:UIControlStateHighlighted];
    [customButton setFrame:CGRectMake(60, 100, 200, 40)];
    [customButton setTitle:@"Custom Button" forState:UIControlStateNormal];
    [self.view addSubview:customButton];
    

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
            
            /*if(putObjectResponse.error ==nil && putObjectResponse.exception ==nil)
                [self showAlertMessage:@"The new recipe was successfully uploaded." withTitle:@"Upload Completed"];
            [hud hide:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];*/
        });
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

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self.photo.image;
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




@end
