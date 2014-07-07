//
//  Register.h
//  RecipeShare
//
//  Created by Zhan Shu on 5/4/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "ACPButton.h"
#import <AWSS3/AWSS3.h>


@interface Register : UIViewController <UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet ACPButton *registerbutton;
@property (strong, nonatomic) IBOutlet UITextField *passwordagain;
@property (strong, nonatomic) IBOutlet UITextField *sex;
@property (strong, nonatomic) IBOutlet UITextField *age;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) AmazonDynamoDBClient *ddb;
@property (nonatomic, retain) NSString *nextToken;
@property (nonatomic, strong)NSString *uID;

@end
