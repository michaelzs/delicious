//
//  SendImageViewController.h
//  RecipeShare
//
//  Created by D L on 5/4/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
@interface SendImageViewController : UIViewController<UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (IBAction)sendImage:(id)sender;
- (IBAction)cancel:(id)sender;

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *charactorCounter;

@property (strong, nonatomic) IBOutlet UIImageView *imageLeft;



@end
