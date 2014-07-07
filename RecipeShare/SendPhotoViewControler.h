//
//  SendPhotoViewControler.h
//  RecipeShare
//
//  Created by D L on 5/11/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface SendPhotoViewControler : UIViewController<UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageLeft;
@property (strong, nonatomic) IBOutlet UITextView *textView;
- (IBAction)sendImage:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *charactorCounter;
- (IBAction)cancel:(id)sender;


@end
